#!/usr/bin/env bash
# ==============================================================================
# vget - User Interface & Styling Module
# Role: Couleurs TrueColor/ANSI, typographie sobre, cartes et barres de progression
# ==============================================================================

[[ -n "${VGET_UI_LOADED:-}" ]] && return 0
readonly VGET_UI_LOADED=1

# Initialisation des codes couleurs selon le terminal
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    CLR_RESET=$'\033[0m'
    CLR_BOLD=$'\033[1m'
    CLR_DIM=$'\033[2m'
    if [[ "${COLORTERM:-}" == "truecolor" || "${COLORTERM:-}" == "24bit" ]]; then
        CLR_PRIMARY=$'\033[38;2;56;189;248m'     # Cyan acier (#38bdf8)
        CLR_SECONDARY=$'\033[38;2;168;85;247m'   # Violet ardoise (#a855f7)
        CLR_SUCCESS=$'\033[38;2;52;211;153m'     # Vert émeraude (#34d399)
        CLR_WARNING=$'\033[38;2;251;191;36m'    # Ambre doux (#fbbf24)
        CLR_DANGER=$'\033[38;2;244;63;94m'      # Rose rubis (#f43f5e)
        CLR_MUTED=$'\033[38;2;148;163;184m'      # Gris ardoise (#94a3b8)
    else
        CLR_PRIMARY=$'\033[38;5;39m'
        CLR_SECONDARY=$'\033[38;5;135m'
        CLR_SUCCESS=$'\033[38;5;82m'
        CLR_WARNING=$'\033[38;5;214m'
        CLR_DANGER=$'\033[38;5;196m'
        CLR_MUTED=$'\033[38;5;244m'
    fi
else
    CLR_RESET="" CLR_BOLD="" CLR_DIM=""
    CLR_PRIMARY="" CLR_SECONDARY="" CLR_SUCCESS=""
    CLR_WARNING="" CLR_DANGER="" CLR_MUTED=""
fi
export CLR_RESET CLR_BOLD CLR_DIM CLR_PRIMARY CLR_SECONDARY CLR_SUCCESS CLR_WARNING CLR_DANGER CLR_MUTED

# Indicateurs de statut minimalistes pour CLI professionnelle
print_info()    { printf "%b›%b %s\n" "${CLR_PRIMARY}" "${CLR_RESET}" "$*"; }
print_success() { printf "%b✓%b %s\n" "${CLR_SUCCESS}" "${CLR_RESET}" "$*"; }
print_warning() { printf "%b!%b %s\n" "${CLR_WARNING}" "${CLR_RESET}" "$*"; }
print_error()   { printf "%bx%b %s\n" "${CLR_DANGER}" "${CLR_RESET}" "$*" >&2; }
print_muted()   { printf "%b%s%b\n" "${CLR_MUTED}" "$*" "${CLR_RESET}"; }
print_step()    { printf "%b::%b %s\n" "${CLR_MUTED}" "${CLR_RESET}" "$*"; }

# En-tête typographique minimaliste et moderne (zéro bruit visuel)
print_banner() {
    printf "%bvget%b %sv%s%b %s·%b %suniversal media cli%b\n\n" \
        "${CLR_BOLD}${CLR_PRIMARY}" "${CLR_RESET}" \
        "${CLR_MUTED}" "${VGET_VERSION:-1.0.0}" "${CLR_RESET}" \
        "${CLR_MUTED}" "${CLR_RESET}" \
        "${CLR_MUTED}" "${CLR_RESET}"
}

# Affiche une boîte d'information épurée
draw_card() {
    local title="$1"
    local content="$2"
    local color="${3:-$CLR_PRIMARY}"
    local width="${4:-54}"

    local inner_width=$((width - 4))
    local title_len=${#title}
    local padding_right=$((inner_width - title_len - 1))
    [[ $padding_right -lt 1 ]] && padding_right=1

    printf "%b╭─ %b%s %b" "$color" "$CLR_BOLD" "$title" "$color"
    for ((i=0; i<padding_right; i++)); do printf "─"; done
    printf "╮%b\n" "$CLR_RESET"

    while IFS= read -r line; do
        printf "%b│%b  %-*s%b│%b\n" "$color" "$CLR_RESET" "$inner_width" "$line" "$color" "$CLR_RESET"
    done <<< "$content"

    printf "%b╰" "$color"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "╯%b\n" "$CLR_RESET"
}

# Barre de progression sub-pixel ultra-fluide (1/8ème de bloc)
render_smooth_progress_bar() {
    local percent="$1"
    local width="${2:-28}"
    local blocks=(" " "▏" "▎" "▍" "▌" "▋" "▊" "▉" "█")

    local total_eighths=$(( percent * width * 8 / 100 ))
    local full_blocks=$(( total_eighths / 8 ))
    local remainder=$(( total_eighths % 8 ))
    local empty_blocks=$(( width - full_blocks - (remainder > 0 ? 1 : 0) ))

    printf "\r["
    printf "%b" "$CLR_PRIMARY"
    for ((i=0; i<full_blocks; i++)); do printf "█"; done
    if (( remainder > 0 )); then printf "%s" "${blocks[remainder]}"; fi
    printf "%b" "$CLR_MUTED"
    for ((i=0; i<empty_blocks; i++)); do printf "░"; done
    printf "%b] %3d%%" "$CLR_RESET" "$percent"
}

# Spinner d'attente sobre
run_with_spinner() {
    local message="$1"
    shift
    local pid
    local delay=0.08
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    "$@" &
    pid=$!

    tput civis 2>/dev/null || printf "\033[?25l"
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r%b%c%b %s" "${CLR_PRIMARY}" "$spinstr" "${CLR_RESET}" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
    done
    tput cnorm 2>/dev/null || printf "\033[?25h"
    wait "$pid"
    local exit_code=$?
    printf "\r\033[K"
    return "$exit_code"
}
