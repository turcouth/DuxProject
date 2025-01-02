/**
 * @title Tests du vérificateur d'âge
 * @author DuxProject Team
 * @notice Tests d'intégration pour le système de vérification d'âge
 * @dev Tests complets du contrat AgeSBT avec mock du vérificateur
 */

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { generateProof } = require("./helpers");
const { expectRevert, expectEvent } = require('@openzeppelin/test-helpers');

/**
 * @notice Suite de tests pour le système de vérification d'âge
 * @dev Tests des fonctionnalités de vérification et de mint
 */
describe("AgeSBT", function() {
    // Variables de test
    let ageSBT;
    let verifier;
    let owner;
    let addr1;
    let addr2;
    let website;
    let feeReceiver;
    const INITIAL_FEE = ethers.utils.parseEther("0.004"); // 0.004 ETH
    const MIN_AGE_IN_SECONDS = 18 * 365 * 24 * 60 * 60; // 18 ans en secondes

    /**
     * @notice Configuration initiale avant chaque test
     * @dev Déploie les contrats et configure les comptes de test
     */
    beforeEach(async function() {
        [owner, addr1, addr2, website, feeReceiver] = await ethers.getSigners();

        // Déploie d'abord le mock du vérificateur
        const MockVerifier = await ethers.getContractFactory("MockVerifier");
        verifier = await MockVerifier.deploy();
        await verifier.deployed();

        // Déploie ensuite le contrat AgeSBT avec l'adresse du vérificateur et les paramètres de frais
        const AgeSBTFactory = await ethers.getContractFactory("AgeSBT");
        ageSBT = await AgeSBTFactory.deploy(
            verifier.address,
            INITIAL_FEE,
            feeReceiver.address
        );
        await ageSBT.deployed();
    });

    /**
     * @notice Tests de déploiement
     * @dev Vérifie la configuration initiale du contrat
     */
    describe("Déploiement", function() {
        it("Devrait définir le bon propriétaire", async function() {
            expect(await ageSBT.owner()).to.equal(owner.address);
        });

        it("Devrait avoir le bon nom et symbole", async function() {
            expect(await ageSBT.name()).to.equal("Age Verification SBT");
            expect(await ageSBT.symbol()).to.equal("AVSBT");
        });

        it("Devrait définir le bon montant de vérification initial", async function() {
            const fee = await ageSBT.verificationFee();
            expect(fee).to.equal(INITIAL_FEE);
        });
    });

    /**
     * @notice Tests de vérification et mint
     * @dev Vérifie le processus complet de vérification et création de SBT
     */
    describe("Vérification et Mint", function() {
        it("Devrait permettre de mint un SBT avec une preuve valide", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp - MIN_AGE_IN_SECONDS - 1000;
            
            const { _pA, _pB, _pC, _pubSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                MIN_AGE_IN_SECONDS
            );

            await verifier.setVerificationResult(true);

            const tx = await ageSBT.verifyAndMint(
                addr1.address,
                _pA,
                _pB,
                _pC,
                _pubSignals
            );
            const receipt = await tx.wait();

            // Vérifie les événements et l'état
            const tokenMintedEvent = receipt.events.find(
                event => event.event === "TokenMinted"
            );
            expect(tokenMintedEvent).to.not.be.undefined;
            expect(tokenMintedEvent.args[0]).to.equal(addr1.address);
            expect(tokenMintedEvent.args[1].toNumber()).to.equal(0);

            const ageVerifiedEvent = receipt.events.find(
                event => event.event === "AgeVerified"
            );
            expect(ageVerifiedEvent).to.not.be.undefined;
            expect(ageVerifiedEvent.args[0]).to.equal(addr1.address);
            expect(ageVerifiedEvent.args[1].toNumber()).to.be.closeTo(currentTimestamp, 2);

            expect(await ageSBT.isVerified(addr1.address)).to.be.true;
        });

        it("Ne devrait pas permettre de mint avec une preuve invalide", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp - MIN_AGE_IN_SECONDS - 1000;
            
            const { _pA, _pB, _pC, _pubSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                MIN_AGE_IN_SECONDS
            );
            
            await verifier.setVerificationResult(false);

            await expectRevert(
                ageSBT.verifyAndMint(addr1.address, _pA, _pB, _pC, _pubSignals),
                "AgeSBT: Invalid age proof"
            );
        });

        it("Ne devrait pas permettre de mint avec un timestamp incorrect", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp - MIN_AGE_IN_SECONDS + 1000;
            
            const { _pA, _pB, _pC, _pubSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                MIN_AGE_IN_SECONDS
            );

            await verifier.setVerificationResult(true);

            await expectRevert(
                ageSBT.verifyAndMint(addr1.address, _pA, _pB, _pC, _pubSignals),
                "AgeSBT: Proof timestamp out of range"
            );
        });
    });

    /**
     * @notice Tests de vérification par les sites web
     * @dev Vérifie le processus de vérification par les sites externes
     */
    describe("Vérification par les sites web", function() {
        beforeEach(async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp - MIN_AGE_IN_SECONDS - 1000;
            
            const { _pA, _pB, _pC, _pubSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                MIN_AGE_IN_SECONDS
            );
            
            await verifier.setVerificationResult(true);
            await ageSBT.verifyAndMint(addr1.address, _pA, _pB, _pC, _pubSignals);
        });

        it("Devrait permettre à un site de vérifier l'âge avec le bon paiement", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp - MIN_AGE_IN_SECONDS - 1000;
            
            const { _pA, _pB, _pC, _pubSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                MIN_AGE_IN_SECONDS
            );

            await verifier.setVerificationResult(true);

            const tx = await ageSBT.connect(website).verifyIdentity(
                addr1.address,
                _pA,
                _pB,
                _pC,
                _pubSignals,
                { value: INITIAL_FEE }
            );
            const receipt = await tx.wait();

            const verificationPaidEvent = receipt.events.find(
                event => event.event === "VerificationPaid"
            );
            expect(verificationPaidEvent).to.not.be.undefined;
            expect(verificationPaidEvent.args.website).to.equal(website.address);
            expect(verificationPaidEvent.args.user).to.equal(addr1.address);
            expect(verificationPaidEvent.args.amount).to.equal(INITIAL_FEE);
        });
    });

    /**
     * @notice Tests de gestion des frais
     * @dev Vérifie la modification et la gestion des frais de vérification
     */
    describe("Gestion des frais", function() {
        it("Devrait permettre au propriétaire de modifier les frais", async function() {
            const newFee = INITIAL_FEE.mul(2);
            const tx = await ageSBT.setVerificationFee(newFee);
            const receipt = await tx.wait();

            const verificationFeeUpdatedEvent = receipt.events.find(
                event => event.event === "VerificationFeeUpdated"
            );
            expect(verificationFeeUpdatedEvent).to.not.be.undefined;
            expect(verificationFeeUpdatedEvent.args.oldFee).to.equal(INITIAL_FEE);
            expect(verificationFeeUpdatedEvent.args.newFee).to.equal(newFee);
            
            const fee = await ageSBT.verificationFee();
            expect(fee).to.equal(newFee);
        });
    });
}); 