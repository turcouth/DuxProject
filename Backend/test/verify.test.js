/**
 * @title Tests de vérification d'identité
 * @author DuxProject Team
 * @notice Tests des fonctionnalités de vérification d'identité par les sites web
 * @dev Tests du processus de vérification et de paiement
 */

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { network } = require("hardhat");
const helpers = require("./helpers");

/**
 * @notice Suite de tests pour la vérification d'identité
 * @dev Vérifie l'interaction entre les sites web et le contrat
 */
describe("Test de Vérification d'Identité", function() {
    // Variables de test
    let ageSBT;
    let verifier;
    let owner;
    let user;
    let website;
    let feeReceiver;

    const INITIAL_FEE = ethers.utils.parseEther("0.004"); // 0.004 ETH

    /**
     * @notice Récupère le timestamp actuel du réseau
     * @dev Utilise les fonctions RPC de Hardhat
     * @return {Promise<number>} Timestamp du bloc actuel
     */
    async function getCurrentTimestamp() {
        const blockNumber = await network.provider.send("eth_blockNumber");
        const block = await network.provider.send("eth_getBlockByNumber", [blockNumber, false]);
        return parseInt(block.timestamp);
    }

    /**
     * @notice Configuration initiale avant chaque test
     * @dev Déploie les contrats et configure les comptes
     */
    beforeEach(async function() {
        [owner, user, website, feeReceiver] = await ethers.getSigners();

        const VerifierFactory = await ethers.getContractFactory("Groth16Verifier");
        verifier = await VerifierFactory.deploy();
        await verifier.deployed();

        const AgeSBTFactory = await ethers.getContractFactory("AgeSBT");
        ageSBT = await AgeSBTFactory.deploy(
            verifier.address,
            INITIAL_FEE,
            feeReceiver.address
        );
        await ageSBT.deployed();
    });

    /**
     * @notice Test de vérification réussie avec paiement correct
     * @dev Vérifie le processus complet de vérification par un site web
     */
    it("Devrait permettre à un site de vérifier l'identité avec le bon paiement", async function() {
        const currentTimestamp = await getCurrentTimestamp();
        const birthTimestamp = currentTimestamp - (20 * 365.25 * 24 * 60 * 60);
        const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;

        const proof = await helpers.generateProof(
            birthTimestamp,
            currentTimestamp,
            minAgeInSeconds
        );

        // Mint d'abord le SBT
        await ageSBT.connect(owner).verifyAndMint(
            user.address,
            proof._pA,
            proof._pB,
            proof._pC,
            proof._pubSignals
        );

        // Vérification par le site
        const verifyTx = await ageSBT.connect(website).verifyIdentity(
            user.address,
            proof._pA,
            proof._pB,
            proof._pC,
            proof._pubSignals,
            { value: INITIAL_FEE }
        );
        const receipt = await verifyTx.wait();

        const verificationPaidEvent = receipt.events.find(e => e.event === "VerificationPaid");
        expect(verificationPaidEvent).to.not.be.undefined;
        expect(verificationPaidEvent.args.website).to.equal(website.address);
        expect(verificationPaidEvent.args.user).to.equal(user.address);
        expect(verificationPaidEvent.args.amount).to.equal(INITIAL_FEE);
    });

    /**
     * @notice Test de vérification avec paiement insuffisant
     * @dev Vérifie que le contrat rejette les paiements insuffisants
     */
    it("Ne devrait pas permettre la vérification avec un paiement insuffisant", async function() {
        const currentTimestamp = await getCurrentTimestamp();
        const birthTimestamp = currentTimestamp - (20 * 365.25 * 24 * 60 * 60);
        const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;

        const proof = await helpers.generateProof(
            birthTimestamp,
            currentTimestamp,
            minAgeInSeconds
        );

        // Mint d'abord le SBT
        await ageSBT.connect(owner).verifyAndMint(
            user.address,
            proof._pA,
            proof._pB,
            proof._pC,
            proof._pubSignals
        );

        // Tentative de vérification avec un paiement insuffisant
        await expect(
            ageSBT.connect(website).verifyIdentity(
                user.address,
                proof._pA,
                proof._pB,
                proof._pC,
                proof._pubSignals,
                { value: INITIAL_FEE.sub(1) }
            )
        ).to.be.revertedWith("FeeManager: Insufficient payment");
    });
}); 