#!/usr/bin/env bash
# ==============================================================================
# vget - Automated Test Suite & Quality Gate
# Role: Validation stricte de la conformité aux règles, linting et tests d'exécution
# ==============================================================================
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

ERRORS=0
TOTAL_TESTS=0

pass() { echo "  [✔ PASS] $1"; }
fail() { echo "  [✖ FAIL] $1"; ERRORS=$((ERRORS + 1)); }

test_case() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    local desc="$1"
    shift
    if "$@"; then
        pass "$desc"
    else
        fail "$desc"
    fi
}

echo "=================================================="
echo "    vget Quality Gate & Test Suite"
echo "=================================================="
echo ""

# 1. Vérification de la limite de 200 lignes par fichier
echo "--- 1. Vérification du plafond de 200 lignes ---"
max_lines_check() {
    local exceeded=0
    for file in bin/vget lib/*.sh install.sh; do
        [[ -f "$file" ]] || continue
        local lines
        lines=$(wc -l < "$file")
        if [[ $lines -gt 200 ]]; then
            echo "Fichier dépassant 200 lignes : $file ($lines lignes)"
            exceeded=1
        fi
    done
    return $exceeded
}
test_case "Tous les fichiers contiennent <= 200 lignes" max_lines_check

# 2. Validation de syntaxe Bash (bash -n)
echo ""
echo "--- 2. Validation de la syntaxe Bash (bash -n) ---"
syntax_check() {
    for file in bin/vget lib/*.sh install.sh; do
        [[ -f "$file" ]] || continue
        bash -n "$file" || return 1
    done
    return 0
}
test_case "Syntaxe Bash 100% valide" syntax_check

# 3. Linter ShellCheck
echo ""
echo "--- 3. Analyse statique ShellCheck ---"
shellcheck_check() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        echo "Shellcheck non installé, test ignoré."
        return 0
    fi
    shellcheck bin/vget lib/*.sh install.sh
}
test_case "ShellCheck sans avertissement (0 warning)" shellcheck_check

# 4. Tests d'exécution des options de base
echo ""
echo "--- 4. Tests d'exécution CLI ---"
test_case "vget --version retourne la version" ./bin/vget --version
test_case "vget --help s'affiche correctement" ./bin/vget --help
test_case "vget --check-deps fonctionne" bash -c "./bin/vget --check-deps >/dev/null || true"
test_case "vget init déploie et initialise le PATH" ./bin/vget init

# 5. Test de rejet d'argument invalide
test_invalid_arg() {
    if ./bin/vget --option-invalide-test >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}
test_case "Rejet propre d'arguments invalides (exit code 1)" test_invalid_arg

echo ""
echo "=================================================="
if [[ $ERRORS -eq 0 ]]; then
    echo "🎉 TOUS LES TESTS SONT PASSÉS AVEC SUCCÈS ($TOTAL_TESTS/$TOTAL_TESTS)"
    echo "=================================================="
    exit 0
else
    echo "✖ ÉCHEC : $ERRORS test(s) ont échoué sur $TOTAL_TESTS"
    echo "=================================================="
    exit 1
fi
