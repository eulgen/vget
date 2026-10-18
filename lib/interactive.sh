#!/usr/bin/env bash
# ==============================================================================
# vget - Interactive Terminal UI (TUI) Mode
# Role: Expérience pas-à-pas inspirée de VidMate directement dans le terminal
# ==============================================================================

[[ -n "${VGET_INTERACTIVE_LOADED:-}" ]] && return 0
readonly VGET_INTERACTIVE_LOADED=1

# shellcheck source=/dev/null
source "$LIB_DIR/downloader.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/player.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/search.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/updater.sh"

# Menu interactif de téléchargement vidéo
interactive_video() {
    if ! check_dependencies "video"; then
        return 1
    fi
    printf "%bEntrez l'URL de la vidéo : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    read -r TARGET_URL
    [[ -z "$TARGET_URL" ]] && { print_warning "URL vide."; return; }
    export TARGET_URL MODE="video"

    echo ""
    printf "%bChoisissez la qualité :%b\n" "${CLR_BOLD}" "${CLR_RESET}"
    echo "  1) 1080p (Full HD - Recommandé)"
    echo "  2) 720p  (HD standard)"
    echo "  3) 480p  (SD - Qualité DVD)"
    echo "  4) 360p  (Léger - Économie data)"
    echo "  5) 240p  (Très léger)"
    echo "  6) 144p  (Ultra léger / minimal)"
    echo "  7) 4K    (Ultra HD)"
    echo "  8) Meilleure qualité absolue (Best)"
    printf "%bVotre choix (1-8, défaut 1) : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local q_choice
    read -r q_choice
    case "$q_choice" in
        2) export QUALITY="720p" ;;
        3) export QUALITY="480p" ;;
        4) export QUALITY="360p" ;;
        5) export QUALITY="240p" ;;
        6) export QUALITY="144p" ;;
        7) export QUALITY="4k" ;;
        8) export QUALITY="best" ;;
        *) export QUALITY="1080p" ;;
    esac

    # Option SponsorBlock
    printf "%bActiver SponsorBlock (retirer pubs/intros) ? (o/N) : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local sb
    read -r sb
    [[ "$sb" =~ ^[oOyY]$ ]] && export SPONSORBLOCK="true"

    # Option Sous-titres
    printf "%bIncruster les sous-titres ? (o/N) : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local sub
    read -r sub
    [[ "$sub" =~ ^[oOyY]$ ]] && export SUB_LANGS="fr,en"

    execute_download
}

# Menu interactif d'extraction audio
interactive_audio() {
    if ! check_dependencies "audio"; then
        return 1
    fi
    printf "%bEntrez l'URL du morceau / de la vidéo : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    read -r TARGET_URL
    [[ -z "$TARGET_URL" ]] && { print_warning "URL vide."; return; }
    export TARGET_URL MODE="audio"

    echo ""
    printf "%bChoisissez le format audio :%b\n" "${CLR_BOLD}" "${CLR_RESET}"
    echo "  1) MP3 (320kbps + Jaquette)"
    echo "  2) FLAC (Sans perte)"
    echo "  3) M4A (Format Apple)"
    printf "%bVotre choix (1-3, défaut 1) : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local a_choice
    read -r a_choice
    case "$a_choice" in
        2) export AUDIO_FORMAT="flac" ;;
        3) export AUDIO_FORMAT="m4a" ;;
        *) export AUDIO_FORMAT="mp3" ;;
    esac

    execute_download
}

# Point d'entrée du mode interactif
start_interactive_mode() {
    clear 2>/dev/null || true
    print_banner

    echo "Bienvenue dans l'assistant interactif vget."
    echo ""
    echo "  1) 📥 Télécharger une vidéo (choix qualité)"
    echo "  2) 🎵 Extraire de la musique (MP3/FLAC avec pochette)"
    echo "  3) 🔍 Rechercher en ligne (YouTube / Web)"
    echo "  4) 📺 Lire en streaming direct (sans téléchargement)"
    echo "  5) 🔎 Inspecter les formats d'un lien (-F)"
    echo "  6) 🛠️  Diagnostiquer les dépendances (--check-deps)"
    echo "  7) 🔄 Mettre à jour vget & yt-dlp (--update)"
    echo "  0) 🚪 Quitter"
    echo ""
    printf "%bQue souhaitez-vous faire ? (0-7) : %b" "${CLR_PRIMARY}" "${CLR_RESET}"

    local choice
    read -r choice

    case "$choice" in
        1) interactive_video ;;
        2) interactive_audio ;;
        3) search_and_select ;;
        4)
            if check_dependencies "play"; then
                printf "%bEntrez l'URL à streamer : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
                read -r TARGET_URL
                [[ -n "$TARGET_URL" ]] && stream_media "$TARGET_URL"
            fi
            ;;
        5)
            printf "%bEntrez l'URL à inspecter : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
            read -r TARGET_URL
            [[ -n "$TARGET_URL" ]] && list_media_formats "$TARGET_URL"
            ;;
        6) show_deps_status ;;
        7) run_updater ;;
        0) print_muted "Au revoir !"; exit 0 ;;
        *) print_warning "Option invalide."; exit 1 ;;
    esac
}
