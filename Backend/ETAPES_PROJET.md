# Étapes du Projet

## Configuration Initiale
1. Création du projet Hardhat
2. Installation des dépendances de base
3. Configuration de Hardhat pour zkSync
4. Mise en place de la structure du projet

## Configuration des Tests
1. Configuration d'un environnement de test dual (ethers v5 et v6)
   - Création de `hardhat.test.config.js` pour les tests avec ethers v5
   - Conservation de `hardhat.config.js` pour zkSync avec ethers v6
   - Installation des dépendances spécifiques pour les tests
   - Configuration des scripts npm pour les deux environnements

2. Mise en place des tests unitaires
   - Création des tests pour le contrat Groth16Verifier
   - Vérification du déploiement du contrat
   - Tests fonctionnels à venir...

## Prochaines Étapes
1. Développement des tests complets pour le contrat Groth16Verifier
2. Implémentation des fonctionnalités de vérification d'âge
3. Tests d'intégration avec le circuit zk-SNARK
4. Déploiement sur le testnet zkSync Era 