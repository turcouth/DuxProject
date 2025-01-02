#!/bin/bash

# @title Script de compilation des circuits ZK
# @author DuxProject Team
# @notice Script pour compiler les circuits zk-SNARK et générer les fichiers nécessaires
# @dev Utilise circom et snarkjs pour la compilation et la génération des clés

# Définition des chemins
CIRCUIT_NAME="circuit"
BUILD_DIR="circuits/build"
CIRCUIT_PATH="circuits/${CIRCUIT_NAME}.circom"

# Création du répertoire de build s'il n'existe pas
echo "Création du répertoire de build..."
mkdir -p $BUILD_DIR

# Compilation du circuit avec circom
echo "Compilation du circuit ${CIRCUIT_NAME}..."
circom ${CIRCUIT_PATH} --r1cs --wasm --sym --c -o ${BUILD_DIR}

# Génération du fichier de contraintes
echo "Génération du fichier de contraintes..."
snarkjs r1cs info ${BUILD_DIR}/${CIRCUIT_NAME}.r1cs

# Configuration de la cérémonie Powers of Tau
echo "Configuration de la cérémonie Powers of Tau..."
snarkjs powersoftau new bn128 12 ${BUILD_DIR}/pot12_0000.ptau -v

# Contribution à la cérémonie
echo "Contribution à la cérémonie..."
snarkjs powersoftau contribute ${BUILD_DIR}/pot12_0000.ptau ${BUILD_DIR}/pot12_0001.ptau --name="First contribution" -v

# Préparation de la phase 2
echo "Préparation de la phase 2..."
snarkjs powersoftau prepare phase2 ${BUILD_DIR}/pot12_0001.ptau ${BUILD_DIR}/pot12_final.ptau -v

# Génération des clés de preuve
echo "Génération des clés de preuve..."
snarkjs groth16 setup ${BUILD_DIR}/${CIRCUIT_NAME}.r1cs ${BUILD_DIR}/pot12_final.ptau ${BUILD_DIR}/${CIRCUIT_NAME}_0000.zkey

# Contribution à la phase 2
echo "Contribution à la phase 2..."
snarkjs zkey contribute ${BUILD_DIR}/${CIRCUIT_NAME}_0000.zkey ${BUILD_DIR}/${CIRCUIT_NAME}_final.zkey --name="1st Contributor" -v

# Export de la clé de vérification
echo "Export de la clé de vérification..."
snarkjs zkey export verificationkey ${BUILD_DIR}/${CIRCUIT_NAME}_final.zkey ${BUILD_DIR}/verification_key.json

# Génération du contrat de vérification Solidity
echo "Génération du contrat de vérification Solidity..."
snarkjs zkey export solidityverifier ${BUILD_DIR}/${CIRCUIT_NAME}_final.zkey ${BUILD_DIR}/verifier.sol

echo "Compilation terminée avec succès!" 