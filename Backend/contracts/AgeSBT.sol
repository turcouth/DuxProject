// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./managers/FeeManager.sol";
import "./managers/RateLimiter.sol";
import "./managers/AgeVerificationManager.sol";
import "./security/SecurityManager.sol";
import "./security/AccessController.sol";
import "./security/TokenGuard.sol";
import "./security/ProofValidator.sol";
import "./Groth16Verifier.sol";

/// @title AgeSBT - Contrat de vérification d'âge utilisant des SoulBound Tokens
/// @author DuxProject Team
/// @notice Ce contrat permet la vérification d'âge via des preuves à connaissance nulle
/// @dev Implémente un système de jetons non-transférables (SBT) avec vérification ZK
contract AgeSBT is 
    ERC721,
    ERC721Burnable,
    ReentrancyGuard,
    AgeVerificationManager,
    ProofValidator,
    SecurityManager,
    AccessController,
    TokenGuard,
    RateLimiter,
    FeeManager
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /// @notice Initialise le contrat AgeSBT
    /// @dev Configure les paramètres initiaux pour la vérification et la gestion des frais
    /// @param _verifier Adresse du contrat de vérification
    /// @param _verificationFee Montant des frais de vérification
    /// @param _feeReceiver Adresse recevant les frais
    constructor(
        address _verifier,
        uint256 _verificationFee,
        address _feeReceiver
    ) 
        ERC721("Age Verification SBT", "AVSBT")
        FeeManager(_verificationFee, _feeReceiver)
        AgeVerificationManager(_verifier)
        SecurityManager()
        AccessController()
        TokenGuard()
        ProofValidator()
    {
    }

    /// @notice Valide une preuve ZK
    /// @dev Vérifie la validité temporelle et l'unicité de la preuve
    /// @param a Premier élément de la preuve Groth16
    /// @param b Deuxième élément de la preuve Groth16
    /// @param c Troisième élément de la preuve Groth16
    /// @param input Signaux publics [isAdult, currentTimestamp, minAgeInSeconds]
    /// @return bytes32 Hash de la preuve
    function validateProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) internal returns (bytes32) {
        require(
            input[1] <= block.timestamp + PROOF_VALIDITY_PERIOD &&
            input[1] >= block.timestamp - PROOF_VALIDITY_PERIOD,
            "AgeSBT: Proof timestamp out of range"
        );
        
        bytes32 proofHash = keccak256(abi.encodePacked(a, b, c, input));
        require(!usedProofs[proofHash], "AgeSBT: Proof already used");
        
        require(validateProofUniqueness(a, b, c, input), "AgeSBT: Proof uniqueness check failed");
        require(validatePublicSignals(input), "AgeSBT: Public signals validation failed");
        
        AgeVerificationManager.verifyProof(a, b, c, input, msg.sender);
        
        return proofHash;
    }

    /// @notice Vérifie la preuve et mint un SBT
    /// @dev Combine la vérification de la preuve et le minting du token
    /// @param to Adresse recevant le SBT
    /// @param a Premier élément de la preuve
    /// @param b Deuxième élément de la preuve
    /// @param c Troisième élément de la preuve
    /// @param input Signaux publics
    function verifyAndMint(
        address to,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) external whenNotPaused nonReentrant checkRateLimit(to) {
        bytes32 proofHash = validateProof(a, b, c, input);
        
        usedProofs[proofHash] = true;
        
        require(!isVerified(to), "AgeSBT: Address already verified");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(to, newTokenId);
        
        setVerified(to);
        
        emit TokenMinted(to, newTokenId);
        emit AgeVerified(to, block.timestamp);
    }

    /// @notice Vérifie l'identité d'un utilisateur
    /// @dev Vérifie la preuve et gère le paiement
    /// @param user Adresse de l'utilisateur à vérifier
    /// @param a Premier élément de la preuve
    /// @param b Deuxième élément de la preuve
    /// @param c Troisième élément de la preuve
    /// @param input Signaux publics
    function verifyIdentity(
        address user,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) external payable whenNotPaused nonReentrant checkRateLimit(user) {
        validatePayment();
        
        bytes32 proofHash = validateProof(a, b, c, input);
        
        usedProofs[proofHash] = true;
        
        processPayment();
        
        emit VerificationPaid(msg.sender, user, msg.value);
    }

    /// @notice Vérifie avant le transfert de token
    /// @dev Empêche le transfert des SBT (sauf mint et burn)
    /// @param from Adresse source
    /// @param to Adresse destination
    /// @param tokenId ID du token
    /// @param batchSize Taille du lot pour les transferts multiples
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, TokenGuard) whenNotPaused {
        require(from == address(0) || to == address(0), "AgeSBT: Token transfer is not allowed");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
} 