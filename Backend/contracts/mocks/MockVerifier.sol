// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IVerifier.sol";

/**
 * @title MockVerifier - Vérificateur simulé pour les tests
 * @author DuxProject Team
 * @notice Contrat simulant le comportement du vérificateur de preuves ZK
 * @dev Implémente l'interface IVerifier pour les tests d'intégration
 */
contract MockVerifier is IVerifier {
    bool private shouldVerify;
    
    /**
     * @notice Constructeur du mock vérificateur
     * @dev Initialise le comportement par défaut du vérificateur
     * @param _shouldVerify Détermine si le vérificateur doit valider ou rejeter les preuves
     */
    constructor(bool _shouldVerify) {
        shouldVerify = _shouldVerify;
    }

    /**
     * @notice Vérifie une preuve ZK simulée
     * @dev Retourne toujours la valeur définie dans shouldVerify
     * @param proof Les données de la preuve (non utilisées dans le mock)
     * @param input Les entrées publiques (non utilisées dans le mock)
     * @return bool Retourne shouldVerify, simulant la validation ou le rejet
     */
    function verifyProof(
        bytes memory proof,
        uint256[] memory input
    ) external view override returns (bool) {
        return shouldVerify;
    }

    /**
     * @notice Change le comportement du vérificateur
     * @dev Permet de modifier la réponse du vérificateur pour les tests
     * @param _shouldVerify Nouvelle valeur pour shouldVerify
     */
    function setShouldVerify(bool _shouldVerify) external {
        shouldVerify = _shouldVerify;
    }
} 