#!/usr/bin/env bash
# ==============================================================================
# vget - Dependencies Verification & Diagnostics Module
# Role: Détection des outils requis (yt-dlp, ffmpeg, mpv) et optionnels (fzf)
# ==============================================================================

[[ -n "${VGET_DEPS_LOADED:-}" ]] && return 0
readonly VGET_DEPS_LOADED=1

# Outils requis et optionnels
readonly REQUIRED_DEPS=("yt-dlp" "ffmpeg" "mpv")
readonly OPTIONAL_DEPS=("fzf")

# Retourne la commande d'installation recommandée selon le système hôte
get_install_hint() {
    local missing=("$@")
    if command -v apt-get >/dev/null 2>&1; then
        echo "sudo apt update && sudo apt install -y ${missing[*]}"
    elif command -v pacman >/dev/null 2>&1; then
        echo "sudo pacman -S --noconfirm ${missing[*]}"
    elif command -v dnf >/dev/null 2>&1; then
        echo "sudo dnf install -y ${missing[*]}"
    elif command -v brew >/dev/null 2>&1; then
        echo "brew install ${missing[*]}"
    else
        echo "Installez manuellement via le gestionnaire de paquets de votre OS: ${missing[*]}"
    fi
}

# Vérifie si les dépendances nécessaires pour un mode donné sont présentes
# Arguments: mode ("all", "video", "audio", "play", "formats", "search")
check_dependencies() {
    local target_mode="${1:-all}"
    local verbose="${2:-false}"
    local -a required=()
    local missing_req=()

    case "$target_mode" in
        play)
            required=("yt-dlp" "mpv")
            ;;
        audio)
            required=("yt-dlp" "ffmpeg")
            ;;
        video)
            required=("yt-dlp" "ffmpeg")
            ;;
        formats|search)
            required=("yt-dlp")
            ;;
        all|true)
            required=("${REQUIRED_DEPS[@]}")
            [[ "$target_mode" == "true" ]] && verbose="true"
            ;;
        *)
            required=("yt-dlp")
            ;;
    esac

    for dep in "${required[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            if [[ "$verbose" == "true" ]]; then
                local ver
                ver=$("$dep" --version 2>/dev/null | head -n1 || echo "installé")
                print_success "Requis: $dep ($ver)"
            fi
        else
            missing_req+=("$dep")
            if [[ "$verbose" == "true" ]]; then
                print_error "Requis manquant: $dep"
            fi
        fi
    done

    # Affichage des outils optionnels en mode verbeux
    if [[ "$verbose" == "true" ]]; then
        for dep in "${OPTIONAL_DEPS[@]}"; do
            if command -v "$dep" >/dev/null 2>&1; then
                local ver
                ver=$("$dep" --version 2>/dev/null | head -n1 || echo "installé")
                print_success "Optionnel: $dep ($ver)"
            else
                print_warning "Optionnel manquant: $dep (recommandé pour un meilleur menu interactif)"
            fi
        done
    fi

    if [[ ${#missing_req[@]} -gt 0 ]]; then
        if [[ "$verbose" != "true" ]]; then
            print_error "Outil(s) requis manquant(s) pour le mode '$target_mode': ${missing_req[*]}"
            print_info "Commande pour installer: $(get_install_hint "${missing_req[@]}")"
        fi
        return 1
    fi

    return 0
}

# Affiche le rapport complet de diagnostic (--check-deps)
show_deps_status() {
    print_banner
    print_info "Vérification des dépendances système de vget..."
    echo ""
    if check_dependencies "true"; then
        echo ""
        print_success "Toutes les dépendances requises sont opérationnelles !"
        return 0
    else
        echo ""
        print_error "Certaines dépendances obligatoires sont absentes."
        return 1
    fi
}
