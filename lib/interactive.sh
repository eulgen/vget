#!/usr/bin/env bash
# ==============================================================================
# vget - Interactive Terminal UI (TUI) Mode (Option 3 - Neovim Telescope Style)
# Role: Orchestration du mode interactif et exécution des actions choisies
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
# shellcheck source=/dev/null
source "$LIB_DIR/clipboard.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/history.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/gif.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/interactive_menu.sh"

interactive_video() {
    check_dependencies "video" || return 1
    if [[ -z "${TARGET_URL:-}" ]]; then
        printf "%b› video url: %b" "${CLR_PRIMARY}" "${CLR_RESET}"
        read -r TARGET_URL
        [[ -z "$TARGET_URL" ]] && { print_warning "URL vide."; return; }
    fi
    export TARGET_URL MODE="video"

    local q_picked
    q_picked="$(select_quality_telescope)"
    export QUALITY="${q_picked:-1080p}"

    printf "%b› Enable SponsorBlock (remove sponsors/intros)? [y/N]: %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local sb
    read -r sb
    [[ "$sb" =~ ^[oOyY]$ ]] && export SPONSORBLOCK="true"

    printf "%b› Embed subtitles? (e.g. fr,en or press Enter to skip): %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local sub
    read -r sub
    [[ -n "$sub" ]] && export SUB_LANGS="$sub"

    execute_download
}

interactive_audio() {
    check_dependencies "audio" || return 1
    if [[ -z "${TARGET_URL:-}" ]]; then
        printf "%b› audio url: %b" "${CLR_PRIMARY}" "${CLR_RESET}"
        read -r TARGET_URL
        [[ -z "$TARGET_URL" ]] && { print_warning "URL vide."; return; }
    fi
    export TARGET_URL MODE="audio"

    local a_picked
    a_picked="$(select_audio_format_telescope)"
    export AUDIO_FORMAT="${a_picked:-mp3}"

    printf "%b› Normalize audio volume (EBU R128)? [y/N]: %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local norm
    read -r norm
    [[ "$norm" =~ ^[oOyY]$ ]] && export LOUDNORM="true"

    execute_download
}

start_interactive_mode() {
    local clip_url=""
    clip_url="$(get_clipboard_url 2>/dev/null || true)"

    local action=""
    action="$(select_action_telescope "$clip_url")"
    [[ -z "$action" || "$action" == "quit" ]] && exit 0

    case "$action" in
        clipboard)
            TARGET_URL="$clip_url"
            interactive_video
            ;;
        video) interactive_video ;;
        audio) interactive_audio ;;
        stream)
            if check_dependencies "play"; then
                printf "%b› stream url: %b" "${CLR_PRIMARY}" "${CLR_RESET}"
                read -r TARGET_URL
                [[ -n "$TARGET_URL" ]] && stream_media "$TARGET_URL"
            fi
            ;;
        search) search_and_select ;;
        gif)
            printf "%b› gif video url: %b" "${CLR_PRIMARY}" "${CLR_RESET}"
            read -r TARGET_URL
            printf "%b› start timestamp (e.g. 00:10): %b" "${CLR_PRIMARY}" "${CLR_RESET}"
            read -r TRIM_START
            printf "%b› end timestamp (e.g. 00:15): %b" "${CLR_PRIMARY}" "${CLR_RESET}"
            read -r TRIM_END
            generate_gif "$TARGET_URL" "$TRIM_START" "$TRIM_END" "${OUTPUT_DIR:-}"
            ;;
        history) show_history ;;
        formats)
            printf "%b› inspect url: %b" "${CLR_PRIMARY}" "${CLR_RESET}"
            read -r TARGET_URL
            [[ -n "$TARGET_URL" ]] && list_media_formats "$TARGET_URL"
            ;;
        deps) show_deps_status ;;
        update) run_updater ;;
        *) print_warning "Invalid action."; exit 1 ;;
    esac
}
