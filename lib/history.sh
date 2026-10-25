#!/usr/bin/env bash
# ==============================================================================
# vget - Download History Module
# Role: Journalisation et consultation de l'historique des téléchargements
# ==============================================================================

[[ -n "${VGET_HISTORY_LOADED:-}" ]] && return 0
readonly VGET_HISTORY_LOADED=1

get_history_file() {
    local dir="${XDG_DATA_HOME:-$HOME/.local/share}/vget"
    mkdir -p "$dir"
    echo "$dir/history.tsv"
}

log_history() {
    local mode="$1"
    local title="$2"
    local url="$3"
    local filepath="$4"
    local hist_file
    hist_file="$(get_history_file)"
    local date_str
    date_str="$(date '+%Y-%m-%d %H:%M:%S')"

    printf "%s\t%s\t%s\t%s\t%s\n" "$date_str" "$mode" "$title" "$url" "$filepath" >> "$hist_file"
}

show_history() {
    local hist_file
    hist_file="$(get_history_file)"
    print_banner

    if [[ ! -f "$hist_file" || ! -s "$hist_file" ]]; then
        print_info "Aucun téléchargement dans l'historique."
        return 0
    fi

    printf "%bHistorique des téléchargements :%b\n\n" "${CLR_BOLD}" "${CLR_RESET}"
    printf "%b%-20s %-8s %-40s %s%b\n" "${CLR_MUTED}" "DATE" "TYPE" "TITRE" "FICHIER" "${CLR_RESET}"
    printf "%b%s%b\n" "${CLR_MUTED}" "------------------------------------------------------------------------------------------------" "${CLR_RESET}"

    tail -n 20 "$hist_file" | while IFS=$'\t' read -r date_str mode title url filepath; do
        local badge_color="${CLR_PRIMARY}"
        [[ "$mode" == "audio" ]] && badge_color="${CLR_WARNING}"
        [[ "$mode" == "gif" ]] && badge_color="${CLR_SUCCESS}"

        local short_title="${title:0:38}"
        local short_file="${filepath##*/}"
        short_file="${short_file:0:35}"

        printf "%-20s %b[%-5s]%b %-40s %s\n" \
            "$date_str" "$badge_color" "$mode" "${CLR_RESET}" "$short_title" "$short_file"
    done
    echo ""
}
