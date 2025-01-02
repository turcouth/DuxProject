#!/bin/bash

# 1. Installation des dépendances nécessaires
# Assurez-vous d'avoir installé :
# - Node.js et npm
# - circom 2.1.4 (via cargo)
# - snarkjs (via npm)
# - jq (pour les tests)

# 2. Compilation du circuit
echo "Compilation du circuit..."
circom age_check.circom --r1cs --wasm --sym

# 3. Setup Powers of Tau
echo "Initialisation des Powers of Tau..."
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

# 4. Contribution à la cérémonie
echo "Contribution à la cérémonie..."
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="Première contribution" -v -e="random text for entropy"

# 5. Préparation de la Phase 2
echo "Préparation de la Phase 2..."
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# 6. Setup de la preuve
echo "Setup de la preuve..."
snarkjs groth16 setup age_check.r1cs pot12_final.ptau age_check_0000.zkey

# 7. Contribution à la clé
echo "Contribution à la clé..."
snarkjs zkey contribute age_check_0000.zkey age_check_0001.zkey --name="Première contribution" -e="random text"

# 8. Export de la clé de vérification
echo "Export de la clé de vérification..."
snarkjs zkey export verificationkey age_check_0001.zkey verification_key.json

# 9. Création du dossier de tests
echo "Création du dossier de tests..."
mkdir -p tests
cp test_cases.json tests/
cp run_tests.sh tests/
chmod +x tests/run_tests.sh

# 10. Génération du contrat de vérification Solidity
echo "Génération du contrat de vérification..."
snarkjs zkey export solidityverifier age_check_0001.zkey verifier.sol

# 11. Exécution des tests
echo "Exécution des tests..."
cd tests && ./run_tests.sh

echo "Setup terminé ! Vérifiez que tous les fichiers ont été générés correctement :"
echo "- age_check.r1cs : Représentation du circuit"
echo "- age_check_js/ : Dossier contenant le code JavaScript"
echo "- age_check_0001.zkey : Clé de preuve"
echo "- verification_key.json : Clé de vérification"
echo "- verifier.sol : Contrat de vérification Solidity"
echo "- tests/ : Dossier contenant les tests" 