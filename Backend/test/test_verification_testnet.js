/**
 * @title Tests de vérification sur le testnet
 * @author DuxProject Team
 * @notice Tests d'intégration pour la vérification d'âge sur le testnet
 * @dev Teste le système complet de vérification dans un environnement de test
 */

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { generateProof } = require("../scripts/generate-proof");
const { deployTestContracts } = require("./Helpers");
const { setupTestEnvironment } = require("./setup");

describe("Tests de vérification sur le testnet", function() {
    let testEnv;

    /**
     * @notice Configure l'environnement avant chaque test
     * @dev Déploie les contrats et configure les comptes
     */
    beforeEach(async function() {
        testEnv = await setupTestEnvironment();
    });

    /**
     * @notice Teste le processus complet de vérification
     * @dev Vérifie la génération de preuve et la vérification sur la chaîne
     */
    it("devrait vérifier une preuve valide", async function() {
        const { ageSBT, owner } = testEnv;
        
        // Génération de la preuve
        const currentTime = Math.floor(Date.now() / 1000);
        const minAge = 18 * 365 * 24 * 60 * 60; // 18 ans en secondes
        const birthDate = currentTime - (20 * 365 * 24 * 60 * 60); // 20 ans
        
        const proof = await generateProof(birthDate, currentTime, minAge);
        expect(proof).to.not.be.undefined;
        
        // Vérification sur la chaîne
        const tx = await ageSBT.connect(owner).verifyAge(
            proof._pA,
            proof._pB,
            proof._pC,
            proof._pubSignals,
            { value: ethers.parseEther("0.01") }
        );
        
        await tx.wait();
        expect(await ageSBT.hasValidAge(owner.address)).to.be.true;
    });

    /**
     * @notice Teste le rejet d'une preuve invalide
     * @dev Vérifie que le système rejette correctement les preuves invalides
     */
    it("devrait rejeter une preuve invalide", async function() {
        const { ageSBT, owner } = testEnv;
        
        // Génération d'une preuve invalide
        const currentTime = Math.floor(Date.now() / 1000);
        const minAge = 18 * 365 * 24 * 60 * 60;
        const birthDate = currentTime - (15 * 365 * 24 * 60 * 60); // 15 ans
        
        const proof = await generateProof(birthDate, currentTime, minAge);
        
        // Tentative de vérification
        await expect(
            ageSBT.connect(owner).verifyAge(
                proof._pA,
                proof._pB,
                proof._pC,
                proof._pubSignals,
                { value: ethers.parseEther("0.01") }
            )
        ).to.be.revertedWith("Preuve invalide");
    });

    /**
     * @notice Teste les limites de taux
     * @dev Vérifie que le système applique correctement les limites de requêtes
     */
    it("devrait respecter les limites de taux", async function() {
        const { ageSBT, owner } = testEnv;
        
        // Génération d'une preuve valide
        const currentTime = Math.floor(Date.now() / 1000);
        const minAge = 18 * 365 * 24 * 60 * 60;
        const birthDate = currentTime - (20 * 365 * 24 * 60 * 60);
        
        const proof = await generateProof(birthDate, currentTime, minAge);
        
        // Première vérification
        await ageSBT.connect(owner).verifyAge(
            proof._pA,
            proof._pB,
            proof._pC,
            proof._pubSignals,
            { value: ethers.parseEther("0.01") }
        );
        
        // Tentative immédiate de seconde vérification
        await expect(
            ageSBT.connect(owner).verifyAge(
                proof._pA,
                proof._pB,
                proof._pC,
                proof._pubSignals,
                { value: ethers.parseEther("0.01") }
            )
        ).to.be.revertedWith("Limite de taux dépassée");
    });
}); 