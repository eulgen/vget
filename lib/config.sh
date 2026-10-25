#!/usr/bin/env bash
# ==============================================================================
# vget - Configuration & Defaults Module
# Role: Centralise la configuration globale, les chemins multi-OS et l'environnement
# ==============================================================================

[[ -n "${VGET_CONFIG_LOADED:-}" ]] && return 0
readonly VGET_CONFIG_LOADED=1

[[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]] && export PATH="${HOME}/.local/bin:${PATH}"

# Version officielle
export VGET_VERSION="1.0.0"

# Détection de la plateforme hôte (Linux, macOS, Windows Git Bash / WSL)
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        Linux*) echo "linux" ;;
        *) echo "generic" ;;
    esac
}
export VGET_PLATFORM
VGET_PLATFORM="$(detect_platform)"

# Répertoires de destination adaptés selon l'OS
if [[ "$VGET_PLATFORM" == "macos" ]]; then
    export VGET_VIDEO_DIR="${VGET_VIDEO_DIR:-$HOME/Movies/vget}"
    export VGET_AUDIO_DIR="${VGET_AUDIO_DIR:-$HOME/Music/vget}"
elif [[ "$VGET_PLATFORM" == "windows" && -n "${USERPROFILE:-}" ]]; then
    win_profile="${USERPROFILE//\\//}"
    export VGET_VIDEO_DIR="${VGET_VIDEO_DIR:-$win_profile/Videos/vget}"
    export VGET_AUDIO_DIR="${VGET_AUDIO_DIR:-$win_profile/Music/vget}"
else
    export VGET_VIDEO_DIR="${VGET_VIDEO_DIR:-$HOME/Videos/vget}"
    export VGET_AUDIO_DIR="${VGET_AUDIO_DIR:-$HOME/Music/vget}"
fi

export VGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vget"
export VGET_ARCHIVE_FILE="${VGET_ARCHIVE_FILE:-${XDG_DATA_HOME:-$HOME/.local/share}/vget/archive.txt}"

# Paramètres de qualité et réseau par défaut
export VGET_DEFAULT_VIDEO_QUALITY="${VGET_DEFAULT_VIDEO_QUALITY:-1080p}"
export VGET_DEFAULT_AUDIO_FORMAT="${VGET_DEFAULT_AUDIO_FORMAT:-mp3}"
export VGET_CONCURRENT_FRAGMENTS="${VGET_CONCURRENT_FRAGMENTS:-5}"
export VGET_FAST="${VGET_FAST:-false}"
export VGET_EFFICIENT="${VGET_EFFICIENT:-false}"
export VGET_USE_ARCHIVE="${VGET_USE_ARCHIVE:-false}"

# Initialise les répertoires nécessaires
init_vget_dirs() {
    local target_dir="${1:-}"
    if [[ -n "$target_dir" ]]; then
        mkdir -p "$target_dir"
    else
        mkdir -p "$VGET_VIDEO_DIR" "$VGET_AUDIO_DIR"
    fi
}
