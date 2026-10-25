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

    # Options d'affichage et décodage robuste (priorité H.264/VP9 pour parer les bugs AV1 matériels)
    mpv_cmd+=(
        "--msg-level=all=warn"
        "--force-window=immediate"
        "--hwdec=auto-safe"
        "--ytdl-format=bestvideo[height<=1080][vcodec^=avc1]+bestaudio/bestvideo[height<=1080][vcodec^=vp9]+bestaudio/bestvideo[height<=1080]+bestaudio/best"
    )

    # Mode audio pur ou vidéo
    if [[ "$MODE" == "audio" ]]; then
        mpv_cmd+=("--no-video")
        print_info "Lecture audio en streaming: $url"
    else
        print_info "Lecture vidéo en streaming: $url"
    fi

    print_muted "Raccourcis mpv : [Espace] Pause | [<- / ->] Avance/Recul | [9 / 0] Volume | [q] Quitter"

    set +e
    "${mpv_cmd[@]}" "$url"
    local exit_code=$?
    set -e

    # En cas de plantage du pilote GPU (Segfault 139 VAAPI/NVDEC), repli automatique en décodage logiciel
    if [[ $exit_code -eq 139 ]]; then
        print_warning "Plantage du pilote GPU détecté. Repli automatique en décodage logiciel (CPU)..."
        local -a fallback_cmd=(
            "mpv"
            "--msg-level=all=warn"
            "--force-window=immediate"
            "--hwdec=no"
            "--ytdl-format=bestvideo[height<=1080][vcodec^=avc1]+bestaudio/bestvideo[height<=1080]+bestaudio/best"
        )
        [[ "$MODE" == "audio" ]] && fallback_cmd+=("--no-video")
        "${fallback_cmd[@]}" "$url"
        return $?
    fi

    return "$exit_code"
}
