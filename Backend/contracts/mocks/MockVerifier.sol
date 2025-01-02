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
     * @param _pA Premier élément de la preuve (point G1)
     * @param _pB Deuxième élément de la preuve (point G2)
     * @param _pC Troisième élément de la preuve (point G1)
     * @param _pubSignals Signaux publics de la preuve
     * @return bool Retourne shouldVerify, simulant la validation ou le rejet
     */
    function verifyProof(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
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