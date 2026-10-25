#!/usr/bin/env bash
# ==============================================================================
# vget - Telescope Preview Generator Module
# Role: Rendu de métadonnées riches et techniques pour le volet de prévisualisation
# ==============================================================================

[[ -n "${VGET_PREVIEW_LOADED:-}" ]] && return 0
readonly VGET_PREVIEW_LOADED=1

render_telescope_preview() {
    local raw_item="${1:-}"
    local key="${raw_item%% *}"
    key="$(echo "$key" | tr '[:upper:]' '[:lower:]')"

    # Palette ANSI adaptée pour le volet preview
    local c_title=$'\033[1;38;2;56;189;248m'     # Cyan acier gras
    local c_bold=$'\033[1m'
    local c_muted=$'\033[38;2;148;163;184m'      # Slate
    local c_accent=$'\033[38;2;168;85;247m'     # Purple
    local c_green=$'\033[38;2;52;211;153m'      # Emerald
    local c_reset=$'\033[0m'

    case "$key" in
        video)
            printf "%bACTION%b      %bDownload Video Stream%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bTARGET%b      %s\n" "$c_muted" "$c_reset" "${VGET_VIDEO_DIR:-$HOME/Videos/vget}"
            printf "%bENGINES%b     yt-dlp + ffmpeg + aria2c\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Multi-resolution: 1080p, 720p, 4k, best\n" "$c_accent" "$c_reset"
            printf "  %b·%b Parallel accelerator: aria2c 16 connections (--fast)\n" "$c_accent" "$c_reset"
            printf "  %b·%b High-efficiency codecs: AV1, VP9 (-40%% bandwidth)\n" "$c_accent" "$c_reset"
            printf "  %b·%b SponsorBlock: Auto-skip intros and sponsor segments\n" "$c_accent" "$c_reset"
            printf "  %b·%b Subtitles: Auto-extract and embed softsubs\n" "$c_accent" "$c_reset"
            ;;
        audio)
            printf "%bACTION%b      %bExtract Standalone Audio Track%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bTARGET%b      %s\n" "$c_muted" "$c_reset" "${VGET_AUDIO_DIR:-$HOME/Music/vget}"
            printf "%bENGINES%b     yt-dlp (strict audio filter) + ffmpeg\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Pure audio stream: Zero video data downloaded\n" "$c_green" "$c_reset"
            printf "  %b·%b Formats: MP3 (320kbps), FLAC (lossless), M4A, WAV\n" "$c_accent" "$c_reset"
            printf "  %b·%b Metadata: ID3v2 tags and cover art embedding\n" "$c_accent" "$c_reset"
            printf "  %b·%b Normalization: EBU R128 loudness normalization\n" "$c_accent" "$c_reset"
            ;;
        stream)
            printf "%bACTION%b      %bInstant Stream Playback%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bSTORAGE%b     Zero disk write / No temp files\n" "$c_green" "$c_reset"
            printf "%bENGINES%b     mpv + yt-dlp direct pipe\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Instant start with hardware acceleration\n" "$c_accent" "$c_reset"
            printf "  %b·%b Minimal RAM and CPU consumption\n" "$c_accent" "$c_reset"
            printf "  %b·%b Supports YouTube, Twitch, Vimeo and direct HTTP\n" "$c_accent" "$c_reset"
            ;;
        search)
            printf "%bACTION%b      %bQuery Remote Media Platforms%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bENGINES%b     yt-dlp multi-search provider\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Live keyword query directly from terminal\n" "$c_accent" "$c_reset"
            printf "  %b·%b Interactive selection among top search matches\n" "$c_accent" "$c_reset"
            printf "  %b·%b Direct action dispatch (download or stream)\n" "$c_accent" "$c_reset"
            ;;
        gif)
            printf "%bACTION%b      %bCreate Animated GIF Clip%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bTARGET%b      %s\n" "$c_muted" "$c_reset" "${VGET_VIDEO_DIR:-$HOME/Videos/vget}"
            printf "%bENGINES%b     ffmpeg (two-pass palettegen + paletteuse)\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b High-precision clipping with --trim timestamps\n" "$c_accent" "$c_reset"
            printf "  %b·%b Color-quantized 256 palette optimization\n" "$c_accent" "$c_reset"
            printf "  %b·%b Smooth looping animation without artifacts\n" "$c_accent" "$c_reset"
            ;;
        history)
            printf "%bACTION%b      %bDisplay Download Ledger%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bDATABASE%b    %s\n\n" "$c_muted" "$c_reset" "${VGET_HISTORY_FILE:-$HOME/.local/share/vget/history.tsv}"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Tabular view of past downloads\n" "$c_accent" "$c_reset"
            printf "  %b·%b Records timestamps, target files and formats\n" "$c_accent" "$c_reset"
            ;;
        formats)
            printf "%bACTION%b      %bInspect Codecs & Streams (-F)%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bENGINES%b     yt-dlp format analyzer\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Lists all available video/audio container tracks\n" "$c_accent" "$c_reset"
            printf "  %b·%b Displays resolutions, bitrates, audio channels\n" "$c_accent" "$c_reset"
            ;;
        clipboard)
            printf "%bACTION%b      %bUse Clipboard URL%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bENGINES%b     wl-paste / xclip / xsel / pbpaste\n\n" "$c_muted" "$c_reset"
            printf "%bDETECTION%b   Auto-extracts URL currently in system clipboard\n" "$c_bold" "$c_reset"
            ;;
        deps)
            printf "%bACTION%b      %bEngine Diagnostics (--check-deps)%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bTARGETS%b     yt-dlp, ffmpeg, mpv, aria2c, clipboard\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Checks binary availability and PATH configuration\n" "$c_accent" "$c_reset"
            ;;
        update)
            printf "%bACTION%b      %bUpdate vget & yt-dlp%b\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "%bTARGETS%b     ~/.local/bin/vget and yt-dlp binary\n\n" "$c_muted" "$c_reset"
            printf "%bCAPABILITIES%b\n" "$c_bold" "$c_reset"
            printf "  %b·%b Synchronizes latest yt-dlp extractor patches\n" "$c_accent" "$c_reset"
            ;;
        1080p|720p|4k|best|480p|360p)
            printf "%bQUALITY%b     %b%s%b\n\n" "$c_bold" "$c_reset" "$c_title" "$key" "$c_reset"
            case "$key" in
                1080p) printf "Resolution:  1920x1080 (Full HD)\nBalance:     Optimal fidelity vs download speed (Recommended)\nCodecs:      H.264 / VP9 / AV1\n" ;;
                720p)  printf "Resolution:  1280x720 (Standard HD)\nBalance:     High speed, light bandwidth usage\nCodecs:      H.264 / VP9\n" ;;
                4k)    printf "Resolution:  3840x2160 (Ultra HD)\nBalance:     Maximum sharpness for 4K displays\nNote:        High bandwidth and storage consumption\n" ;;
                best)  printf "Resolution:  Highest available remote master\nNote:        Selects maximum resolution stream\n" ;;
                *)     printf "Resolution:  Standard / Data Saver\nUsage:       Ultra fast download for limited connectivity\n" ;;
            esac
            ;;
        mp3|flac|m4a|wav)
            printf "%bAUDIO FORMAT%b %b%s%b\n\n" "$c_bold" "$c_reset" "$c_title" "$key" "$c_reset"
            case "$key" in
                mp3)  printf "Codec:       MPEG-1 Audio Layer III (320kbps CBR)\nSupport:     Universal compatibility with all devices\nTags:        ID3v2 tags + embedded album art\n" ;;
                flac) printf "Codec:       Free Lossless Audio Codec\nFidelity:    Bit-perfect studio master quality\nTags:        Vorbis comments + embedded album art\n" ;;
                m4a)  printf "Codec:       Advanced Audio Coding (AAC)\nEfficiency:  Superior audio compression ratio\nSupport:     Apple, Android & modern hi-fi devices\n" ;;
                wav)  printf "Codec:       Raw Uncompressed PCM waveform\nUsage:       Audio engineering and studio production\n" ;;
            esac
            ;;
        quit)
            printf "%bACTION%b      %bExit Session%b\n\n" "$c_bold" "$c_reset" "$c_title" "$c_reset"
            printf "Closes interactive navigation without performing actions.\n"
            ;;
        *)
            printf "%bITEM%b        %s\n\n" "$c_bold" "$c_reset" "$raw_item"
            printf "Press Enter to select this option.\n"
            ;;
    esac
}

# Permet l'exécution directe comme script (pour fzf --preview)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    render_telescope_preview "${1:-}"
fi
