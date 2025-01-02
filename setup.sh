#!/bin/bash

# Script de configuration pour le projet DuxProject
# Ce script installe et configure tous les outils nécessaires pour le développement

echo "🚀 Début de l'installation..."

# 0. Vérification et installation des dépendances de base
echo "📦 Vérification des dépendances de base..."
if ! command -v brew &> /dev/null; then
    echo "Installation de Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v node &> /dev/null; then
    echo "Installation de Node.js..."
    brew install node
fi

if ! command -v cargo &> /dev/null; then
    echo "Installation de Rust et Cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
fi

# 1. Configuration du projet
echo "🏗️ Configuration du projet..."
mkdir -p DuxProject
cd DuxProject
npm init -y

# 2. Installation des dépendances Node.js
echo "📦 Installation des dépendances Node.js..."
npm install --save-dev hardhat @matterlabs/hardhat-zksync-solc @matterlabs/hardhat-zksync-deploy ethers zksync-web3 dotenv

# 3. Installation de zksolc pour macOS ARM64
echo "📥 Téléchargement de zksolc..."
curl -LJO https://github.com/matter-labs/zksolc-bin/releases/download/v1.5.8/zksolc-macosx-arm64-v1.5.8
chmod +x zksolc-macosx-arm64-v1.5.8

# 4. Installation de circom depuis le code source
echo "📥 Installation de circom..."
rm -rf circom
git clone https://github.com/iden3/circom.git
cd circom
cargo build --release

# 5. Ajout de circom au PATH
echo "🔧 Configuration du PATH..."
export PATH=$PATH:$(pwd)/target/release
echo 'export PATH=$PATH:~/circom/target/release' >> ~/.zshrc
source ~/.zshrc

# 6. Création de la structure du projet
echo "📁 Création de la structure du projet..."
cd ..
mkdir -p backend/circuits/age_verification
mkdir -p backend/contracts
mkdir -p backend/scripts
mkdir -p backend/test

# 7. Création du fichier de configuration Hardhat
echo "📝 Création du fichier hardhat.config.js..."
cat > backend/hardhat.config.js << 'EOL'
require("@matterlabs/hardhat-zksync-deploy");
require("@matterlabs/hardhat-zksync-solc");
require("dotenv").config();

module.exports = {
    zksolc: {
        version: "1.5.8",
        compilerSource: "binary",
        settings: {
            optimizer: {
                enabled: true,
                mode: "3"
            }
        },
    },
    defaultNetwork: "zkSyncSepoliaTestnet",
    networks: {
        zkSyncSepoliaTestnet: {
            url: "https://sepolia.era.zksync.dev",
            ethNetwork: "sepolia",
            zksync: true,
            verifyURL: 'https://explorer.sepolia.era.zksync.dev/contract_verification',
            accounts: [process.env.PRIVATE_KEY],
        },
    },
    solidity: {
        version: "0.8.28",
    },
};
EOL

# 8. Création du fichier .env
echo "📝 Création du fichier .env..."
cat > backend/.env << 'EOL'
PRIVATE_KEY=votre_clé_privée_ici
EOL

# 9. Installation de circomlib
echo "📦 Installation de circomlib..."
cd backend
npm install circomlib --save-dev --legacy-peer-deps

# 10. Compilation du circuit
echo "🔨 Compilation du circuit..."
cd circuits/age_verification
../../../circom/target/release/circom age_check.circom --r1cs --wasm --sym

echo "✅ Installation terminée !"
echo "
Les fichiers suivants ont été générés :
- age_check.r1cs : contraintes arithmétiques
- age_check.sym : symboles pour le débogage
- age_check_js/age_check.wasm : circuit compilé en WebAssembly

⚠️ N'oubliez pas de :
1. Configurer votre clé privée dans le fichier backend/.env
2. Installer les dépendances supplémentaires si nécessaire avec npm install
3. Vérifier que tous les chemins sont corrects pour votre environnement
" 