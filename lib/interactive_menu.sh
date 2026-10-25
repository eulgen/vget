#!/usr/bin/env bash
# ==============================================================================
# vget - Interactive Telescope TUI Menu Module (Option 3)
# Role: Menus de sélection Telescope avec prévisualisation dynamique
# ==============================================================================

[[ -n "${VGET_INTERACTIVE_MENU_LOADED:-}" ]] && return 0
readonly VGET_INTERACTIVE_MENU_LOADED=1

# shellcheck source=/dev/null
source "$LIB_DIR/preview.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/picker.sh"

get_telescope_preview_window() {
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    if [[ $cols -lt 100 ]]; then
        echo "down:45%:wrap:rounded"
    else
        echo "right:52%:wrap:rounded"
    fi
}

select_action_telescope() {
    if [[ ! -t 0 ]]; then
        local line
        read -r line || true
        echo "${line%% *}"
        return 0
    fi

    local clip_url="${1:-}"
    local items=()
    [[ -n "$clip_url" ]] && items+=("clipboard   Use URL from clipboard (${clip_url:0:34}...)")
    items+=(
        "video       Download video stream in 1080p, 720p or 4K"
        "audio       Extract lossless or high-bitrate audio track"
        "stream      Instant playback via mpv without disk write"
        "search      Search YouTube / Web directly"
        "gif         Generate optimized animated GIF clip (--trim)"
        "history     Display completed downloads ledger"
        "formats     Inspect remote codecs and available streams (-F)"
        "deps        Engine diagnostics (--check-deps)"
        "update      Update vget and yt-dlp binaries"
        "quit        Exit session"
    )

    if command -v fzf >/dev/null 2>&1; then
        local p_win
        p_win="$(get_telescope_preview_window)"

        local chosen
        chosen=$(printf "%s\n" "${items[@]}" | fzf \
            --height=60% --min-height=14 --layout=reverse --border=rounded \
            --border-label=" vget · actions " --border-label-pos=2 \
            --preview-label=" preview " --preview-label-pos=2 \
            --prompt="› " --pointer="›" --marker="✓" \
            --color="bg+:#1e2030,fg+:#c0caf5,prompt:#7aa2f7,pointer:#bb9af7,header:#7dcfff,border:#3b4261,info:#7aa2f7,hl:#e0af68,hl+:#ff9e64,label:#7aa2f7" \
            --preview-window="$p_win" \
            --preview="bash \"$LIB_DIR/preview.sh\" {}" || true)
        echo "${chosen%% *}"
    else
        telescope_pure_bash_picker "vget · actions" "${items[@]}"
    fi
}

select_quality_telescope() {
    if [[ ! -t 0 ]]; then
        local line
        read -r line || true
        echo "${line%% *}"
        return 0
    fi

    local qualities=(
        "1080p   Full HD · 1920x1080 (Recommended)"
        "720p    HD Standard · 1280x720"
        "4k      Ultra HD · 3840x2160"
        "best    Highest available remote master"
        "480p    SD Quality · Bandwidth saver"
        "360p    Data Saver · Ultra compact"
    )

    if command -v fzf >/dev/null 2>&1; then
        local p_win
        p_win="$(get_telescope_preview_window)"

        local chosen
        chosen=$(printf "%s\n" "${qualities[@]}" | fzf \
            --height=45% --min-height=10 --layout=reverse --border=rounded \
            --border-label=" video quality " --border-label-pos=2 \
            --preview-label=" preview " --preview-label-pos=2 \
            --prompt="› quality: " --pointer="›" --marker="✓" \
            --color="bg+:#1e2030,fg+:#c0caf5,prompt:#7aa2f7,pointer:#bb9af7,header:#7dcfff,border:#3b4261,info:#7aa2f7,hl:#e0af68,hl+:#ff9e64,label:#7aa2f7" \
            --preview-window="$p_win" \
            --preview="bash \"$LIB_DIR/preview.sh\" {}" || true)
        echo "${chosen%% *}"
    else
        telescope_pure_bash_picker "video quality" "${qualities[@]}"
    fi
}

select_audio_format_telescope() {
    if [[ ! -t 0 ]]; then
        local line
        read -r line || true
        echo "${line%% *}"
        return 0
    fi

    local formats=(
        "mp3     MP3 · 320kbps CBR (Universal)"
        "flac    FLAC · Bit-perfect lossless studio"
        "m4a     M4A · High-efficiency AAC container"
        "wav     WAV · Raw uncompressed PCM stream"
    )

    if command -v fzf >/dev/null 2>&1; then
        local p_win
        p_win="$(get_telescope_preview_window)"

        local chosen
        chosen=$(printf "%s\n" "${formats[@]}" | fzf \
            --height=40% --min-height=9 --layout=reverse --border=rounded \
            --border-label=" audio format " --border-label-pos=2 \
            --preview-label=" preview " --preview-label-pos=2 \
            --prompt="› format: " --pointer="›" --marker="✓" \
            --color="bg+:#1e2030,fg+:#c0caf5,prompt:#7aa2f7,pointer:#bb9af7,header:#7dcfff,border:#3b4261,info:#7aa2f7,hl:#e0af68,hl+:#ff9e64,label:#7aa2f7" \
            --preview-window="$p_win" \
            --preview="bash \"$LIB_DIR/preview.sh\" {}" || true)
        echo "${chosen%% *}"
    else
        telescope_pure_bash_picker "audio format" "${formats[@]}"
    fi
}
