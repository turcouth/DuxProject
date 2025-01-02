# Tests de Vérification d'Âge

Ce dossier contient les tests pour notre circuit de vérification d'âge. Voici les détails des timestamps utilisés dans nos tests :

## Tests de Base
### Personne Majeure
- Date de naissance : 2000-01-01 (946684800)
- Date actuelle : 2023-12-29 (1703862000)
- Âge : 23 ans
- Résultat attendu : 1 (majeur)

### Personne Mineure
- Date de naissance : 2004-01-01 (1072915200)
- Date actuelle : 2023-12-29 (1703862000)
- Âge : 15 ans
- Résultat attendu : 0 (mineur)

## Cas Limites
### Exactement 18 ans
- Date de naissance : 2006-01-01 (1136073600)
- Date actuelle : 2023-12-29 (1703862000)
- Âge : 18 ans
- Résultat attendu : 1 (majeur)

### Presque 18 ans
- Date de naissance : 2006-01-02 (1136160000)
- Date actuelle : 2023-12-29 (1703862000)
- Âge : 17 ans et 364 jours
- Résultat attendu : 0 (mineur)

## Cas Spéciaux
### Né un 29 février (année bissextile)
- Date de naissance : 2000-02-29 (951782400)
- Date actuelle : 2023-12-29 (1703862000)
- Âge : 23 ans
- Résultat attendu : 1 (majeur)

### Personne très âgée
- Date de naissance : 1920-01-01 (-1577923200)
- Date actuelle : 2023-12-29 (1703862000)
- Âge : 103 ans
- Résultat attendu : 1 (majeur)

## Notes sur les Tests
- Tous les timestamps sont en secondes depuis l'époque Unix (1970-01-01)
- L'âge minimum est fixé à 18 ans (567648000 secondes)
- La date actuelle est fixée au 29 décembre 2023 pour tous les tests
- Les tests couvrent les cas normaux, limites et spéciaux 