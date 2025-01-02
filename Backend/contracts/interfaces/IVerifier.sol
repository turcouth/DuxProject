// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IVerifier - Interface du vérificateur de preuves
/// @author DuxProject Team
/// @notice Interface pour la vérification des preuves zk-SNARK
/// @dev Interface minimale pour les vérificateurs de preuves Groth16
interface IVerifier {
    /// @notice Vérifie la validité d'une preuve zk-SNARK
    /// @dev Implémente la logique de vérification spécifique au circuit
    /// @param _pA Premier élément de la preuve (point G1)
    /// @param _pB Deuxième élément de la preuve (point G2)
    /// @param _pC Troisième élément de la preuve (point G1)
    /// @param _pubSignals Signaux publics de la preuve
    /// @return bool Validité de la preuve
    function verifyProof(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) external view returns (bool);
} 