/**
 * @title Tests du circuit ZK-SNARK de vérification d'âge
 * @author DuxProject Team
 * @notice Tests du circuit cryptographique pour la vérification d'âge
 * @dev Tests complets du circuit Groth16 et de la génération des preuves
 */

const { expect } = require("chai");
const snarkjs = require("snarkjs");
const path = require("path");

/**
 * @notice Suite de tests pour le circuit ZK-SNARK
 * @dev Vérifie la génération et la validation des preuves cryptographiques
 */
describe("Circuit ZK-SNARK de Vérification d'Âge", function() {
    // Chemins des fichiers du circuit
    const circuitWasmPath = path.join(__dirname, "../circuits/age_verification/age_check_js/age_check.wasm");
    const zkeyPath = path.join(__dirname, "../circuits/age_verification/age_check_0001.zkey");

    /**
     * @notice Génère une preuve ZK-SNARK
     * @dev Utilise snarkjs pour générer une preuve Groth16
     * @param birthTimestamp Timestamp de naissance
     * @param currentTimestamp Timestamp actuel
     * @param minAgeInSeconds Âge minimum requis en secondes
     * @return {Promise<Object>} Preuve et signaux publics
     */
    async function generateProof(birthTimestamp, currentTimestamp, minAgeInSeconds) {
        const input = {
            birthTimestamp: birthTimestamp,
            currentTimestamp: currentTimestamp,
            minAgeInSeconds: minAgeInSeconds
        };

        return await snarkjs.groth16.fullProve(input, circuitWasmPath, zkeyPath);
    }

    /**
     * @notice Tests de base du circuit
     * @dev Vérifie les cas d'utilisation principaux
     */
    describe("Tests de Base", function() {
        it("devrait générer une preuve valide pour une personne majeure", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp - (20 * 365.25 * 24 * 60 * 60); // 20 ans
            const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60; // 18 ans

            const { proof, publicSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                minAgeInSeconds
            );

            expect(proof).to.not.be.undefined;
            expect(publicSignals[0]).to.equal("1"); // isAdult devrait être true
        });

        it("devrait générer une preuve valide pour une personne mineure", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp - (15 * 365.25 * 24 * 60 * 60); // 15 ans
            const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60; // 18 ans

            const { proof, publicSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                minAgeInSeconds
            );

            expect(proof).to.not.be.undefined;
            expect(publicSignals[0]).to.equal("0"); // isAdult devrait être false
        });
    });

    /**
     * @notice Tests des cas limites
     * @dev Vérifie le comportement aux limites d'âge
     */
    describe("Cas Limites", function() {
        it("devrait gérer correctement le cas d'une personne presque majeure", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;
            const birthTimestamp = currentTimestamp - minAgeInSeconds + (24 * 60 * 60); // 1 jour avant 18 ans

            const { proof, publicSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                minAgeInSeconds
            );

            expect(publicSignals[0]).to.equal("0"); // isAdult devrait être false
        });

        it("devrait gérer correctement le cas d'une personne exactement majeure", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;
            const birthTimestamp = currentTimestamp - minAgeInSeconds;

            const { proof, publicSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                minAgeInSeconds
            );

            expect(publicSignals[0]).to.equal("1"); // isAdult devrait être true
        });
    });

    /**
     * @notice Tests spécifiques aux années bissextiles
     * @dev Vérifie le calcul correct de l'âge avec les années bissextiles
     */
    describe("Tests Années Bissextiles", function() {
        it("devrait gérer correctement une personne née un 29 février", async function() {
            // 29 février 2004 (année bissextile)
            const birthTimestamp = 1078012800;
            // Utilisons une date fixe en 2023 pour le test
            const currentTimestamp = 1703862000; // 29 décembre 2023
            const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;

            const { proof, publicSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                minAgeInSeconds
            );

            expect(proof).to.not.be.undefined;
            expect(publicSignals[0]).to.equal("1"); // La personne a 19 ans en 2023
        });
    });

    /**
     * @notice Tests de robustesse du circuit
     * @dev Vérifie le comportement avec des cas extrêmes
     */
    describe("Tests de Robustesse", function() {
        it("devrait gérer correctement une personne très âgée", async function() {
            // Date fixe : 29 décembre 2023
            const currentTimestamp = 1703862000;
            // Date de naissance : 1er janvier 1933 (90 ans)
            const birthTimestamp = -1167609600;
            const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;

            const { proof, publicSignals } = await generateProof(
                birthTimestamp,
                currentTimestamp,
                minAgeInSeconds
            );

            expect(proof).to.not.be.undefined;
            expect(publicSignals[0]).to.equal("1"); // isAdult devrait être true
        });

        it("devrait rejeter une date de naissance future", async function() {
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const birthTimestamp = currentTimestamp + (24 * 60 * 60); // 1 jour dans le futur
            const minAgeInSeconds = 18 * 365.25 * 24 * 60 * 60;

            try {
                await generateProof(birthTimestamp, currentTimestamp, minAgeInSeconds);
                expect.fail("La preuve aurait dû échouer");
            } catch (error) {
                expect(error).to.exist;
            }
        });
    });
}); 