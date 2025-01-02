# Configuration du Projet

## Prérequis
- Node.js (v16 ou supérieur)
- npm (v7 ou supérieur)
- Git

## Installation

1. Cloner le repository :
```bash
git clone [URL_DU_REPO]
cd backend
```

2. Installer les dépendances :
```bash
npm install
```

## Configuration de l'Environnement

1. Créer un fichier `.env` à la racine du projet :
```bash
cp .env.example .env
```

2. Remplir les variables d'environnement dans `.env` :
```
PRIVATE_KEY=votre_clé_privée
```

## Structure des Tests

Le projet utilise une configuration duale pour les tests :
- ethers v5 pour les tests unitaires standards
- ethers v6 pour les tests liés à zkSync

### Scripts de Test Disponibles

- Tests avec ethers v5 (recommandé pour les tests unitaires) :
```bash
npm test
```

- Tests avec ethers v6 (pour les tests spécifiques à zkSync) :
```bash
npm run test:v6
```

### Compilation des Contrats

Pour compiler les contrats :
```bash
npm run compile
```

## Structure du Projet

```
backend/
├── contracts/          # Contrats Solidity
├── tests/             # Tests des contrats
├── scripts/           # Scripts de déploiement
├── hardhat.config.js  # Configuration principale (ethers v6 + zkSync)
└── hardhat.test.config.js  # Configuration de test (ethers v5)
```

## Notes Importantes

1. La configuration principale (`hardhat.config.js`) est optimisée pour zkSync et utilise ethers v6
2. La configuration de test (`hardhat.test.config.js`) utilise ethers v5 pour une meilleure compatibilité avec les tests
3. Les tests doivent être écrits en tenant compte de la version d'ethers utilisée 