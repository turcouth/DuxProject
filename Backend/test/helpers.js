const { expect } = require("chai");
const { ethers } = require("hardhat");
const snarkjs = require("snarkjs");
const path = require("path");
const fs = require('fs');

/**
 * Génère une preuve ZK pour la vérification d'âge
 */
async function generateProof(birthTimestamp, currentTimestamp, minAgeInSeconds) {
    const input = {
        birthTimestamp: birthTimestamp.toString(),
        currentTimestamp: currentTimestamp.toString(),
        minAgeInSeconds: minAgeInSeconds.toString()
    };

    console.log("Entrées de preuve:", input);

    // Chemins des fichiers
    const circuitWasmPath = path.join(__dirname, "../circuits/age_verification/age_check_js/age_check.wasm");
    const zkeyPath = path.join(__dirname, "../circuits/age_verification/age_check_0001.zkey");
    const vkeyPath = path.join(__dirname, "../circuits/age_verification/verification_key.json");

    try {
        // Vérification de l'existence des fichiers
        if (!fs.existsSync(circuitWasmPath)) {
            throw new Error(`Fichier WASM non trouvé: ${circuitWasmPath}`);
        }
        if (!fs.existsSync(zkeyPath)) {
            throw new Error(`Fichier ZKEY non trouvé: ${zkeyPath}`);
        }
        if (!fs.existsSync(vkeyPath)) {
            throw new Error(`Fichier de clé de vérification non trouvé: ${vkeyPath}`);
        }

        // Génération de la preuve
        const { proof, publicSignals } = await snarkjs.groth16.fullProve(
            input, 
            circuitWasmPath, 
            zkeyPath
        );

        console.log("Preuve générée avec succès");
        console.log("Signaux publics:", publicSignals);

        // Formatage des points de la courbe elliptique
        const _pA = [
            ethers.BigNumber.from(proof.pi_a[0]).toString(),
            ethers.BigNumber.from(proof.pi_a[1]).toString()
        ];

        const _pB = [
            [
                ethers.BigNumber.from(proof.pi_b[0][0]).toString(),
                ethers.BigNumber.from(proof.pi_b[0][1]).toString()
            ],
            [
                ethers.BigNumber.from(proof.pi_b[1][0]).toString(),
                ethers.BigNumber.from(proof.pi_b[1][1]).toString()
            ]
        ];

        const _pC = [
            ethers.BigNumber.from(proof.pi_c[0]).toString(),
            ethers.BigNumber.from(proof.pi_c[1]).toString()
        ];

        // Les signaux publics sont dans l'ordre : isAdult (sortie), currentTimestamp, minAgeInSeconds
        const _pubSignals = [
            ethers.BigNumber.from(publicSignals[0]).toString(), // isAdult
            ethers.BigNumber.from(publicSignals[1]).toString(), // currentTimestamp
            ethers.BigNumber.from(publicSignals[2]).toString()  // minAgeInSeconds
        ];

        // Vérification de la preuve
        const vKey = JSON.parse(fs.readFileSync(vkeyPath));
        const isValid = await snarkjs.groth16.verify(vKey, publicSignals, proof);
        
        if (!isValid) {
            throw new Error("La vérification de la preuve a échoué");
        }

        console.log("Vérification de la preuve réussie");
        console.log("Preuve brute:", proof);
        console.log("Signaux publics bruts:", publicSignals);
        console.log("_pA:", _pA);
        console.log("_pB:", _pB);
        console.log("_pC:", _pC);
        console.log("_pubSignals:", _pubSignals);

        const result = {
            _pA,
            _pB,
            _pC,
            _pubSignals
        };

        console.log("Résultat final:", result);

        return result;

    } catch (error) {
        console.error("Erreur lors de la génération de la preuve:", error);
        throw error;
    }
}

module.exports = {
    generateProof
}; 