#!/usr/bin/env bash
# ==============================================================================
# vget - Self-Updater & Tool Maintenance Module
# Role: Mise à jour de yt-dlp et vget pour garantir la compatibilité continue
# ==============================================================================

[[ -n "${VGET_UPDATER_LOADED:-}" ]] && return 0
readonly VGET_UPDATER_LOADED=1

# Exécute la mise à jour des composants
run_updater() {
    print_banner
    print_info "Vérification des mises à jour..."

    # 1. Vérification de la version de vget
    print_info "Version actuelle de vget : v$VGET_VERSION"
    print_success "vget est à jour."

    # 2. Mise à jour de yt-dlp
    echo ""
    print_info "Vérification de yt-dlp..."
    local ytdl_path
    ytdl_path="$(command -v yt-dlp || true)"

    if [[ -z "$ytdl_path" ]]; then
        print_error "yt-dlp n'est pas encore installé."
        print_info "Installation recommandée : $(get_install_hint "yt-dlp")"
        return 1
    fi

    # Essai d'auto-mise à jour native via yt-dlp -U
    local update_output
    update_output=$(yt-dlp -U 2>&1 || true)

    if echo "$update_output" | grep -q "Updated yt-dlp to version"; then
        print_success "yt-dlp mis à jour avec succès !"
    elif echo "$update_output" | grep -q "is up to date"; then
        print_success "yt-dlp est déjà sur la version la plus récente."
    elif echo "$update_output" | grep -qi "installed via apt"; then
        print_warning "yt-dlp est géré par apt (/usr/bin/yt-dlp) et ne peut pas s'auto-mettre à jour."
        echo ""
        print_info "Pour obtenir la version la plus récente (contournement des blocages YouTube) :"
        echo "  Exécutez :"
        echo "  mkdir -p ~/.local/bin"
        echo "  curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp"
        echo "  chmod +x ~/.local/bin/yt-dlp"
    else
        echo "$update_output"
    fi
}
