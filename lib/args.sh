#!/usr/bin/env bash
# ==============================================================================
# vget - CLI Arguments Parser Module
# Role: Analyse, validation et dispatch des options de la ligne de commande
# ==============================================================================

[[ -n "${VGET_ARGS_LOADED:-}" ]] && return 0
readonly VGET_ARGS_LOADED=1

# Variables d'état globales pour les arguments
export MODE="video"
export TARGET_URL=""
export QUALITY="${VGET_DEFAULT_VIDEO_QUALITY:-1080p}"
export AUDIO_FORMAT="${VGET_DEFAULT_AUDIO_FORMAT:-mp3}"
export OUTPUT_DIR=""
export TRIM_START=""
export TRIM_END=""
export LIMIT_RATE=""
export SUB_LANGS=""
export SPONSORBLOCK="false"
export ORGANIZE="false"
export DRY_RUN="false"
export BATCH_FILE=""
export SEARCH_QUERY=""
export LOUDNORM="false"
export COOKIES_BROWSER=""
export VGET_ENABLE_NOTIFY="true"
export FAST="${VGET_FAST:-false}"
export EFFICIENT="${VGET_EFFICIENT:-false}"
export USE_ARCHIVE="${VGET_USE_ARCHIVE:-false}"

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help; exit 0 ;;
            -V|--version) echo "vget v$VGET_VERSION"; exit 0 ;;
            init|--init) MODE="init"; shift ;;
            --check-deps) show_deps_status; exit $? ;;
            --history) MODE="history"; shift ;;
            -i|--interactive) MODE="interactive"; shift ;;
            -p|--play) MODE="play"; shift ;;
            --gif) MODE="gif"; shift ;;
            --fast|--aria2) FAST="true"; shift ;;
            --efficient) EFFICIENT="true"; shift ;;
            --archive) USE_ARCHIVE="true"; shift ;;
            -s|--search) MODE="search"; SEARCH_QUERY="${2:-}"; shift 2 ;;
            -c|--clipboard)
                # shellcheck source=/dev/null
                source "$LIB_DIR/clipboard.sh"
                local clip_url
                clip_url="$(get_clipboard_url || true)"
                if [[ -n "$clip_url" ]]; then
                    TARGET_URL="$clip_url"
                    print_info "URL récupérée du presse-papier: $TARGET_URL"
                else
                    print_warning "Aucune URL trouvée dans le presse-papier."
                fi
                shift ;;
            -v|--video)
                MODE="video"
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then QUALITY="$2"; shift 2; else shift; fi ;;
            -a|--audio)
                MODE="audio"
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then AUDIO_FORMAT="$2"; shift 2; else shift; fi ;;
            --loudnorm) LOUDNORM="true"; shift ;;
            --cookies-browser)
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then COOKIES_BROWSER="$2"; shift 2; else COOKIES_BROWSER="auto"; shift; fi ;;
            --no-notify) VGET_ENABLE_NOTIFY="false"; shift ;;
            -F|--formats) MODE="formats"; shift ;;
            -n|--dry-run|--simulate) DRY_RUN="true"; shift ;;
            --sponsorblock) SPONSORBLOCK="true"; shift ;;
            --organize) ORGANIZE="true"; shift ;;
            --trim) TRIM_START="${2:-}"; TRIM_END="${3:-}"; shift 3 ;;
            --sub)
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then SUB_LANGS="$2"; shift 2; else SUB_LANGS="all"; shift; fi ;;
            -b|--batch) BATCH_FILE="${2:-}"; shift 2 ;;
            -l|--limit-rate) LIMIT_RATE="${2:-}"; shift 2 ;;
            -o|--output) OUTPUT_DIR="${2:-}"; shift 2 ;;
            --update) MODE="update"; shift ;;
            *)
                if [[ -z "$TARGET_URL" && ! "$1" =~ ^- ]]; then
                    TARGET_URL="$1"
                    shift
                else
                    print_error "Argument inconnu ou inattendu: $1"
                    show_help
                    exit 1
                fi
                ;;
        esac
    done
}
