// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ProofValidator - Validateur de preuves zk-SNARK
/// @author DuxProject Team
/// @notice Gère la validation et le suivi des preuves zk-SNARK
/// @dev Implémente les mécanismes de vérification d'unicité et de validité temporelle
contract ProofValidator is Ownable {
    // Constantes
    uint256 public constant PROOF_VALIDITY_PERIOD = 1 hours;
    
    // État du contrat
    mapping(bytes32 => bool) public usedProofs;

    // Événements
    event ProofValidated(bytes32 indexed proofHash, uint256 timestamp);
    event ProofRejected(bytes32 indexed proofHash, string reason);
    event ValidityPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);

    /// @notice Vérifie qu'une preuve n'a pas déjà été utilisée
    /// @dev Calcule le hash de la preuve et vérifie son unicité
    /// @param _pA Premier élément de la preuve
    /// @param _pB Deuxième élément de la preuve
    /// @param _pC Troisième élément de la preuve
    /// @param _pubSignals Signaux publics de la preuve
    /// @return bool Validité de l'unicité de la preuve
    function validateProofUniqueness(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) public view returns (bool) {
        bytes32 proofHash = keccak256(abi.encodePacked(_pA, _pB, _pC, _pubSignals));
        require(!usedProofs[proofHash], "ProofValidator: Proof already used");
        return true;
    }

    /// @notice Vérifie la validité temporelle des signaux publics
    /// @dev Vérifie que le timestamp de la preuve est dans la période valide
    /// @param pubSignals Tableau des signaux publics [isAdult, currentTimestamp, minAgeInSeconds]
    /// @return bool Validité temporelle de la preuve
    function validatePublicSignals(uint256[3] memory pubSignals) public view returns (bool) {
        require(
            pubSignals[1] >= block.timestamp - PROOF_VALIDITY_PERIOD &&
            pubSignals[1] <= block.timestamp + PROOF_VALIDITY_PERIOD,
            "ProofValidator: Proof timestamp out of range"
        );
        return true;
    }

    /// @notice Enregistre une preuve comme utilisée
    /// @dev Stocke le hash de la preuve et émet un événement
    /// @param _pA Premier élément de la preuve
    /// @param _pB Deuxième élément de la preuve
    /// @param _pC Troisième élément de la preuve
    /// @param _pubSignals Signaux publics de la preuve
    function markProofAsUsed(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) internal {
        bytes32 proofHash = keccak256(abi.encodePacked(_pA, _pB, _pC, _pubSignals));
        usedProofs[proofHash] = true;
        emit ProofValidated(proofHash, block.timestamp);
    }

    /// @notice Vérifie si une preuve a déjà été utilisée
    /// @dev Calcule le hash de la preuve et vérifie son statut
    /// @param _pA Premier élément de la preuve
    /// @param _pB Deuxième élément de la preuve
    /// @param _pC Troisième élément de la preuve
    /// @param _pubSignals Signaux publics de la preuve
    /// @return bool Statut d'utilisation de la preuve
    function isProofUsed(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) public view returns (bool) {
        bytes32 proofHash = keccak256(abi.encodePacked(_pA, _pB, _pC, _pubSignals));
        return usedProofs[proofHash];
    }

    /// @notice Calcule le hash d'une preuve
    /// @dev Utilise keccak256 pour générer un identifiant unique
    /// @param _pA Premier élément de la preuve
    /// @param _pB Deuxième élément de la preuve
    /// @param _pC Troisième élément de la preuve
    /// @param _pubSignals Signaux publics de la preuve
    /// @return bytes32 Hash de la preuve
    function calculateProofHash(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_pA, _pB, _pC, _pubSignals));
    }
} 