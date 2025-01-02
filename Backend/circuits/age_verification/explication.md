# Système de Vérification d'Âge Privé avec zk-SNARK

## Introduction Simple
Imaginez que vous devez prouver que vous avez plus de 18 ans pour accéder à un service, mais que vous ne voulez pas révéler votre date de naissance exacte. C'est exactement ce que notre système permet de faire ! C'est comme montrer votre carte d'identité à un videur de boîte de nuit, mais en ne lui montrant que la confirmation "Oui, cette personne est majeure" sans révéler votre âge exact.

## Qu'est-ce qu'un zk-SNARK ?
Un zk-SNARK (Zero-Knowledge Succinct Non-Interactive Argument of Knowledge) est comme une boîte magique qui permet de prouver quelque chose sans révéler les détails. Par exemple :
- Vous pouvez prouver que vous connaissez le code d'un coffre-fort sans révéler le code
- Vous pouvez prouver que vous avez assez d'argent sur votre compte sans montrer votre solde exact
- Dans notre cas : prouver que vous êtes majeur sans révéler votre date de naissance

## Notre Circuit de Vérification d'Âge

### 1. Le Circuit (age_check.circom)
Notre circuit est comme une recette de cuisine qui explique comment vérifier l'âge :
- Ingrédients (entrées) :
  * Date de naissance (privée)
  * Date actuelle (publique)
  * Âge minimum requis (public)
- Résultat (sortie) :
  * Un simple "oui" (1) ou "non" (0) indiquant si la personne est majeure

### 2. Les Étapes de Configuration

#### Étape 1 : Compilation du Circuit
```bash
circom age_check.circom --r1cs --wasm --sym
```
Cette commande transforme notre "recette" en langage que l'ordinateur peut comprendre. C'est comme traduire une recette de cuisine en instructions précises pour un robot cuisinier.

#### Étape 2 : Génération du Witness
```bash
node age_check_js/generate_witness.js age_check_js/age_check.wasm input.json witness.wtns
```
Cette étape prend nos "ingrédients" (les dates) et les utilise dans la recette. C'est comme préparer tous les ingrédients avant de cuisiner.

#### Étape 3 : Setup de la Preuve
```bash
snarkjs groth16 setup age_check.r1cs pot12_final.ptau age_check_0000.zkey
```
Cette étape crée les "outils spéciaux" nécessaires pour créer et vérifier les preuves. C'est comme préparer tous les ustensiles nécessaires pour la recette.

#### Étape 4 : Contribution à la Cérémonie
```bash
snarkjs zkey contribute age_check_0000.zkey age_check_0001.zkey --name="Première contribution"
```
Cette étape ajoute de l'aléatoire pour rendre le système plus sûr. C'est comme ajouter un ingrédient secret que personne ne connaît complètement.

#### Étape 5 : Création des Clés de Vérification
```bash
snarkjs zkey export verificationkey age_check_0001.zkey verification_key.json
```
Crée les outils qui permettront de vérifier les preuves plus tard. C'est comme créer une check-list pour vérifier que la recette a été bien suivie.

#### Étape 6 : Génération de la Preuve
```bash
snarkjs groth16 prove age_check_0001.zkey witness.wtns proof.json public.json
```
Crée la preuve que quelqu'un est majeur. C'est comme obtenir un certificat qui prouve que vous avez bien suivi la recette.

#### Étape 7 : Vérification de la Preuve
```bash
snarkjs groth16 verify verification_key.json public.json proof.json
```
Vérifie que la preuve est valide. C'est comme vérifier que le plat final correspond bien à la recette.

#### Étape 8 : Création du Contrat de Vérification
```bash
snarkjs zkey export solidityverifier age_check_0001.zkey verifier.sol
```
Crée un programme qui pourra vérifier les preuves sur la blockchain. C'est comme créer un guide qui permet à n'importe qui de vérifier que la recette a été bien suivie.

## Pourquoi C'est Sécurisé ?
- Personne ne peut tricher car les mathématiques derrière le système sont très solides
- La date de naissance reste complètement privée
- Les preuves sont impossibles à falsifier
- Chaque preuve est unique et ne peut pas être réutilisée

## Avantages du Système
1. Protection de la Vie Privée : Seul le résultat (majeur/non majeur) est visible
2. Sécurité : Impossible de créer de fausses preuves
3. Efficacité : La vérification est rapide et peu coûteuse
4. Transparence : Tout le monde peut vérifier la validité d'une preuve

## Conclusion
Notre système permet de prouver son âge de manière moderne et sécurisée, tout en protégeant la vie privée. C'est comme avoir une carte d'identité magique qui ne montre que ce qui est strictement nécessaire ! 