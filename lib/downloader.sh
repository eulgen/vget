#!/usr/bin/env bash
# ==============================================================================
# vget - Media Downloader & Extraction Engine
# Role: Orchestration des téléchargements et conversions via yt-dlp et ffmpeg
# ==============================================================================

[[ -n "${VGET_DOWNLOADER_LOADED:-}" ]] && return 0
readonly VGET_DOWNLOADER_LOADED=1

get_quality_filter() {
    local q="${1:-1080p}"
    local eff="${2:-false}"
    if [[ "$eff" == "true" ]]; then
        case "$q" in
            720p)  echo "bestvideo[height<=720][vcodec^=av01]+bestaudio/bestvideo[height<=720][vcodec^=vp9]+bestaudio/bestvideo[height<=720]+bestaudio/best" ;;
            1080p) echo "bestvideo[height<=1080][vcodec^=av01]+bestaudio/bestvideo[height<=1080][vcodec^=vp9]+bestaudio/bestvideo[height<=1080]+bestaudio/best" ;;
            4k)    echo "bestvideo[height<=2160][vcodec^=av01]+bestaudio/bestvideo[height<=2160][vcodec^=vp9]+bestaudio/bestvideo[height<=2160]+bestaudio/best" ;;
            *)     echo "bestvideo[vcodec^=av01]+bestaudio/bestvideo[vcodec^=vp9]+bestaudio/bestvideo+bestaudio/best" ;;
        esac
        return 0
    fi

    case "$q" in
        144p)       echo "bestvideo[height<=144]+bestaudio/best[height<=144]/best" ;;
        240p)       echo "bestvideo[height<=240]+bestaudio/best[height<=240]/best" ;;
        360p)       echo "bestvideo[height<=360]+bestaudio/best[height<=360]/best" ;;
        400p|480p)  echo "bestvideo[height<=480]+bestaudio/best[height<=480]/best" ;;
        720p)       echo "bestvideo[height<=720]+bestaudio/best[height<=720]/best" ;;
        1080p)      echo "bestvideo[height<=1080]+bestaudio/best[height<=1080]/best" ;;
        4k)         echo "bestvideo[height<=2160]+bestaudio/best[height<=2160]/best" ;;
        best)       echo "bestvideo+bestaudio/best" ;;
        *)          echo "$q" ;;
    esac
}

list_media_formats() {
    local url="${1:-}"
    [[ -z "$url" ]] && { print_error "URL manquante pour l'inspection des formats."; return 1; }
    print_info "Analyse des formats disponibles pour: $url"
    yt-dlp -F "$url"
}

execute_download() {
    local dest_dir="${OUTPUT_DIR:-}"
    if [[ -z "$dest_dir" ]]; then
        [[ "$MODE" == "audio" ]] && dest_dir="$VGET_AUDIO_DIR" || dest_dir="$VGET_VIDEO_DIR"
    fi
    init_vget_dirs "$dest_dir"

    if [[ -z "${TARGET_URL:-}" && -z "${BATCH_FILE:-}" ]]; then
        print_error "Aucune URL ou fichier batch fourni."
        return 1
    fi

    local -a cmd=("yt-dlp" "--continue" "--retries" "5" "--fragment-retries" "10")
    cmd+=("--concurrent-fragments" "${VGET_CONCURRENT_FRAGMENTS:-5}")

    # Accélération multi-connexions aria2c
    if [[ "${FAST:-false}" == "true" ]]; then
        if command -v aria2c >/dev/null 2>&1; then
            cmd+=("--downloader" "aria2c")
            cmd+=("--downloader-args" "aria2c:-x 16 -s 16 -k 1M -j 4 --min-split-size=1M")
            print_info "Accélération aria2c multi-connexions active (16 flux TCP parallèles)."
        else
            print_warning "aria2c non détecté. Utilisation du téléchargeur natif."
        fi
    fi

    # Déduplication et archive
    if [[ "${USE_ARCHIVE:-false}" == "true" ]]; then
        local arch_file="${VGET_ARCHIVE_FILE:-${XDG_DATA_HOME:-$HOME/.local/share}/vget/archive.txt}"
        mkdir -p "$(dirname "$arch_file")"
        cmd+=("--download-archive" "$arch_file")
        print_info "Déduplication active via archive: $arch_file"
    fi

    # Injection des cookies navigateur
    if [[ -n "${COOKIES_BROWSER:-}" ]]; then
        local b="$COOKIES_BROWSER"
        if [[ "$b" == "auto" ]]; then
            for cand in firefox chrome brave chromium vivaldi; do
                if command -v "$cand" >/dev/null 2>&1; then b="$cand"; break; fi
            done
            [[ "$b" == "auto" ]] && b="firefox"
        fi
        cmd+=("--cookies-from-browser" "$b")
        print_info "Utilisation des cookies du navigateur : $b"
    fi

    # Mode audio strict (ne télécharge QUE l'audio) ou vidéo
    if [[ "$MODE" == "audio" ]]; then
        cmd+=("-f" "bestaudio/best" "-x" "--audio-format" "$AUDIO_FORMAT" "--audio-quality" "0" "--embed-metadata")
        command -v ffmpeg >/dev/null 2>&1 && cmd+=("--embed-thumbnail")
        if [[ "${LOUDNORM:-false}" == "true" ]]; then
            cmd+=("--postprocessor-args" "ExtractAudio:-af loudnorm=I=-16:TP=-1.5:LRA=11")
            print_info "Normalisation sonore EBU R128 activée."
        fi
    else
        cmd+=("-f" "$(get_quality_filter "$QUALITY" "${EFFICIENT:-false}")" "--merge-output-format" "mp4")
        [[ "${EFFICIENT:-false}" == "true" ]] && print_info "Sélecteur haute efficacité actif (priorité AV1/VP9, -40% bande passante)."
    fi

    [[ -n "${TRIM_START:-}" && -n "${TRIM_END:-}" ]] && cmd+=("--download-sections" "*${TRIM_START}-${TRIM_END}" "--force-keyframes-at-cuts")
    [[ "$SPONSORBLOCK" == "true" ]] && cmd+=("--sponsorblock-remove" "sponsor,intro,outro,selfpromo,preview")
    if [[ -n "${SUB_LANGS:-}" ]]; then
        cmd+=("--write-subs" "--embed-subs")
        [[ "$SUB_LANGS" != "all" ]] && cmd+=("--sub-langs" "$SUB_LANGS")
    fi
    [[ -n "${LIMIT_RATE:-}" ]] && cmd+=("--limit-rate" "$LIMIT_RATE")

    if [[ "$DRY_RUN" == "true" ]]; then
        cmd+=("--simulate" "--print" "Titre: %(title)s | Résolution: %(resolution)s | Durée: %(duration_string)s")
    fi

    [[ "$ORGANIZE" == "true" ]] && cmd+=("-o" "$dest_dir/%(uploader,channel|Inconnu)s/%(title)s.%(ext)s") || cmd+=("-o" "$dest_dir/%(title)s.%(ext)s")

    if [[ -n "${BATCH_FILE:-}" ]]; then
        [[ ! -f "$BATCH_FILE" ]] && { print_error "Fichier batch introuvable: $BATCH_FILE"; return 1; }
        cmd+=("-a" "$BATCH_FILE")
        print_info "Téléchargement par lot depuis: $BATCH_FILE vers $dest_dir"
    else
        cmd+=("$TARGET_URL")
        print_info "Traitement ($MODE - ${QUALITY:-$AUDIO_FORMAT}) vers: $dest_dir"
    fi

    "${cmd[@]}"
    local ret=$?
    if [[ $ret -eq 0 && "$DRY_RUN" != "true" ]]; then
        print_success "Terminé avec succès dans: $dest_dir"
        # shellcheck source=/dev/null
        source "$LIB_DIR/notify.sh"
        # shellcheck source=/dev/null
        source "$LIB_DIR/history.sh"
        send_notification "vget - Téléchargement terminé" "Fichier disponible dans $dest_dir"
        log_history "$MODE" "${TARGET_URL##*/}" "${TARGET_URL:-batch}" "$dest_dir"
    fi
    return $ret
}
