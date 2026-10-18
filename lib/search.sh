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
        selection=$(printf "%s\n" "${items[@]}" | fzf --prompt="Choisir une vidéo > " --height=50% --reverse --border)
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
    printf "%bQue voulez-vous faire ?%b\n" "${CLR_BOLD}" "${CLR_RESET}"
    echo "  1) Télécharger la vidéo (1080p)"
    echo "  2) Télécharger en 720p"
    echo "  3) Extraire l'audio (MP3)"
    echo "  4) Lire en streaming direct"
    echo "  0) Annuler"
    printf "%bVotre choix (1-4) : %b" "${CLR_PRIMARY}" "${CLR_RESET}"
    local action
    read -r action

    case "$action" in
        1) export MODE="video" QUALITY="1080p"; execute_download ;;
        2) export MODE="video" QUALITY="720p"; execute_download ;;
        3) export MODE="audio" AUDIO_FORMAT="mp3"; execute_download ;;
        4) export MODE="play"; stream_media "$TARGET_URL" ;;
        *) print_warning "Annulé." ;;
    esac
}
