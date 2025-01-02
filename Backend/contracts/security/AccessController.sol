// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccessController - Gestionnaire des accès
 * @author DuxProject Team
 * @notice Gère les rôles et permissions du système
 * @dev Étend AccessControl d'OpenZeppelin pour la gestion des rôles
 */
contract AccessController is AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /**
     * @notice Constructeur du contrôleur d'accès
     * @dev Configure les rôles initiaux et attribue le rôle admin par défaut
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Vérifie si une adresse a le rôle de vérificateur
     * @dev Utilise la fonction hasRole d'AccessControl
     * @param account L'adresse à vérifier
     * @return bool True si l'adresse a le rôle de vérificateur
     */
    function isVerifier(address account) public view returns (bool) {
        return hasRole(VERIFIER_ROLE, account);
    }

    /**
     * @notice Vérifie si une adresse a le rôle d'administrateur
     * @dev Utilise la fonction hasRole d'AccessControl
     * @param account L'adresse à vérifier
     * @return bool True si l'adresse a le rôle d'administrateur
     */
    function isAdmin(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    /**
     * @notice Vérifie si une adresse a le rôle d'opérateur
     * @dev Utilise la fonction hasRole d'AccessControl
     * @param account L'adresse à vérifier
     * @return bool True si l'adresse a le rôle d'opérateur
     */
    function isOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    /**
     * @notice Ajoute un nouveau vérificateur
     * @dev Seul un admin peut appeler cette fonction
     * @param account L'adresse à ajouter comme vérificateur
     */
    function addVerifier(address account) external onlyRole(ADMIN_ROLE) {
        grantRole(VERIFIER_ROLE, account);
    }

    /**
     * @notice Ajoute un nouvel opérateur
     * @dev Seul un admin peut appeler cette fonction
     * @param account L'adresse à ajouter comme opérateur
     */
    function addOperator(address account) external onlyRole(ADMIN_ROLE) {
        grantRole(OPERATOR_ROLE, account);
    }

    /**
     * @notice Révoque le rôle de vérificateur
     * @dev Seul un admin peut appeler cette fonction
     * @param account L'adresse à révoquer
     */
    function removeVerifier(address account) external onlyRole(ADMIN_ROLE) {
        revokeRole(VERIFIER_ROLE, account);
    }

    /**
     * @notice Révoque le rôle d'opérateur
     * @dev Seul un admin peut appeler cette fonction
     * @param account L'adresse à révoquer
     */
    function removeOperator(address account) external onlyRole(ADMIN_ROLE) {
        revokeRole(OPERATOR_ROLE, account);
    }
} 