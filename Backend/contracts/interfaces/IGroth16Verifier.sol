// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IGroth16Verifier - Interface du vérificateur Groth16
/// @author DuxProject Team
/// @notice Interface pour la vérification des preuves Groth16
/// @dev Interface standard pour les vérificateurs de preuves zk-SNARK Groth16
interface IGroth16Verifier {
    /// @notice Vérifie une preuve zk-SNARK au format Groth16
    /// @dev Implémente l'algorithme de vérification Groth16
    /// @param proof Éléments de la preuve [πA, πB, πC] encodés en un tableau
    /// @param pubSignals Signaux publics de la preuve
    /// @return bool Vrai si la preuve est valide, faux sinon
    function verifyProof(
        uint256[8] calldata proof,
        uint256[2] calldata pubSignals
    ) external view returns (bool);
} 