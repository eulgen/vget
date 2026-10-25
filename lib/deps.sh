#!/usr/bin/env bash
# ==============================================================================
# vget - Dependencies Verification & Diagnostics Module
# Role: Détection des outils requis (yt-dlp, ffmpeg, mpv) et optionnels (fzf, aria2c)
# ==============================================================================

[[ -n "${VGET_DEPS_LOADED:-}" ]] && return 0
readonly VGET_DEPS_LOADED=1

readonly REQUIRED_DEPS=("yt-dlp" "ffmpeg" "mpv")
readonly OPTIONAL_DEPS=("fzf" "aria2c")

get_install_hint() {
    local missing=("$@")
    if command -v brew >/dev/null 2>&1; then
        echo "brew install ${missing[*]}"
    elif command -v apt-get >/dev/null 2>&1; then
        echo "sudo apt update && sudo apt install -y ${missing[*]}"
    elif command -v pacman >/dev/null 2>&1; then
        echo "sudo pacman -S --noconfirm ${missing[*]}"
    elif command -v dnf >/dev/null 2>&1; then
        echo "sudo dnf install -y ${missing[*]}"
    elif command -v winget.exe >/dev/null 2>&1 || command -v winget >/dev/null 2>&1; then
        echo "winget install ${missing[*]}"
    elif command -v scoop >/dev/null 2>&1; then
        echo "scoop install ${missing[*]}"
    elif command -v choco >/dev/null 2>&1; then
        echo "choco install ${missing[*]}"
    elif command -v pkg >/dev/null 2>&1; then
        echo "pkg install ${missing[*]}"
    else
        echo "Installez manuellement via le gestionnaire de paquets de votre OS: ${missing[*]}"
    fi
}

check_dependencies() {
    local target_mode="${1:-all}"
    local verbose="${2:-false}"
    local -a required=()
    local missing_req=()

    case "$target_mode" in
        play)
            required=("yt-dlp" "mpv")
            ;;
        audio|video)
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

    if [[ "$verbose" == "true" ]]; then
        for dep in "${OPTIONAL_DEPS[@]}"; do
            if command -v "$dep" >/dev/null 2>&1; then
                local ver
                ver=$("$dep" --version 2>/dev/null | head -n1 || echo "installé")
                print_success "Optionnel: $dep ($ver)"
            else
                print_warning "Optionnel manquant: $dep (recommandé pour une expérience optimale)"
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
