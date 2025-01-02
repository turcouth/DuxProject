// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IAgeVerifier - Interface du vérificateur d'âge
/// @author DuxProject Team
/// @notice Interface pour la vérification cryptographique de l'âge
/// @dev Interface pour le contrat vérifiant les preuves ZK-SNARK d'âge
interface IAgeVerifier {
    /// @notice Vérifie une preuve ZK-SNARK d'âge
    /// @dev Implémente la vérification cryptographique Groth16
    /// @param a Points G1 de la courbe elliptique (première partie de la preuve)
    /// @param b Points G2 de la courbe elliptique (deuxième partie de la preuve)
    /// @param c Points G1 de la courbe elliptique (troisième partie de la preuve)
    /// @param input Signaux publics [currentTimestamp, minAgeInSeconds]
    /// @return bool Vrai si la preuve est valide, faux sinon
    function verifyProof(
        uint[2] calldata a,
        uint[2][2] calldata b,
        uint[2] calldata c,
        uint[2] calldata input
    ) external view returns (bool);
} 