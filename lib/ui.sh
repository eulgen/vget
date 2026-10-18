#!/usr/bin/env bash
# ==============================================================================
# vget - User Interface & Styling Module
# Role: Couleurs ANSI, bannières stylisées, spinners et messages d'état
# ==============================================================================

[[ -n "${VGET_UI_LOADED:-}" ]] && return 0
readonly VGET_UI_LOADED=1

# Initialisation des codes couleurs selon le terminal
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    CLR_RESET=$'\033[0m'
    CLR_BOLD=$'\033[1m'
    CLR_DIM=$'\033[2m'
    CLR_PRIMARY=$'\033[38;5;39m'     # Cyan électrique
    CLR_SUCCESS=$'\033[38;5;82m'     # Vert vif
    CLR_WARNING=$'\033[38;5;214m'    # Orange doux
    CLR_DANGER=$'\033[38;5;196m'     # Rouge vif
    CLR_MUTED=$'\033[38;5;244m'      # Gris neutre
else
    CLR_RESET=""
    CLR_BOLD=""
    CLR_DIM=""
    CLR_PRIMARY=""
    CLR_SUCCESS=""
    CLR_WARNING=""
    CLR_DANGER=""
    CLR_MUTED=""
fi
export CLR_RESET CLR_BOLD CLR_DIM CLR_PRIMARY CLR_SUCCESS CLR_WARNING CLR_DANGER CLR_MUTED

print_info()    { printf "%b[ℹ]%b %s\n" "${CLR_PRIMARY}" "${CLR_RESET}" "$*"; }
print_success() { printf "%b[✔]%b %s\n" "${CLR_SUCCESS}" "${CLR_RESET}" "$*"; }
print_warning() { printf "%b[▲]%b %s\n" "${CLR_WARNING}" "${CLR_RESET}" "$*"; }
print_error()   { printf "%b[✖]%b %s\n" "${CLR_DANGER}" "${CLR_RESET}" "$*" >&2; }
print_muted()   { printf "%b%s%b\n" "${CLR_MUTED}" "$*" "${CLR_RESET}"; }

# Affiche la bannière visuelle de vget
print_banner() {
    printf "%b" "${CLR_PRIMARY}${CLR_BOLD}"
    cat << "EOF"
  __   __ __ _   ___  _   
  \ \ / // _` | / _ \| |_ 
   \ V /| (_| ||  __/|  _|
    \_/  \__, | \___| \__|
         |___/            
EOF
    printf "%b  Universal Video & Audio CLI Hub (v%s)%b\n\n" "${CLR_MUTED}" "${VGET_VERSION:-1.0.0}" "${CLR_RESET}"
}

# Exécute une commande avec un spinner animé non-bloquant
run_with_spinner() {
    local message="$1"
    shift
    local pid
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    "$@" &
    pid=$!

    # Masquer le curseur
    tput civis 2>/dev/null || printf "\033[?25l"
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r%b[%c]%b %s" "${CLR_PRIMARY}" "$spinstr" "${CLR_RESET}" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
    done
    # Réafficher le curseur
    tput cnorm 2>/dev/null || printf "\033[?25h"
    wait "$pid"
    local exit_code=$?
    printf "\r\033[K"
    return "$exit_code"
}
