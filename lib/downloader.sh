#!/usr/bin/env bash
# ==============================================================================
# vget - Media Downloader & Extraction Engine
# Role: Orchestration des téléchargements et conversions via yt-dlp et ffmpeg
# ==============================================================================

[[ -n "${VGET_DOWNLOADER_LOADED:-}" ]] && return 0
readonly VGET_DOWNLOADER_LOADED=1

# Formate le sélecteur yt-dlp selon la résolution demandée
get_quality_filter() {
    local q="${1:-1080p}"
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

# Affiche la liste des formats disponibles (-F)
list_media_formats() {
    local url="${1:-}"
    if [[ -z "$url" ]]; then
        print_error "URL manquante pour l'inspection des formats."
        return 1
    fi
    print_info "Analyse des formats disponibles pour: $url"
    yt-dlp -F "$url"
}

# Construit et exécute la commande de téléchargement
execute_download() {
    local dest_dir
    if [[ -n "${OUTPUT_DIR:-}" ]]; then
        dest_dir="$OUTPUT_DIR"
    elif [[ "$MODE" == "audio" ]]; then
        dest_dir="$VGET_AUDIO_DIR"
    else
        dest_dir="$VGET_VIDEO_DIR"
    fi
    init_vget_dirs "$dest_dir"

    # Vérification de la cible (URL unique ou fichier batch)
    if [[ -z "${TARGET_URL:-}" && -z "${BATCH_FILE:-}" ]]; then
        print_error "Aucune URL ou fichier batch fourni."
        return 1
    fi

    local -a cmd=("yt-dlp")
    cmd+=("--continue" "--retries" "5" "--fragment-retries" "10")

    # Mode Audio ou Vidéo
    if [[ "$MODE" == "audio" ]]; then
        cmd+=("-x" "--audio-format" "$AUDIO_FORMAT" "--audio-quality" "0")
        cmd+=("--embed-metadata")
        if command -v ffmpeg >/dev/null 2>&1; then
            cmd+=("--embed-thumbnail")
        fi
    else
        cmd+=("-f" "$(get_quality_filter "$QUALITY")" "--merge-output-format" "mp4")
    fi

    # Découpage (Trim)
    if [[ -n "${TRIM_START:-}" && -n "${TRIM_END:-}" ]]; then
        cmd+=("--download-sections" "*${TRIM_START}-${TRIM_END}" "--force-keyframes-at-cuts")
    fi

    # SponsorBlock
    if [[ "$SPONSORBLOCK" == "true" ]]; then
        cmd+=("--sponsorblock-remove" "sponsor,intro,outro,selfpromo,preview")
    fi

    # Sous-titres
    if [[ -n "${SUB_LANGS:-}" ]]; then
        cmd+=("--write-subs" "--embed-subs")
        [[ "$SUB_LANGS" != "all" ]] && cmd+=("--sub-langs" "$SUB_LANGS")
    fi

    # Limitation de bande passante
    [[ -n "${LIMIT_RATE:-}" ]] && cmd+=("--limit-rate" "$LIMIT_RATE")

    # Mode Simulation (Dry-Run)
    if [[ "$DRY_RUN" == "true" ]]; then
        cmd+=("--simulate" "--print" "Titre: %(title)s | Résolution: %(resolution)s | Durée: %(duration_string)s")
    fi

    # Modèle de nommage et organisation
    if [[ "$ORGANIZE" == "true" ]]; then
        cmd+=("-o" "$dest_dir/%(uploader,channel|Inconnu)s/%(title)s.%(ext)s")
    else
        cmd+=("-o" "$dest_dir/%(title)s.%(ext)s")
    fi

    # Fichier batch ou URL directe
    if [[ -n "${BATCH_FILE:-}" ]]; then
        if [[ ! -f "$BATCH_FILE" ]]; then
            print_error "Le fichier batch n'existe pas: $BATCH_FILE"
            return 1
        fi
        cmd+=("-a" "$BATCH_FILE")
        print_info "Téléchargement par lot depuis: $BATCH_FILE vers $dest_dir"
    else
        cmd+=("$TARGET_URL")
        print_info "Traitement ($MODE - ${QUALITY:-$AUDIO_FORMAT}) vers: $dest_dir"
    fi

    # Exécution finale
    "${cmd[@]}"
    local ret=$?
    if [[ $ret -eq 0 && "$DRY_RUN" != "true" ]]; then
        print_success "Terminé avec succès dans: $dest_dir"
    fi
    return $ret
}
