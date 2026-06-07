#!/bin/bash
# Script de test automatique pour le projet TPC
# Ce script teste l'analyseur syntaxique avec des fichiers valides et invalides

EXEC="./bin/tpcas"
GOOD_DIR="test/good"
ERR_DIR="test/syn-err"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
total_tests=0
passed_tests=0
failed_tests=0

echo "======================================"
echo "   Tests du compilateur TPC"
echo "======================================"
echo ""

# Vérifier que l'exécutable existe
if [ ! -f "$EXEC" ]; then
    echo -e "${RED}Erreur: L'exécutable $EXEC n'existe pas${NC}"
    echo "Veuillez d'abord compiler le projet avec 'make'"
    exit 1
fi

# Afficher la version du compilateur
echo -e "${BLUE}Compilateur:${NC} $EXEC"
echo ""

# Tests sur programmes corrects
echo -e "${BLUE}=== Tests sur programmes corrects ===${NC}"
if [ -d "$GOOD_DIR" ]; then
    good_count=0
    for file in "$GOOD_DIR"/*.tpc; do
        if [ -f "$file" ]; then
            total_tests=$((total_tests + 1))
            good_count=$((good_count + 1))
            printf "%-40s " "Test: $(basename $file)"

            # Capture de la sortie pour debug si nécessaire
            output=$($EXEC < "$file" 2>&1)
            ret=$?

            if [ $ret -eq 0 ]; then
                echo -e "${GREEN}✓ PASS${NC}"
                passed_tests=$((passed_tests + 1))
            else
                echo -e "${RED}✗ FAIL (code de retour: $ret)${NC}"
                if [ -n "$VERBOSE" ]; then
                    echo "$output" | head -3
                fi
                failed_tests=$((failed_tests + 1))
            fi
        fi
    done
    if [ $good_count -eq 0 ]; then
        echo -e "${YELLOW}Aucun fichier de test trouvé dans $GOOD_DIR${NC}"
    fi
else
    echo -e "${YELLOW}Le dossier $GOOD_DIR n'existe pas${NC}"
fi

echo ""

# Tests sur programmes avec erreurs
echo -e "${BLUE}=== Tests sur programmes avec erreurs ===${NC}"
if [ -d "$ERR_DIR" ]; then
    err_count=0
    for file in "$ERR_DIR"/*.tpc; do
        if [ -f "$file" ]; then
            total_tests=$((total_tests + 1))
            err_count=$((err_count + 1))
            printf "%-40s " "Test: $(basename $file)"

            output=$($EXEC < "$file" 2>&1)
            ret=$?

            # Le compilateur doit retourner 1 pour une erreur syntaxique
            if [ $ret -eq 1 ]; then
                echo -e "${GREEN}✓ PASS (erreur détectée)${NC}"
                passed_tests=$((passed_tests + 1))
            else
                echo -e "${RED}✗ FAIL (code: $ret, erreur non détectée)${NC}"
                if [ -n "$VERBOSE" ]; then
                    echo "$output" | head -3
                fi
                failed_tests=$((failed_tests + 1))
            fi
        fi
    done
    if [ $err_count -eq 0 ]; then
        echo -e "${YELLOW}Aucun fichier de test trouvé dans $ERR_DIR${NC}"
    fi
else
    echo -e "${YELLOW}Le dossier $ERR_DIR n'existe pas${NC}"
fi

echo ""
echo "======================================"
echo "   Résultats des tests"
echo "======================================"
echo "Total:   $total_tests tests"
echo -e "${GREEN}Réussis: $passed_tests${NC}"
echo -e "${RED}Échoués: $failed_tests${NC}"

if [ $total_tests -gt 0 ]; then
    score=$((passed_tests * 100 / total_tests))
    echo "Score:   $score%"
    echo ""
    if [ $failed_tests -eq 0 ]; then
        echo -e "${GREEN}✓ Tous les tests sont passés avec succès!${NC}"
    else
        echo -e "${RED}✗ Certains tests ont échoué.${NC}"
        echo -e "${YELLOW}Conseil: Utilisez VERBOSE=1 ./test.sh pour voir les erreurs détaillées${NC}"
    fi
else
    echo -e "${YELLOW}Aucun test n'a été exécuté.${NC}"
fi

echo ""

# Code de retour
if [ $failed_tests -eq 0 ] && [ $total_tests -gt 0 ]; then
    exit 0
else
    exit 1
fi
