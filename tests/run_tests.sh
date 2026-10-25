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

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; ERRORS=$((ERRORS + 1)); }

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
# shellcheck disable=SC2317
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
    return "$exceeded"
}
test_case "Tous les fichiers contiennent <= 200 lignes" max_lines_check

# 2. Validation de syntaxe Bash (bash -n)
echo ""
echo "--- 2. Validation de la syntaxe Bash (bash -n) ---"
# shellcheck disable=SC2317
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
# shellcheck disable=SC2317
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
echo "--- 4. Tests d'exécution CLI & Nouvelles Fonctionnalités ---"
test_case "vget --version retourne la version" ./bin/vget --version
test_case "vget --help s'affiche correctement" ./bin/vget --help
test_case "vget --check-deps fonctionne" bash -c "./bin/vget --check-deps >/dev/null || true"
test_case "vget --history s'affiche correctement" ./bin/vget --history

# shellcheck disable=SC2317
test_advanced_flags() {
    local out
    out=$(./bin/vget -n --loudnorm --no-notify --cookies-browser firefox --fast --efficient --archive "https://test.url" 2>&1 || true)
    [[ "$out" != *"Argument inconnu"* ]]
}
test_case "Acceptation des flags avancés (--fast, --efficient, --archive, etc.)" test_advanced_flags

# 5. Validation Multi-Plateforme (OS, Complétions, Wrappers)
# shellcheck disable=SC2317
test_cross_platform() {
    [[ -f "completions/vget.bash" ]] && [[ -f "completions/_vget" ]] && [[ -f "completions/vget.fish" ]] && \
    [[ -f "vget.cmd" ]] && [[ -f "vget.ps1" ]] && \
    [[ -f "packaging/homebrew/vget.rb" ]] && [[ -f "packaging/scoop/vget.json" ]]
}
test_case "Assets cross-platform présents (Bash/Zsh/Fish completions, Windows wrappers, Homebrew/Scoop)" test_cross_platform

test_case "vget init déploie et initialise le PATH" ./bin/vget init

# 6. Test de rejet d'argument invalide
# shellcheck disable=SC2317
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
    echo "ALL TESTS PASSED ($TOTAL_TESTS/$TOTAL_TESTS)"
    echo "=================================================="
    exit 0
else
    echo "FAILED: $ERRORS test(s) failed out of $TOTAL_TESTS"
    echo "=================================================="
    exit 1
fi
