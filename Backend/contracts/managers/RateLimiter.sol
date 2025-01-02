// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title RateLimiter - Gestionnaire de limitation des requêtes
/// @author DuxProject Team
/// @notice Implémente un système de limitation des requêtes pour prévenir les abus
/// @dev Utilise un système de comptage par période pour limiter les requêtes par adresse
contract RateLimiter is Ownable {
    // Constantes du contrat
    uint256 public constant REQUEST_LIMIT = 50;
    uint256 public constant REQUEST_PERIOD = 1 hours;

    // Mappings de suivi
    mapping(address => uint256) public lastRequestTime;
    mapping(address => uint256) public requestCount;

    // Événements
    event RateLimitExceeded(address indexed user, uint256 timestamp);
    event RequestProcessed(address indexed user, uint256 timestamp);

    /// @notice Vérifie et met à jour les limites de requêtes pour un utilisateur
    /// @dev Réinitialise le compteur si la période est écoulée
    /// @param user Adresse de l'utilisateur à vérifier
    modifier checkRateLimit(address user) {
        if (block.timestamp >= lastRequestTime[user] + REQUEST_PERIOD) {
            requestCount[user] = 0;
            lastRequestTime[user] = block.timestamp;
        }

        require(requestCount[user] < REQUEST_LIMIT, "RateLimiter: Request limit exceeded");
        requestCount[user]++;

        emit RequestProcessed(user, block.timestamp);
        _;
    }

    /// @notice Calcule le nombre de requêtes restantes pour un utilisateur
    /// @dev Retourne la limite complète si la période est écoulée
    /// @param user Adresse de l'utilisateur
    /// @return uint256 Nombre de requêtes restantes
    function getRemainingRequests(address user) external view returns (uint256) {
        if (block.timestamp >= lastRequestTime[user] + REQUEST_PERIOD) {
            return REQUEST_LIMIT;
        }
        return REQUEST_LIMIT - requestCount[user];
    }

    /// @notice Calcule le temps restant avant la réinitialisation des requêtes
    /// @dev Retourne 0 si la période est déjà écoulée
    /// @param user Adresse de l'utilisateur
    /// @return uint256 Temps restant en secondes
    function getTimeUntilReset(address user) external view returns (uint256) {
        if (block.timestamp >= lastRequestTime[user] + REQUEST_PERIOD) {
            return 0;
        }
        return lastRequestTime[user] + REQUEST_PERIOD - block.timestamp;
    }

    /// @notice Réinitialise manuellement le compteur de requêtes
    /// @dev Accessible uniquement au propriétaire du contrat
    /// @param user Adresse de l'utilisateur à réinitialiser
    function resetRequestCount(address user) external onlyOwner {
        requestCount[user] = 0;
        lastRequestTime[user] = block.timestamp;
        emit RequestProcessed(user, block.timestamp);
    }
} 