/**
 * @title Tests des preuves zk-SNARK
 * @author DuxProject Team
 * @notice Tests de génération et validation des preuves zk-SNARK
 */

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { network } = require("hardhat");
const helpers = require("./helpers");

/**
 * @notice Suite de tests pour les preuves zk-SNARK
 * @dev Vérifie la génération et la validation des preuves d'âge
 */
describe("Test de Preuve ZK-SNARK", function() {
    // Variables de test
    let ageSBT;
    let verifier;
    let owner;
    let user;
    let feeReceiver;

    const INITIAL_FEE = ethers.utils.parseEther("0.004"); // 0.004 ETH

    /**
     * @notice Récupère le timestamp du bloc actuel
     * @dev Utilise les fonctions RPC de Hardhat
     * @return {Promise<number>} Timestamp actuel
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
        [owner, user, feeReceiver] = await ethers.getSigners();

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
     * @notice Test de génération et vérification d'une preuve valide
     * @dev Vérifie le processus complet de preuve et mint
     */
    it("Devrait générer et vérifier une preuve valide", async function() {
        const currentTimestamp = await getCurrentTimestamp();
        const birthTimestamp = currentTimestamp - (20 * 365.25 * 24 * 60 * 60);
        const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;

        const proof = await helpers.generateProof(
            birthTimestamp,
            currentTimestamp,
            minAgeInSeconds
        );

        const mintTx = await ageSBT.connect(owner).verifyAndMint(user.address, proof._pA, proof._pB, proof._pC, proof._pubSignals);
        const receipt = await mintTx.wait();
        
        const tokenMintedEvent = receipt.events.find(e => e.event === "TokenMinted");
        expect(tokenMintedEvent).to.not.be.undefined;
        expect(tokenMintedEvent.args.to).to.equal(user.address);
        expect(tokenMintedEvent.args.tokenId).to.equal(0);
    });

    /**
     * @notice Test de rejet d'une preuve invalide
     * @dev Vérifie que le contrat rejette les preuves incorrectes
     */
    it("Devrait échouer avec une preuve invalide", async function() {
        const currentTimestamp = await getCurrentTimestamp();
        const birthTimestamp = currentTimestamp - (20 * 365.25 * 24 * 60 * 60);
        const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;

        // Générer une preuve invalide
        const invalidProof = { _pA: [], _pB: [], _pC: [], _pubSignals: [] };

        await expect(
            ageSBT.connect(owner).verifyAndMint(user.address, invalidProof._pA, invalidProof._pB, invalidProof._pC, invalidProof._pubSignals)
        ).to.be.revertedWith("Invalid proof");
    });
}); 