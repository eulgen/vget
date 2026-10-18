#!/usr/bin/env bash
# ==============================================================================
# vget - Configuration & Defaults Module
# Role: Centralise la configuration globale, les chemins par défaut et l'environnement
# ==============================================================================

# Sécurité & mode strict (si exécuté directement ou sourcé)
[[ -n "${VGET_CONFIG_LOADED:-}" ]] && return 0
readonly VGET_CONFIG_LOADED=1

# Version officielle
export VGET_VERSION="1.0.0"

# Répertoires de destination par défaut (surchargeables via variables d'environnement)
export VGET_VIDEO_DIR="${VGET_VIDEO_DIR:-$HOME/Videos/vget}"
export VGET_AUDIO_DIR="${VGET_AUDIO_DIR:-$HOME/Music/vget}"
export VGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vget"

# Paramètres de qualité par défaut
export VGET_DEFAULT_VIDEO_QUALITY="${VGET_DEFAULT_VIDEO_QUALITY:-1080p}"
export VGET_DEFAULT_AUDIO_FORMAT="${VGET_DEFAULT_AUDIO_FORMAT:-mp3}"

# Initialise les répertoires nécessaires
init_vget_dirs() {
    local target_dir="${1:-}"
    if [[ -n "$target_dir" ]]; then
        mkdir -p "$target_dir"
    else
        mkdir -p "$VGET_VIDEO_DIR" "$VGET_AUDIO_DIR"
    fi
}
