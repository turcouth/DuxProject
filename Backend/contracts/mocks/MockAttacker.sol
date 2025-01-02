// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockAttacker - Contrat simulant un attaquant
 * @author DuxProject Team
 * @notice Contrat utilisé pour tester la sécurité du système de vérification d'âge
 * @dev Simule différentes attaques possibles sur le système AgeSBT
 */
contract MockAttacker {
    /**
     * @notice Tente une attaque de réentrance
     * @dev Simule une attaque de réentrance sur le contrat cible
     * @param target L'adresse du contrat à attaquer
     */
    function attemptReentrancy(address target) external payable {
        // Code de l'attaque
    }

    /**
     * @notice Tente une attaque par déni de service
     * @dev Simule une attaque DoS en épuisant les ressources
     * @param target L'adresse du contrat à attaquer
     */
    function attemptDOS(address target) external {
        // Code de l'attaque
    }

    /**
     * @notice Tente de manipuler les preuves
     * @dev Simule une tentative de manipulation des preuves ZK
     * @param target L'adresse du contrat à attaquer
     * @param fakeProof Les données de preuve falsifiées
     */
    function attemptProofManipulation(address target, bytes calldata fakeProof) external {
        // Code de l'attaque
    }

    /**
     * @notice Fonction de repli pour recevoir des ETH
     * @dev Nécessaire pour certains tests d'attaque
     */
    receive() external payable {}
} 