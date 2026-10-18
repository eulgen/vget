#!/usr/bin/env bash
# ==============================================================================
# vget - Streaming & Direct Player Engine
# Role: Pilotage de mpv pour la lecture instantanée sans téléchargement préalable
# ==============================================================================

[[ -n "${VGET_PLAYER_LOADED:-}" ]] && return 0
readonly VGET_PLAYER_LOADED=1

# Lance la lecture ou le streaming direct via mpv
stream_media() {
    local url="${1:-$TARGET_URL}"
    if [[ -z "$url" ]]; then
        print_error "Aucune URL fournie pour la lecture en streaming."
        return 1
    fi

    if ! command -v mpv >/dev/null 2>&1; then
        print_error "mpv n'est pas installé. Nécessaire pour le streaming direct."
        print_info "Commande pour installer: $(get_install_hint "mpv")"
        return 1
    fi

    local -a mpv_cmd=("mpv")

    # Options d'affichage et de contrôle
    mpv_cmd+=("--msg-level=all=warn" "--force-window=immediate")
    mpv_cmd+=("--ytdl-format=bestvideo[height<=1080]+bestaudio/best")

    # Mode audio pur ou vidéo
    if [[ "$MODE" == "audio" ]]; then
        mpv_cmd+=("--no-video")
        print_info "Lecture audio en streaming: $url"
    else
        print_info "Lecture vidéo en streaming: $url"
    fi

    print_muted "Raccourcis mpv : [Espace] Pause | [<- / ->] Avance/Recul | [9 / 0] Volume | [q] Quitter"
    
    "${mpv_cmd[@]}" "$url"
    return $?
}
