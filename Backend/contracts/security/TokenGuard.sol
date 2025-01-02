// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title TokenGuard - Protection des tokens SBT
 * @author DuxProject Team
 * @notice Assure la sécurité et l'intégrité des tokens SBT
 * @dev Implémente des mécanismes de protection pour les tokens non-transférables
 */
contract TokenGuard is AccessControl {
    // Mapping des tokens sécurisés
    mapping(uint256 => bool) private secureTokens;
    
    // Mapping des tokens révoqués
    mapping(uint256 => bool) private revokedTokens;

    // Events
    event TokenSecured(uint256 indexed tokenId);
    event TokenRevoked(uint256 indexed tokenId);
    event TokenRestored(uint256 indexed tokenId);

    /**
     * @notice Constructeur du garde des tokens
     * @dev Configure les rôles initiaux
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Vérifie si un token est sécurisé
     * @dev Vérifie le statut de sécurité et de révocation
     * @param tokenId L'identifiant du token à vérifier
     * @return bool True si le token est sécurisé et non révoqué
     */
    function isTokenSafe(uint256 tokenId) public view returns (bool) {
        return secureTokens[tokenId] && !revokedTokens[tokenId];
    }

    /**
     * @notice Sécurise un nouveau token
     * @dev Marque un token comme sécurisé
     * @param tokenId L'identifiant du token à sécuriser
     */
    function secureToken(uint256 tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!secureTokens[tokenId], "Token already secured");
        secureTokens[tokenId] = true;
        emit TokenSecured(tokenId);
    }

    /**
     * @notice Révoque un token
     * @dev Marque un token comme révoqué
     * @param tokenId L'identifiant du token à révoquer
     */
    function revokeToken(uint256 tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!revokedTokens[tokenId], "Token already revoked");
        revokedTokens[tokenId] = true;
        emit TokenRevoked(tokenId);
    }

    /**
     * @notice Restaure un token révoqué
     * @dev Retire le statut de révocation d'un token
     * @param tokenId L'identifiant du token à restaurer
     */
    function restoreToken(uint256 tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(revokedTokens[tokenId], "Token not revoked");
        revokedTokens[tokenId] = false;
        emit TokenRestored(tokenId);
    }

    /**
     * @notice Vérifie si un token est révoqué
     * @dev Retourne le statut de révocation d'un token
     * @param tokenId L'identifiant du token à vérifier
     * @return bool True si le token est révoqué
     */
    function isTokenRevoked(uint256 tokenId) public view returns (bool) {
        return revokedTokens[tokenId];
    }
} 