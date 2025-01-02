# DuxProject - Vérification d'Âge Privée avec ZK-SNARKs

## 🎯 Vue d'ensemble

DuxProject est une solution innovante de vérification d'âge utilisant les Zero-Knowledge Proofs (ZKP) sur zkSync Era. Le projet permet aux utilisateurs de prouver qu'ils ont plus de 18 ans sans révéler leur date de naissance exacte, garantissant ainsi la confidentialité tout en assurant la conformité.

## 🔑 Caractéristiques Principales

- **Confidentialité Totale** : Vérification d'âge sans divulgation de données personnelles
- **Sécurité Renforcée** : Utilisation de ZK-SNARKs pour des preuves cryptographiques robustes
- **Optimisation L2** : Déployé sur zkSync Era pour des coûts réduits et une meilleure scalabilité
- **Non-Transférable** : Implémentation SBT (Soulbound Token) pour lier l'identité
- **Architecture Modulaire** : Design flexible et extensible

## 🏗️ Architecture

### Smart Contracts
- `AgeSBT.sol` : Token non-transférable pour la preuve d'âge
- `AgeVerificationManager.sol` : Gestion des vérifications
- `FeeManager.sol` : Gestion des frais de service
- `RateLimiter.sol` : Protection contre les abus
- `Groth16Verifier.sol` : Vérification des ZK-proofs

### Circuit ZK-SNARK
Le circuit `age_check.circom` vérifie que :
```circom
template AgeCheck() {
    signal input birthTimestamp;
    signal input currentTimestamp;
    signal output isAdult;
    
    // Vérification : âge >= 18 ans
    signal ageInSeconds;
    ageInSeconds <== currentTimestamp - birthTimestamp;
    isAdult <== ageInSeconds >= 567648000; // 18 ans en secondes
}
```

## 🚀 Installation

1. **Prérequis**
```bash
node >= 16.0.0
npm >= 7.0.0
circom >= 2.1.4
```

2. **Installation des dépendances**
```bash
cd backend
npm install
```

3. **Compilation du circuit**
```bash
./compile_circuit.sh
```

4. **Configuration**
```bash
cp .env.example .env
# Configurer les variables d'environnement
```

## 💻 Utilisation

### Génération d'une preuve
```javascript
const input = {
    birthTimestamp: // timestamp de naissance,
    currentTimestamp: Math.floor(Date.now() / 1000)
};

const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    input,
    "circuits/age_verification/age_check_js/age_check.wasm",
    "circuits/age_verification/age_check_0001.zkey"
);
```

### Vérification et Mint
```javascript
const tx = await ageSBT.verifyAndMint(proofData, publicSignals);
await tx.wait();
```

## 🔒 Sécurité

### Mesures de Protection
- Vérification cryptographique robuste
- Rate limiting pour prévenir les abus
- Contrôles d'accès stricts
- Tests de sécurité approfondis

### Audit et Tests
- Tests unitaires complets
- Tests d'intégration
- Vérification formelle des circuits

## 📚 Documentation

Documentation détaillée disponible dans le dossier `docs/` :
- [Guide ZK-SNARK](backend/docs/zk-snark-guide.md)
- [Guide de Déploiement](backend/Setup.md)
- [Journal des Étapes](ETAPES_PROJET.md)

## 🛣️ Roadmap

### Phase 1 ✅
- [x] Développement des smart contracts
- [x] Implémentation du circuit ZK-SNARK
- [x] Tests et déploiement sur testnet
- [x] Documentation technique

### Phase 2 🔄
- [ ] Interface utilisateur
- [ ] Tests d'intégration
- [ ] Audit de sécurité
- [ ] Optimisations gas

### Phase 3 📋
- [ ] Déploiement mainnet
- [ ] Support multi-langues
- [ ] Analytics et monitoring
- [ ] Extensions fonctionnelles

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :
1. Forkez le projet
2. Créez une branche pour votre fonctionnalité
3. Committez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Contact

- GitHub : [@turcouth](https://github.com/turcouth)
- Email : [contact@tcouture.fr]

## 🙏 Remerciements

- Équipe zkSync Era
- Communauté Circom
- Contributeurs OpenZeppelin 