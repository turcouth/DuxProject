/**
 * @title Script de déploiement des contrats
 * @author DuxProject Team
 * @notice Script pour déployer l'ensemble des contrats sur zkSync Era
 * @dev Déploie les contrats dans l'ordre suivant :
 * 1. Groth16Verifier
 * 2. FeeManager
 * 3. RateLimiter
 * 4. AgeVerificationManager
 * 5. AgeSBT
 */

require("dotenv").config();
const { Wallet, Provider, ContractFactory } = require("zksync-ethers");
const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

/**
 * @notice Fonction principale de déploiement
 * @dev Déploie tous les contrats et retourne leurs adresses
 * @return {Promise<Object>} Adresses des contrats déployés
 */
async function main() {
    console.log("Starting deployment process...");
    
    try {
        // Initialisation du provider zkSync
        const zkSyncTestnetUrl = "https://sepolia.era.zksync.dev";
        const provider = new Provider(zkSyncTestnetUrl);
        console.log("Provider initialized");
        
        const privateKey = process.env.PRIVATE_KEY;
        if (!privateKey) {
            throw new Error("Private key not found in .env file");
        }

        const wallet = new Wallet(privateKey, provider);
        console.log("Wallet address:", wallet.address);
        
        /**
         * @notice Déploiement du vérificateur Groth16
         * @dev Déploie le contrat qui vérifie les preuves ZK
         */
        console.log("Deploying Groth16Verifier...");
        const verifierPath = path.join(__dirname, "../artifacts-zk/contracts/Groth16Verifier.sol/Groth16Verifier.json");
        const verifierArtifact = require(verifierPath);
        const verifierFactory = new ContractFactory(verifierArtifact.abi, verifierArtifact.bytecode, wallet);
        const verifier = await verifierFactory.deploy();
        await verifier.waitForDeployment();
        const verifierAddress = await verifier.getAddress();
        console.log("Groth16Verifier deployed to:", verifierAddress);

        /**
         * @notice Déploiement du gestionnaire de frais
         * @dev Configure les frais initiaux et l'adresse du receveur
         */
        console.log("Deploying FeeManager...");
        const feeManagerPath = path.join(__dirname, "../artifacts-zk/contracts/managers/FeeManager.sol/FeeManager.json");
        const feeManagerArtifact = require(feeManagerPath);
        const feeManagerFactory = new ContractFactory(feeManagerArtifact.abi, feeManagerArtifact.bytecode, wallet);
        const initialFee = ethers.parseEther("0.01"); // 0.01 ETH
        const feeManager = await feeManagerFactory.deploy(initialFee, wallet.address);
        await feeManager.waitForDeployment();
        const feeManagerAddress = await feeManager.getAddress();
        console.log("FeeManager deployed to:", feeManagerAddress);

        /**
         * @notice Déploiement du limiteur de requêtes
         * @dev Gère les limites de requêtes par utilisateur
         */
        console.log("Deploying RateLimiter...");
        const rateLimiterPath = path.join(__dirname, "../artifacts-zk/contracts/managers/RateLimiter.sol/RateLimiter.json");
        const rateLimiterArtifact = require(rateLimiterPath);
        const rateLimiterFactory = new ContractFactory(rateLimiterArtifact.abi, rateLimiterArtifact.bytecode, wallet);
        const rateLimiter = await rateLimiterFactory.deploy();
        await rateLimiter.waitForDeployment();
        const rateLimiterAddress = await rateLimiter.getAddress();
        console.log("RateLimiter deployed to:", rateLimiterAddress);

        /**
         * @notice Déploiement du gestionnaire de vérification d'âge
         * @dev Gère la logique de vérification avec le vérificateur
         */
        console.log("Deploying AgeVerificationManager...");
        const ageVerificationManagerPath = path.join(__dirname, "../artifacts-zk/contracts/managers/AgeVerificationManager.sol/AgeVerificationManager.json");
        const ageVerificationManagerArtifact = require(ageVerificationManagerPath);
        const ageVerificationManagerFactory = new ContractFactory(ageVerificationManagerArtifact.abi, ageVerificationManagerArtifact.bytecode, wallet);
        const ageVerificationManager = await ageVerificationManagerFactory.deploy(verifierAddress);
        await ageVerificationManager.waitForDeployment();
        const ageVerificationManagerAddress = await ageVerificationManager.getAddress();
        console.log("AgeVerificationManager deployed to:", ageVerificationManagerAddress);

        /**
         * @notice Déploiement du contrat principal AgeSBT
         * @dev Déploie le contrat qui gère les SBT de vérification d'âge
         */
        console.log("Deploying AgeSBT...");
        const ageSBTPath = path.join(__dirname, "../artifacts-zk/contracts/AgeSBT.sol/AgeSBT.json");
        const ageSBTArtifact = require(ageSBTPath);
        const ageSBTFactory = new ContractFactory(ageSBTArtifact.abi, ageSBTArtifact.bytecode, wallet);
        const ageSBT = await ageSBTFactory.deploy(
            verifierAddress,
            initialFee,
            wallet.address
        );
        await ageSBT.waitForDeployment();
        const ageSBTAddress = await ageSBT.getAddress();
        console.log("AgeSBT deployed to:", ageSBTAddress);

        console.log("\nDeployment Summary:");
        console.log("-------------------");
        console.log("Groth16Verifier:", verifierAddress);
        console.log("FeeManager:", feeManagerAddress);
        console.log("RateLimiter:", rateLimiterAddress);
        console.log("AgeVerificationManager:", ageVerificationManagerAddress);
        console.log("AgeSBT:", ageSBTAddress);

        return {
            verifier: verifierAddress,
            feeManager: feeManagerAddress,
            rateLimiter: rateLimiterAddress,
            ageVerificationManager: ageVerificationManagerAddress,
            ageSBT: ageSBTAddress
        };

    } catch (error) {
        console.error("Detailed error:", error);
        throw error;
    }
}

// Pour l'exécution directe
if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error("Deployment failed:", error);
            process.exit(1);
        });
}

// Pour l'import dans d'autres scripts
module.exports = main; 