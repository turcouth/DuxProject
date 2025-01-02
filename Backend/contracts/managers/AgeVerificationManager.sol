// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AgeVerificationManager - Gestionnaire de vérification d'âge
/// @author DuxProject Team
/// @notice Gère la vérification d'âge des utilisateurs via des preuves zk-SNARKs
/// @dev Implémente la logique de vérification et de gestion des statuts de vérification
contract AgeVerificationManager is Ownable {
    // Contrats externes
    IGroth16Verifier public verifier;

    // État du contrat
    mapping(address => bool) private _isVerified;

    // Événements
    event AgeVerified(address indexed user, uint256 timestamp);
    event VerificationRevoked(address indexed user, uint256 timestamp);
    event VerifierUpdated(address oldVerifier, address newVerifier);

    /// @notice Initialise le gestionnaire de vérification
    /// @dev Configure l'adresse du vérificateur Groth16
    /// @param _verifier Adresse du contrat vérificateur
    constructor(address _verifier) {
        require(_verifier != address(0), "AgeVerificationManager: Verifier address cannot be zero");
        verifier = IGroth16Verifier(_verifier);
    }

    /// @notice Vérifie si un utilisateur est vérifié
    /// @param user Adresse de l'utilisateur à vérifier
    /// @return bool Statut de vérification
    function isVerified(address user) public view returns (bool) {
        return _isVerified[user];
    }

    /// @notice Vérifie une preuve zk-SNARK
    /// @dev Utilise le vérificateur Groth16 pour valider la preuve
    /// @param _pA Premier élément de la preuve
    /// @param _pB Deuxième élément de la preuve
    /// @param _pC Troisième élément de la preuve
    /// @param _pubSignals Signaux publics de la preuve
    /// @param user Adresse de l'utilisateur concerné
    function verifyProof(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals,
        address user
    ) internal virtual {
        require(
            verifier.verifyProof(_pA, _pB, _pC, _pubSignals),
            "AgeVerificationManager: Invalid age proof"
        );
        emit AgeVerified(user, block.timestamp);
    }

    /// @notice Marque une adresse comme vérifiée
    /// @dev Modifie le statut de vérification dans le mapping
    /// @param user Adresse à marquer comme vérifiée
    function setVerified(address user) internal {
        require(!_isVerified[user], "AgeVerificationManager: Address already verified");
        _isVerified[user] = true;
    }

    /// @notice Révoque la vérification d'une adresse
    /// @dev Retire le statut de vérification
    /// @param user Adresse dont la vérification doit être révoquée
    function revokeVerification(address user) internal {
        require(_isVerified[user], "AgeVerificationManager: Address not verified");
        _isVerified[user] = false;
        emit VerificationRevoked(user, block.timestamp);
    }

    /// @notice Met à jour l'adresse du vérificateur
    /// @dev Accessible uniquement au propriétaire du contrat
    /// @param newVerifier Nouvelle adresse du vérificateur
    function updateVerifier(address newVerifier) external onlyOwner {
        require(newVerifier != address(0), "AgeVerificationManager: New verifier address cannot be zero");
        address oldVerifier = address(verifier);
        verifier = IGroth16Verifier(newVerifier);
        emit VerifierUpdated(oldVerifier, newVerifier);
    }
}

/// @title IGroth16Verifier - Interface du vérificateur zk-SNARK
/// @dev Interface pour le vérificateur de preuves Groth16
interface IGroth16Verifier {
    /// @notice Vérifie une preuve zk-SNARK
    /// @param _pA Premier élément de la preuve
    /// @param _pB Deuxième élément de la preuve
    /// @param _pC Troisième élément de la preuve
    /// @param _pubSignals Signaux publics de la preuve
    /// @return bool Validité de la preuve
    function verifyProof(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) external view returns (bool);
} 