/**
 * @title Setup - Configuration de l'environnement de test
 * @author DuxProject Team
 * @notice Configure l'environnement pour les tests du système AgeSBT
 * @dev Initialise les variables globales et les hooks pour les tests
 */

const { ethers } = require("hardhat");
const { expect } = require("chai");
const { deployTestContracts } = require("./Helpers");

/**
 * @notice Configure le contexte global pour les tests
 * @dev Initialise les contrats et les comptes avant chaque test
 */
async function setupTestEnvironment() {
    // Déploiement des contrats
    const contracts = await deployTestContracts();
    
    // Configuration des comptes
    const signers = await ethers.getSigners();
    const [owner, user1, user2] = signers;

    // Configuration des paramètres de test
    const testFee = ethers.parseEther("0.01");
    const testAge = 25;
    const testThreshold = 18;

    return {
        ...contracts,
        testFee,
        testAge,
        testThreshold,
        signers
    };
}

/**
 * @notice Réinitialise l'état des contrats
 * @dev Remet à zéro l'état des contrats entre les tests
 * @param {Object} contracts Les instances des contrats à réinitialiser
 */
async function resetContractState(contracts) {
    const { ageSBT, feeManager, rateLimiter } = contracts;
    
    // Réinitialisation des compteurs et états
    await feeManager.resetFees();
    await rateLimiter.resetLimits();
    await ageSBT.resetTokenCount();
}

/**
 * @notice Configure les hooks de test Mocha
 * @dev Définit les actions à exécuter avant et après chaque test
 */
function setupTestHooks() {
    beforeEach(async function() {
        this.testEnv = await setupTestEnvironment();
    });

    afterEach(async function() {
        if (this.testEnv) {
            await resetContractState(this.testEnv);
        }
    });
}

module.exports = {
    setupTestEnvironment,
    resetContractState,
    setupTestHooks
}; 