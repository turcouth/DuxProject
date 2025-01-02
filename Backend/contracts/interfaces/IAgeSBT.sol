// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IAgeSBT - Interface du contrat de vérification d'âge
/// @author DuxProject Team
/// @notice Interface définissant les fonctionnalités principales du système de vérification d'âge
/// @dev Interface pour l'interaction avec le contrat AgeSBT
interface IAgeSBT {
    /// @notice Émis lors de la création d'un nouveau SBT
    /// @param to Adresse recevant le SBT
    /// @param tokenId Identifiant unique du token
    event AgeSBTMinted(address indexed to, uint256 tokenId);
    
    /// @notice Émis lors de la vérification d'âge d'un utilisateur
    /// @param user Adresse de l'utilisateur vérifié
    /// @param timestamp Horodatage de la vérification
    event AgeVerified(address indexed user, uint256 timestamp);

    /// @notice Crée un nouveau SBT pour un utilisateur vérifié
    /// @dev Ne peut être appelé que pour les utilisateurs ayant passé la vérification
    /// @param to Adresse de l'utilisateur recevant le SBT
    /// @return uint256 Identifiant du nouveau token créé
    function mint(address to) external returns (uint256);

    /// @notice Vérifie le statut de vérification d'âge d'une adresse
    /// @dev Consulte le mapping des adresses vérifiées
    /// @param user Adresse à vérifier
    /// @return bool Vrai si l'adresse est vérifiée, faux sinon
    function verifyAge(address user) external view returns (bool);
} 