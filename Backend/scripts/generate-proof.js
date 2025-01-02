/**
 * @title Script de génération de preuves ZK
 * @author DuxProject Team
 * @notice Script pour générer des preuves zk-SNARK pour la vérification d'âge
 * @dev Utilise snarkjs pour générer les preuves à partir des inputs
 */

const snarkjs = require("snarkjs");
const fs = require("fs");
const path = require("path");

/**
 * @notice Génère une preuve ZK pour la vérification d'âge
 * @dev Utilise le circuit compilé et les inputs pour générer la preuve
 * @param {Object} inputs Les entrées pour la génération de preuve
 * @param {number} inputs.age L'âge à vérifier
 * @param {number} inputs.threshold Le seuil d'âge minimum
 * @return {Promise<Object>} La preuve générée et les signaux publics
 */
async function generateProof(inputs) {
    try {
        const circuitWasmPath = path.join(__dirname, "../circuits/build/circuit.wasm");
        const circuitZkeyPath = path.join(__dirname, "../circuits/build/circuit_final.zkey");

        if (!fs.existsSync(circuitWasmPath) || !fs.existsSync(circuitZkeyPath)) {
            throw new Error("Circuit files not found. Please compile the circuit first.");
        }

        console.log("Generating proof with inputs:", inputs);
        const { proof, publicSignals } = await snarkjs.groth16.fullProve(
            inputs,
            circuitWasmPath,
            circuitZkeyPath
        );

        console.log("Proof generated successfully");
        console.log("Public signals:", publicSignals);

        return { proof, publicSignals };
    } catch (error) {
        console.error("Error generating proof:", error);
        throw error;
    }
}

/**
 * @notice Vérifie une preuve ZK générée
 * @dev Utilise la clé de vérification pour valider la preuve
 * @param {Object} proof La preuve à vérifier
 * @param {Array} publicSignals Les signaux publics associés
 * @return {Promise<boolean>} True si la preuve est valide
 */
async function verifyProof(proof, publicSignals) {
    try {
        const verificationKeyPath = path.join(__dirname, "../circuits/build/verification_key.json");
        
        if (!fs.existsSync(verificationKeyPath)) {
            throw new Error("Verification key not found");
        }

        const verificationKey = JSON.parse(fs.readFileSync(verificationKeyPath));
        const isValid = await snarkjs.groth16.verify(verificationKey, publicSignals, proof);

        console.log("Proof verification result:", isValid);
        return isValid;
    } catch (error) {
        console.error("Error verifying proof:", error);
        throw error;
    }
}

/**
 * @notice Convertit une preuve en format calldata
 * @dev Prépare la preuve pour l'utilisation dans un smart contract
 * @param {Object} proof La preuve à convertir
 * @param {Array} publicSignals Les signaux publics associés
 * @return {Promise<string>} Le calldata formaté
 */
async function generateCalldata(proof, publicSignals) {
    try {
        const calldata = await snarkjs.groth16.exportSolidityCallData(proof, publicSignals);
        console.log("Calldata generated successfully");
        return calldata;
    } catch (error) {
        console.error("Error generating calldata:", error);
        throw error;
    }
}

// Pour l'exécution directe
if (require.main === module) {
    const inputs = {
        age: 25,
        threshold: 18
    };

    generateProof(inputs)
        .then(async ({ proof, publicSignals }) => {
            await verifyProof(proof, publicSignals);
            await generateCalldata(proof, publicSignals);
        })
        .catch(console.error);
}

// Pour l'import dans d'autres scripts
module.exports = {
    generateProof,
    verifyProof,
    generateCalldata
}; 