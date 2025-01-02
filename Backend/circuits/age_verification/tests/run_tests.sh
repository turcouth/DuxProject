#!/bin/bash

# Couleurs pour le terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction pour exécuter un test
run_test() {
    local test_name=$1
    local test_data=$2
    
    echo "Exécution du test: $test_name"
    
    # Création du fichier input.json pour ce test
    echo "$test_data" > input.json
    
    # Génération du witness
    node ../age_check_js/generate_witness.js ../age_check_js/age_check.wasm input.json witness.wtns
    
    if [ $? -eq 0 ]; then
        # Génération de la preuve
        snarkjs groth16 prove ../age_check_0001.zkey witness.wtns proof.json public.json
        
        if [ $? -eq 0 ]; then
            # Vérification de la preuve
            if snarkjs groth16 verify ../verification_key.json public.json proof.json; then
                echo -e "${GREEN}✓ Test réussi : $test_name${NC}"
            else
                echo -e "${RED}✗ Test échoué : $test_name (vérification échouée)${NC}"
            fi
        else
            echo -e "${RED}✗ Test échoué : $test_name (génération de preuve échouée)${NC}"
        fi
    else
        echo -e "${RED}✗ Test échoué : $test_name (génération de witness échouée)${NC}"
    fi
    
    echo "----------------------------------------"
}

# Création du dossier de tests s'il n'existe pas
mkdir -p test_results

# Lecture du fichier de cas de test
TEST_CASES=$(cat test_cases.json)

# Exécution des tests de base
echo "=== Tests de Base ==="
for test in $(echo $TEST_CASES | jq -r '.basic_tests | keys[]'); do
    test_data=$(echo $TEST_CASES | jq -c ".basic_tests.$test")
    run_test "Test de base - $test" "$test_data"
done

# Exécution des cas limites
echo "=== Cas Limites ==="
for test in $(echo $TEST_CASES | jq -r '.edge_cases | keys[]'); do
    test_data=$(echo $TEST_CASES | jq -c ".edge_cases.$test")
    run_test "Cas limite - $test" "$test_data"
done

# Exécution des cas d'années bissextiles
echo "=== Tests Années Bissextiles ==="
for test in $(echo $TEST_CASES | jq -r '.leap_year_cases | keys[]'); do
    test_data=$(echo $TEST_CASES | jq -c ".leap_year_cases.$test")
    run_test "Année bissextile - $test" "$test_data"
done

# Exécution des tests de robustesse
echo "=== Tests de Robustesse ==="
for test in $(echo $TEST_CASES | jq -r '.robustness_tests | keys[]'); do
    test_data=$(echo $TEST_CASES | jq -c ".robustness_tests.$test")
    run_test "Test de robustesse - $test" "$test_data"
done

echo "Tous les tests sont terminés !" 