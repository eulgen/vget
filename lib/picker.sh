#!/usr/bin/env bash
# ==============================================================================
# vget - Native Telescope Pure Bash Picker
# Role: Sélecteur interactif fléché avec volet de prévisualisation sans dépendance
# ==============================================================================

[[ -n "${VGET_PICKER_LOADED:-}" ]] && return 0
readonly VGET_PICKER_LOADED=1

# shellcheck source=/dev/null
source "$LIB_DIR/preview.sh"

telescope_pure_bash_picker() {
    local title="$1"
    shift
    local -a items=("$@")
    local count=${#items[@]}
    [[ $count -eq 0 ]] && return 0

    if [[ ! -t 0 ]]; then
        local line
        read -r line || true
        echo "${line%% *}"
        return 0
    fi

    local selected=0
    local key=""
    local first_render=1
    local total_lines=0

    tput civis 2>/dev/null || printf "\033[?25l"
    cleanup_picker() {
        tput cnorm 2>/dev/null || printf "\033[?25h"
    }
    trap cleanup_picker RETURN

    while true; do
        local cur_item="${items[selected]}"
        local cur_key="${cur_item%% *}"

        if [[ $first_render -eq 0 && $total_lines -gt 0 ]]; then
            printf "\033[%dA" "$total_lines" >&2
        fi
        first_render=0

        local rendered_lines=0
        printf "\033[K%b╭─ %s %b" "${CLR_PRIMARY}" "$title" "${CLR_PRIMARY}" >&2
        local pad=$(( 52 - ${#title} ))
        [[ $pad -lt 1 ]] && pad=1
        for ((p=0; p<pad; p++)); do printf "─" >&2; done
        printf "╮%b\n" "${CLR_RESET}" >&2
        ((rendered_lines++))

        for ((i=0; i<count; i++)); do
            local it="${items[i]}"
            local it_display="${it:0:52}"
            if [[ $i -eq $selected ]]; then
                printf "\033[K%b│ %b› %-51s%b│%b\n" "${CLR_PRIMARY}" "${CLR_BOLD}${CLR_PRIMARY}" "$it_display" "${CLR_PRIMARY}" "${CLR_RESET}" >&2
            else
                printf "\033[K%b│   %-51s%b│%b\n" "${CLR_PRIMARY}" "$it_display" "${CLR_PRIMARY}" "${CLR_RESET}" >&2
            fi
            ((rendered_lines++))
        done

        printf "\033[K%b├─ preview ──────────────────────────────────────────────┤%b\n" "${CLR_PRIMARY}" "${CLR_RESET}" >&2
        ((rendered_lines++))

        local p_text
        p_text="$(render_telescope_preview "$cur_item" | head -n 3 | sed 's/\x1b\[[0-9;]*m//g')"
        while IFS= read -r p_line; do
            local p_clean="${p_line:0:52}"
            printf "\033[K%b│ %b%-52s%b│%b\n" "${CLR_PRIMARY}" "${CLR_MUTED}" "$p_clean" "${CLR_PRIMARY}" "${CLR_RESET}" >&2
            ((rendered_lines++))
        done <<< "$p_text"

        printf "\033[K%b╰─ [↑/k] Up  [↓/j] Down  [Enter] Select  [q] Quit ───────╯%b\n" "${CLR_PRIMARY}" "${CLR_RESET}" >&2
        ((rendered_lines++))

        total_lines=$rendered_lines

        IFS= read -rsn1 key
        if [[ "$key" == $'\x1b' ]]; then
            local seq
            read -rsn2 -t 0.1 seq || true
            if [[ "$seq" == "[A" ]]; then
                selected=$(( (selected - 1 + count) % count ))
            elif [[ "$seq" == "[B" ]]; then
                selected=$(( (selected + 1) % count ))
            else
                echo "quit"
                return 0
            fi
        elif [[ "$key" == "k" || "$key" == "K" ]]; then
            selected=$(( (selected - 1 + count) % count ))
        elif [[ "$key" == "j" || "$key" == "J" ]]; then
            selected=$(( (selected + 1) % count ))
        elif [[ -z "$key" ]]; then
            cleanup_picker
            echo "$cur_key"
            return 0
        elif [[ "$key" == "q" || "$key" == "Q" ]]; then
            cleanup_picker
            echo "quit"
            return 0
        fi
    done
}
