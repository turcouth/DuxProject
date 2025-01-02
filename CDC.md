# Cahier des Charges DUXPROJET

## 1. Introduction
Je dois développer un site en web3 pour pouvoir répondre à une demande du gouvernement.

## 2. Contexte
Il y a actuellement des sites interdits aux personnes qui ont moins de 18 ans, moins 16 ans, moins 21 ans, moins 12 ans, moins 25 ans, etc...
Le gouvernement demande à ces différents sites de trouver une solution pour valider que les personnes ont bien l'âge requis pour accéder à leur site.
La solution doit être indépendante de leur entreprise et doit être réalisée par une entreprise tierce.
Cette entreprise tierce doit mettre en place un système de vérification d'âge répondant aux normes RGPD.

## 3. Objectifs
L'objectif est le suivant :
- Le site doit être en web3
- Le site doit pouvoir enregistrer les données des personnes qui sont les suivantes :
    - La date de naissance de la personne
    - L'adresse de son metamask
- Le site doit être en mode gratuit, les personnes se connectent avec leur metamask et doivent :
    - Se connecter
    - Se créer un SBT qui validera leur âge et ce SBT sera vérifiable par les sites ayant besoin de valider l'âge des personnes.
    
Comment cela doit se faire :
1. La personne doit passer un KYC pour valider ses informations
2. L'information liée à la date de naissance de la personne devra être stockée dans un ZPK (zk-snarks)
3. Le SBT contiendra une méthode de vérification de l'âge de la personne et on devra passer en paramètre :
    - La date courante
    - L'âge minimum requis
    Et devra retourner un booléen

4. Le SBT est récupéré par la personne et doit être vérifiable par le site qui a besoin de valider l'âge des personnes
5. La personne se connecte à un site demandant la vérification de l'âge et le site doit vérifier le SBT et si le SBT renvoie true, le site pourra accéder à la personne et si il renvoie false, le site ne pourra pas accéder à la personne.

## 4. Contraintes
- Le site doit être en mode gratuit
- La vérification d'âge doit être faite par le site qui a besoin de valider l'âge des personnes
- La vérification d'âge doit être payante

## 5. Fonctionnalités
- La personne doit pouvoir se créer un SBT
- La personne doit pouvoir se connecter avec son metamask
- La personne doit récupérer le SBT
- Le site doit pouvoir enregistrer la date de naissance de la personne en suivant les normes RGPD mode zk-snarks
- Le site doit pouvoir transférer le SBT à la personne
- Les sites qui ont besoin de valider l'âge des personnes doivent pouvoir vérifier le SBT

## 6. Architecture
- Composants :
    - backend :
        - Il doit être composé de :
            - Un smart contract qui permet de créer un SBT
            - Un smart contract qui permet de vérifier le ZK-SNARKS
            - Un smart contract qui permet de récupérer la fonction de vérification 'proof' du zk-snarks qui sera appelée dans le SBT
        - Ils doivent être en mode décentralisé (blockchain) sur ZkSync

    - frontend :
        - Le site doit être créé avec Next.js et react.js
        - Le site doit être en mode décentralisé (blockchain) sur vercel
        - Le site doit interagir avec le backend
        - Le site doit permettre à la personne de se créer un SBT
        - Le site doit permettre à la personne de se connecter avec son metamask
        - Le site doit permettre à la personne de récupérer le SBT
        - Le site doit permettre à la personne de se déconnecter

## 7. Technologies
- Le backend doit être en mode solidity, zk-snarks, zkSync, circom, zksnarks-js
- Le frontend doit être en mode react, next.js, tailwindcss, shadcn/ui

## 8. Planification
- 1) Créer le backend
- 2) Créer le ZK-SNARKS avec circom pour la vérification de l'âge
    - 2.1) Créer le smart contract qui permet de créer un SBT
    - 2.2) Créer le smart contract qui permet de vérifier le ZK-SNARKS
    - 2.3) Créer le smart contract qui permet de récupérer la fonction de vérification 'proof' du zk-snarks qui sera appelée dans le SBT
- 3) Créer le frontend
- 4) Créer le site