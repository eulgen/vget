#!/usr/bin/env bash
# ==============================================================================
# vget - Multi-Platform Search Engine
# Role: Recherche en ligne via yt-dlp et sélection interactive
# ==============================================================================

[[ -n "${VGET_SEARCH_LOADED:-}" ]] && return 0
readonly VGET_SEARCH_LOADED=1

# Recherche et permet la sélection d'un résultat
search_and_select() {
    local query="${1:-}"
    if [[ -z "$query" ]]; then
        printf "%bEntrez votre recherche : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
        read -r query
    fi

    if [[ -z "$query" ]]; then
        print_error "Recherche vide."
        return 1
    fi

    print_info "Recherche en cours pour : '$query'..."

    # Récupération des 8 premiers résultats au format: ID | Durée | Titre
    local raw_results
    raw_results=$(yt-dlp "ytsearch8:${query}" \
        --flat-playlist \
        --skip-download \
        --print "%(id)s | %(duration_string,duration>%H:%M:%S|Inconnue)s | %(title)s" 2>/dev/null || true)

    if [[ -z "$raw_results" ]]; then
        print_warning "Aucun résultat trouvé pour : '$query'"
        return 1
    fi

    local -a items=()
    local -a ids=()
    local -a titles=()

    while IFS='|' read -r vid_id duration title; do
        vid_id=$(echo "$vid_id" | xargs)
        duration=$(echo "$duration" | xargs)
        title=$(echo "$title" | xargs)
        if [[ -n "$vid_id" ]]; then
            ids+=("$vid_id")
            titles+=("$title")
            items+=("[$duration] $title")
        fi
    done <<< "$raw_results"

    local selected_idx=-1

    # Sélection interactive avec fzf ou menu standard
    if command -v fzf >/dev/null 2>&1; then
        local selection
        selection=$(printf "%s\n" "${items[@]}" | fzf \
            --height=50% --min-height=12 --layout=reverse --border=rounded \
            --border-label=" search results · $query " --border-label-pos=2 \
            --prompt="› " --pointer="›" --marker="✓" \
            --color="bg+:#1e2030,fg+:#c0caf5,prompt:#7aa2f7,pointer:#bb9af7,header:#7dcfff,border:#3b4261,info:#7aa2f7,hl:#e0af68,hl+:#ff9e64,label:#7aa2f7" || true)
        for i in "${!items[@]}"; do
            if [[ "${items[$i]}" == "$selection" ]]; then
                selected_idx=$i
                break
            fi
        done
    else
        echo ""
        print_info "Résultats trouvés :"
        for i in "${!items[@]}"; do
            printf "  %b%2d)%b %s\n" "${CLR_PRIMARY}" "$((i+1))" "${CLR_RESET}" "${items[$i]}"
        done
        echo ""
        printf "%bEntrez le numéro (1-%d, 0 pour quitter) : %b" "${CLR_PRIMARY}" "${#items[@]}" "${CLR_RESET}"
        local choice
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 && "$choice" -le "${#items[@]}" ]]; then
            selected_idx=$((choice - 1))
        fi
    fi

    if [[ $selected_idx -lt 0 ]]; then
        print_warning "Opération annulée."
        return 0
    fi

    local selected_id="${ids[$selected_idx]}"
    local selected_title="${titles[$selected_idx]}"
    export TARGET_URL="https://www.youtube.com/watch?v=$selected_id"

    echo ""
    print_success "Sélectionné : $selected_title"

    local -a actions=(
        "video-1080p   Download Video (1080p Full HD)"
        "video-720p    Download Video (720p HD Standard)"
        "audio-mp3     Extract Audio Track (MP3 320kbps)"
        "stream        Instant Playback via mpv"
        "cancel        Cancel"
    )
    local act_choice=""
    if command -v fzf >/dev/null 2>&1; then
        local raw_act
        raw_act=$(printf "%s\n" "${actions[@]}" | fzf \
            --height=35% --min-height=8 --layout=reverse --border=rounded \
            --border-label=" action for: ${selected_title:0:36} " --border-label-pos=2 \
            --prompt="› " --pointer="›" \
            --color="bg+:#1e2030,fg+:#c0caf5,prompt:#7aa2f7,pointer:#bb9af7,header:#7dcfff,border:#3b4261,info:#7aa2f7,hl:#e0af68,hl+:#ff9e64,label:#7aa2f7" || true)
        act_choice="${raw_act%% *}"
    else
        printf "%bAction [1: 1080p, 2: 720p, 3: mp3, 4: stream] (default 1): %b" "${CLR_PRIMARY}" "${CLR_RESET}"
        local num
        read -r num
        case "$num" in
            2) act_choice="video-720p" ;;
            3) act_choice="audio-mp3" ;;
            4) act_choice="stream" ;;
            *) act_choice="video-1080p" ;;
        esac
    fi

    case "$act_choice" in
        video-1080p) export MODE="video" QUALITY="1080p"; execute_download ;;
        video-720p)  export MODE="video" QUALITY="720p"; execute_download ;;
        audio-mp3)   export MODE="audio" AUDIO_FORMAT="mp3"; execute_download ;;
        stream)      export MODE="play"; stream_media "$TARGET_URL" ;;
        *)           print_warning "Annulé." ;;
    esac
}
