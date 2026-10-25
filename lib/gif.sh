#!/usr/bin/env bash
# ==============================================================================
# vget - Animated GIF Generator Module
# Role: Création de GIFs haute fidélité via FFmpeg avec palette optimisée
# ==============================================================================

[[ -n "${VGET_GIF_LOADED:-}" ]] && return 0
readonly VGET_GIF_LOADED=1

generate_gif() {
    local url="$1"
    local trim_start="${2:-}"
    local trim_end="${3:-}"
    local dest_dir="${4:-${VGET_VIDEO_DIR:-$HOME/Videos/vget}}"

    mkdir -p "$dest_dir"
    print_info "Préparation de l'extrait pour conversion GIF..."

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local raw_video="$tmp_dir/raw.mp4"
    local palette="$tmp_dir/palette.png"

    # Récupérer le titre
    local title
    title=$(yt-dlp --print "%(title)s" "$url" 2>/dev/null || echo "vget_gif")
    local safe_title
    safe_title="$(echo "$title" | tr -cd '[:alnum:] ._-' | tr ' ' '_')"
    local output_gif="$dest_dir/${safe_title}.gif"

    local ytdl_args=("-f" "bestvideo[height<=720]+bestaudio/best" "--merge-output-format" "mp4" "-o" "$raw_video")
    if [[ -n "$trim_start" && -n "$trim_end" ]]; then
        ytdl_args+=("--download-sections" "*${trim_start}-${trim_end}")
    fi

    # Téléchargement de la séquence
    if ! yt-dlp "${ytdl_args[@]}" "$url"; then
        rm -rf "$tmp_dir"
        print_error "Échec de récupération de la séquence vidéo pour le GIF."
        return 1
    fi

    print_info "Génération de la palette et encodage du GIF (FFmpeg)..."
    # Passe 1: Palettegen
    ffmpeg -hide_banner -v error -i "$raw_video" -vf "fps=15,scale=480:-1:flags=lanczos,palettegen" -y "$palette"
    # Passe 2: Paletteuse
    ffmpeg -hide_banner -v error -i "$raw_video" -i "$palette" -lavfi "fps=15,scale=480:-1:flags=lanczos [x]; [x][1:v] paletteuse" -y "$output_gif"

    rm -rf "$tmp_dir"

    print_success "GIF animé généré avec succès !"
    echo "  output : $output_gif"
    send_notification "vget - GIF généré" "$title"
    log_history "gif" "$title" "$url" "$output_gif"
}
