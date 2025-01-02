// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AccessController.sol";
import "./TokenGuard.sol";

/**
 * @title SecurityManager - Gestionnaire de sécurité principal
 * @author DuxProject Team
 * @notice Coordonne les différents aspects de sécurité du système
 * @dev Combine le contrôle d'accès et la protection des tokens
 */
contract SecurityManager {
    AccessController public immutable accessController;
    TokenGuard public immutable tokenGuard;

    /**
     * @notice Constructeur du gestionnaire de sécurité
     * @dev Initialise les composants de sécurité
     * @param _accessController Adresse du contrôleur d'accès
     * @param _tokenGuard Adresse du garde des tokens
     */
    constructor(address _accessController, address _tokenGuard) {
        require(_accessController != address(0), "Invalid access controller address");
        require(_tokenGuard != address(0), "Invalid token guard address");
        accessController = AccessController(_accessController);
        tokenGuard = TokenGuard(_tokenGuard);
    }

    /**
     * @notice Vérifie les permissions d'une opération
     * @dev Combine les vérifications d'accès et de token
     * @param operator L'adresse de l'opérateur
     * @param tokenId L'identifiant du token
     * @return bool True si l'opération est autorisée
     */
    function checkPermissions(address operator, uint256 tokenId) external view returns (bool) {
        return accessController.isOperator(operator) && tokenGuard.isTokenSafe(tokenId);
    }

    /**
     * @notice Vérifie si une adresse est autorisée pour la vérification
     * @dev Vérifie le rôle de vérificateur
     * @param verifier L'adresse du vérificateur
     * @return bool True si l'adresse est un vérificateur autorisé
     */
    function isAuthorizedVerifier(address verifier) external view returns (bool) {
        return accessController.isVerifier(verifier);
    }

    /**
     * @notice Vérifie si un token est sécurisé
     * @dev Délègue la vérification au TokenGuard
     * @param tokenId L'identifiant du token à vérifier
     * @return bool True si le token est sécurisé
     */
    function isTokenSecure(uint256 tokenId) external view returns (bool) {
        return tokenGuard.isTokenSafe(tokenId);
    }
} 