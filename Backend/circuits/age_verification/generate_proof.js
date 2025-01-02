const snarkjs = require("snarkjs");
const fs = require("fs");
const path = require("path");

async function generateProof(inputs) {
    const circuitWasmPath = path.join(__dirname, "age_check.wasm");
    const zkeyPath = path.join(__dirname, "circuit_final.zkey");

    try {
        // Génération de la preuve
        const { proof, publicSignals } = await snarkjs.groth16.fullProve(
            inputs,
            circuitWasmPath,
            zkeyPath
        );

        // Conversion des BigInts en strings pour la sérialisation
        const proofForContract = {
            a: [proof.pi_a[0], proof.pi_a[1]],
            b: [[proof.pi_b[0][1], proof.pi_b[0][0]], [proof.pi_b[1][1], proof.pi_b[1][0]]],
            c: [proof.pi_c[0], proof.pi_c[1]]
        };

        return {
            proof: proofForContract,
            publicSignals: publicSignals
        };
    } catch (error) {
        console.error("Erreur lors de la génération de la preuve:", error);
        throw error;
    }
}

module.exports = {
    generateProof
}; 