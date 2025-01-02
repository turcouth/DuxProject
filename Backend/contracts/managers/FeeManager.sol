// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title FeeManager - Gestionnaire des frais de vérification
/// @author DuxProject Team
/// @notice Gère la collecte et la distribution des frais de vérification
/// @dev Implémente un système de gestion des frais avec protection contre la réentrance
contract FeeManager is Ownable, ReentrancyGuard {
    // État du contrat
    uint256 public verificationFee;
    address public feeReceiver;
    uint256 public accumulatedFees;

    // Événements
    event VerificationFeeUpdated(uint256 oldFee, uint256 newFee);
    event FeeReceiverUpdated(address oldReceiver, address newReceiver);
    event VerificationPaid(address indexed verifier, address indexed user, uint256 amount);
    event FeesWithdrawn(address indexed receiver, uint256 amount);

    /// @notice Initialise le gestionnaire de frais
    /// @dev Configure les frais initiaux et l'adresse du receveur
    /// @param _initialFee Montant initial des frais de vérification
    /// @param _feeReceiver Adresse qui recevra les frais
    constructor(uint256 _initialFee, address _feeReceiver) {
        require(_initialFee > 0, "FeeManager: Fee cannot be zero");
        require(_feeReceiver != address(0), "FeeManager: Fee receiver cannot be zero address");
        verificationFee = _initialFee;
        feeReceiver = _feeReceiver;
    }

    /// @notice Vérifie si le paiement reçu est suffisant
    /// @dev Compare msg.value avec verificationFee
    function validatePayment() internal view {
        require(msg.value >= verificationFee, "FeeManager: Insufficient payment");
    }

    /// @notice Traite le paiement et gère le remboursement du surplus
    /// @dev Accumule les frais et rembourse l'excédent si nécessaire
    function processPayment() internal {
        accumulatedFees += verificationFee;
        
        if (msg.value > verificationFee) {
            (bool success, ) = msg.sender.call{value: msg.value - verificationFee}("");
            require(success, "FeeManager: Refund transfer failed");
        }
    }

    /// @notice Met à jour le montant des frais de vérification
    /// @dev Seul le propriétaire peut modifier les frais
    /// @param newFee Nouveau montant des frais
    function setVerificationFee(uint256 newFee) external onlyOwner {
        require(newFee > 0, "FeeManager: Fee cannot be zero");
        uint256 oldFee = verificationFee;
        verificationFee = newFee;
        emit VerificationFeeUpdated(oldFee, newFee);
    }
    
    /// @notice Change l'adresse qui reçoit les frais
    /// @dev Seul le propriétaire peut modifier l'adresse
    /// @param newReceiver Nouvelle adresse du receveur
    function setFeeReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != address(0), "FeeManager: Fee receiver cannot be zero address");
        address oldReceiver = feeReceiver;
        feeReceiver = newReceiver;
        emit FeeReceiverUpdated(oldReceiver, newReceiver);
    }
    
    /// @notice Retourne le montant total des frais accumulés
    /// @return uint256 Montant total des frais non retirés
    function getAccumulatedFees() external view returns (uint256) {
        return accumulatedFees;
    }

    /// @notice Permet au receveur de retirer les frais accumulés
    /// @dev Protégé contre la réentrance et accessible uniquement au receveur
    function withdrawFees() external nonReentrant {
        require(msg.sender == feeReceiver, "FeeManager: Only fee receiver can withdraw");
        require(accumulatedFees > 0, "FeeManager: No fees to withdraw");

        uint256 amount = accumulatedFees;
        accumulatedFees = 0;

        (bool success, ) = feeReceiver.call{value: amount}("");
        require(success, "FeeManager: Withdrawal transfer failed");

        emit FeesWithdrawn(feeReceiver, amount);
    }
} 