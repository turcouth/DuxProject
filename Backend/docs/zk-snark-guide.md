# Guide ZK-SNARK avec snarkjs et Circom

Ce guide explique en détail l'implémentation et l'utilisation des ZK-SNARKs (Zero-Knowledge Succinct Non-Interactive Argument of Knowledge) dans notre projet de vérification d'âge sur zkSync Era.

## Table des matières
- [Introduction aux ZK-SNARKs](#introduction-aux-zk-snarks)
- [Vue d'ensemble](#vue-densemble)
- [Structure du Circuit](#structure-du-circuit)
- [Processus de Setup](#processus-de-setup)
- [Génération de Preuve](#génération-de-preuve)
- [Vérification On-chain](#vérification-on-chain)
- [Sécurité et Considérations](#sécurité-et-considérations)
- [Optimisations sur zkSync Era](#optimisations-sur-zksync-era)

## Introduction aux ZK-SNARKs

Les ZK-SNARKs sont des preuves cryptographiques qui permettent à une partie (le prouveur) de prouver à une autre partie (le vérificateur) qu'une déclaration est vraie, sans révéler aucune information supplémentaire. Dans notre cas, nous l'utilisons pour prouver qu'une personne a plus de 18 ans sans révéler sa date de naissance exacte.

### Pourquoi utiliser les ZK-SNARKs ?
1. **Confidentialité** : Protection totale des données personnelles
2. **Efficacité** : Preuves compactes et vérification rapide
3. **Non-interactivité** : La preuve peut être vérifiée sans interaction avec le prouveur
4. **Scalabilité** : Particulièrement efficace sur les L2 comme zkSync Era

## Vue d'ensemble

Le processus complet de ZK-SNARK se décompose en plusieurs étapes clés :

1. **Compilation du circuit Circom**
   - Transformation de notre logique de vérification en circuit arithmétique
   - Génération des contraintes mathématiques

2. **Génération de la preuve**
   - Création d'une preuve cryptographique de la validité de notre déclaration
   - Utilisation des paramètres générés lors du setup

3. **Vérification de la preuve**
   - Vérification on-chain de la validité de la preuve
   - Exécution du contrat intelligent de vérification

## Structure du Circuit

Notre circuit de vérification d'âge est implémenté en Circom, un langage spécialisé pour les circuits arithmétiques :

```circom
pragma circom 2.1.4;

template AgeCheck() {
    // Entrées privées
    signal input birthTimestamp;    // Timestamp Unix de la date de naissance
    signal input currentTimestamp;  // Timestamp Unix actuel
    
    // Sortie publique
    signal output isAdult;         // Résultat booléen : true si >= 18 ans
    
    // Calcul de l'âge en secondes
    signal ageInSeconds;
    ageInSeconds <== currentTimestamp - birthTimestamp;
    
    // Vérification de l'âge (18 ans en secondes = 18 * 365 * 24 * 60 * 60)
    isAdult <== ageInSeconds >= 567648000;
}

component main = AgeCheck();
```

### Explication détaillée du circuit

1. **Signaux d'entrée (`signal input`)**
   - `birthTimestamp` : Timestamp Unix de la date de naissance (privé)
   - `currentTimestamp` : Timestamp Unix actuel (privé)
   - Ces valeurs restent confidentielles et ne sont jamais révélées

2. **Signal de sortie (`signal output`)**
   - `isAdult` : Booléen indiquant si la personne a 18 ans ou plus
   - C'est la seule information qui sera publique

3. **Contraintes arithmétiques**
   - Le circuit convertit la logique de vérification en équations mathématiques
   - L'opérateur `<==` crée des contraintes qui doivent être satisfaites
   - Chaque contrainte est vérifiée lors de la génération de la preuve

## Processus de Setup

Le "Trusted Setup" est une étape cruciale qui garantit la sécurité du système. Il se déroule en deux phases :

### Phase 1 : Powers of Tau
```javascript
// Génération des paramètres initiaux
await snarkjs.powersOfTau.new(12); // 2^12 contraintes max
await snarkjs.powersOfTau.contribute("pot12_0000.ptau");
```

Cette phase génère les paramètres cryptographiques de base qui seront utilisés pour toutes les preuves. Le nombre 12 indique que nous supportons jusqu'à 2^12 contraintes.

### Phase 2 : Circuit-Specific Setup
```javascript
// Génération des paramètres spécifiques au circuit
await snarkjs.zkey.new(r1csFile, ptauFile, zkeyFile);
await snarkjs.zkey.contribute(zkeyFile, finalZkeyFile);
```

Cette phase crée les paramètres spécifiques à notre circuit de vérification d'âge.

### Importance du Trusted Setup
- Les paramètres générés doivent être créés de manière sécurisée
- Si les nombres aléatoires utilisés sont compromis, des fausses preuves pourraient être créées
- La cérémonie multi-parties (MPC) permet de garantir la sécurité

## Génération de Preuve

La génération de preuve est le processus par lequel nous créons une preuve cryptographique de notre déclaration :

```javascript
// Préparation des inputs
const input = {
    birthTimestamp: Math.floor(Date.now() / 1000) - (20 * 365 * 24 * 60 * 60), // 20 ans
    currentTimestamp: Math.floor(Date.now() / 1000)
};

// Génération de la preuve
const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    input,                                                    // Inputs privés
    "circuits/age_verification/age_check_js/age_check.wasm", // Circuit compilé
    "circuits/age_verification/age_check_0001.zkey"          // Clé de preuve
);
```

### Anatomie d'une preuve

La preuve générée est composée de points sur des courbes elliptiques :
```javascript
proof = {
    // Point sur la courbe elliptique G1
    pi_a: [point_x, point_y],           
    
    // Points sur la courbe elliptique G2
    pi_b: [[point_x1, point_y1],        
           [point_x2, point_y2]],
           
    // Point sur la courbe elliptique G1
    pi_c: [point_x, point_y]            
}
```

### Préparation pour la vérification

Les données de preuve doivent être formatées pour le contrat Solidity :
```javascript
const proofData = [
    // Points A de la preuve (G1)
    proof.pi_a[0], proof.pi_a[1],           
    
    // Points B de la preuve (G2) - Noter l'inversion nécessaire
    [proof.pi_b[0][1], proof.pi_b[0][0]],   
    [proof.pi_b[1][1], proof.pi_b[1][0]],
    
    // Points C de la preuve (G1)
    proof.pi_c[0], proof.pi_c[1]            
];
```

## Vérification On-chain

La vérification de la preuve se fait dans un contrat intelligent :

```javascript
// Appel au contrat intelligent
const tx = await ageSBT.verifyAndMint(proofData, publicSignals);
```

### Processus de vérification
1. Le contrat reçoit la preuve et les signaux publics
2. Vérifie la validité mathématique de la preuve
3. Si la preuve est valide, exécute l'action demandée (mint du SBT)

## Sécurité et Considérations

### Confidentialité
- Les inputs privés (date de naissance) ne sont jamais exposés
- Seul le résultat de la vérification (isAdult) est public
- La preuve ne contient aucune information sur les données d'origine

### Vérifiabilité
- La preuve peut être vérifiée par n'importe qui
- La vérification est déterministe et rapide
- Impossible de falsifier une preuve valide

### Efficacité
- Taille de preuve constante (~300 bytes)
- Vérification rapide et peu coûteuse en gas
- Adapté aux contraintes des blockchains

### Sécurité
- Basé sur des hypothèses cryptographiques solides
- Résistant aux attaques quantiques connues
- Protocole Groth16 prouvé mathématiquement

## Optimisations sur zkSync Era

### 1. Protocole Groth16
- **Efficacité en gas** : Optimisé pour les opérations on-chain
- **Preuves compactes** : Minimise les coûts de stockage
- **Vérification rapide** : Réduit les coûts de calcul

### 2. Avantages Layer 2
- **Scalabilité** : Traitement de nombreuses preuves
- **Coûts réduits** : Frais de transaction minimisés
- **Rapidité** : Confirmation rapide des transactions

### 3. Intégration snarkjs
- **Compatibilité** : Fonctionne nativement avec Ethereum
- **Maintenance** : Mises à jour régulières
- **Support** : Documentation et communauté actives

## Commandes Utiles

### Setup et compilation
```bash
# 1. Compilation du circuit
# Génère les fichiers nécessaires pour la génération de preuves
circom age_check.circom --r1cs --wasm --sym

# 2. Setup Powers of Tau
# Initialise les paramètres cryptographiques de base
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution"

# 3. Préparation Phase 2
# Finalise les paramètres de base
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# 4. Setup de la preuve
# Génère les paramètres spécifiques au circuit
snarkjs groth16 setup age_check.r1cs pot12_final.ptau age_check_0000.zkey
snarkjs zkey contribute age_check_0000.zkey age_check_0001.zkey --name="First contribution"

# 5. Export de la clé de vérification
# Génère la clé pour la vérification on-chain
snarkjs zkey export verificationkey age_check_0001.zkey verification_key.json
```

## Conclusion

L'utilisation de snarkjs avec Circom pour les ZK-SNARKs offre :

### Avantages techniques
- Preuves cryptographiques robustes
- Vérification efficace et rapide
- Intégration native avec Ethereum

### Bénéfices pour l'application
- Protection totale de la vie privée
- Expérience utilisateur fluide
- Coûts optimisés sur L2

### Perspectives futures
- Extensible à d'autres cas d'usage
- Compatible avec les évolutions d'Ethereum
- Adaptable aux nouveaux besoins de confidentialité 