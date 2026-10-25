#!/usr/bin/env bash
# ==============================================================================
# vget - System Initializer & Cross-Platform Installer Module
# Role: Déploie vget, configure le PATH, les autocomplétions et les lanceurs OS
# ==============================================================================

[[ -n "${VGET_INSTALLER_LOADED:-}" ]] && return 0
readonly VGET_INSTALLER_LOADED=1

run_init() {
    print_banner
    print_info "Initialisation et intégration de vget dans l'environnement système..."
    echo ""

    local target_bin="$HOME/.local/bin"
    local target_lib="$HOME/.local/share/vget/lib"
    local target_bash_comp="$HOME/.local/share/bash-completion/completions"
    local target_zsh_comp="$HOME/.local/share/zsh/site-functions"
    local target_fish_comp="${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions"
    local target_icons="$HOME/.local/share/icons/hicolor/scalable/apps"
    local target_apps="$HOME/.local/share/applications"

    local src_dir
    src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # 1. Création des répertoires cibles
    mkdir -p "$target_bin" "$target_lib" "$target_bash_comp" "$target_zsh_comp" "$target_fish_comp"

    # 2. Copie des bibliothèques et du binaire exécutable
    print_info "Copie des modules dans $target_lib..."
    cp "$src_dir"/lib/*.sh "$target_lib/"

    print_info "Installation de l'exécutable dans $target_bin/vget..."
    cp "$src_dir/bin/vget" "$target_bin/vget"
    chmod +x "$target_bin/vget"

    # Wrappers natifs Windows pour CMD et PowerShell
    if [[ -f "$src_dir/vget.cmd" ]]; then
        cp "$src_dir/vget.cmd" "$target_bin/vget.cmd"
    fi
    if [[ -f "$src_dir/vget.ps1" ]]; then
        cp "$src_dir/vget.ps1" "$target_bin/vget.ps1"
    fi

    # 3. Installation des autocomplétions multi-shells (Bash, Zsh, Fish)
    if [[ -f "$src_dir/completions/vget.bash" ]]; then
        cp "$src_dir/completions/vget.bash" "$target_bash_comp/vget"
    fi
    if [[ -f "$src_dir/completions/_vget" ]]; then
        cp "$src_dir/completions/_vget" "$target_zsh_comp/_vget"
    fi
    if [[ -f "$src_dir/completions/vget.fish" ]]; then
        cp "$src_dir/completions/vget.fish" "$target_fish_comp/vget.fish"
    fi

    # 4. Intégration Desktop Linux XDG
    if [[ "${VGET_PLATFORM:-linux}" == "linux" && -f "$src_dir/assets/vget.svg" ]]; then
        mkdir -p "$target_icons" "$target_apps"
        cp "$src_dir/assets/vget.svg" "$target_icons/vget.svg"
        cat << "EOF" > "$target_apps/vget.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=vget
GenericName=Media Downloader
Comment=Universal Video & Audio CLI Hub
Exec=vget
Icon=vget
Terminal=true
Categories=AudioVideo;Audio;Video;Network;
Keywords=youtube;download;video;audio;stream;mpv;yt-dlp;
EOF
    fi

    # 5. Configuration permanente du PATH dans les fichiers RC de shell
    local updated_rc="false"
    local path_export="export PATH=\"\$HOME/.local/bin:\$PATH\""

    for rc_file in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [[ -f "$rc_file" ]] && ! grep -q '\.local/bin' "$rc_file"; then
            printf "\n# Added by vget init\n%s\n" "$path_export" >> "$rc_file"
            updated_rc="true"
        fi
    done

    local zshrc="$HOME/.zshrc"
    if [[ -f "$zshrc" ]]; then
        if ! grep -q '\.local/bin' "$zshrc"; then
            printf "\n# Added by vget init\n%s\n" "$path_export" >> "$zshrc"
            updated_rc="true"
        fi
        if ! grep -q 'site-functions' "$zshrc"; then
            printf "fpath=(\"\$HOME/.local/share/zsh/site-functions\" \$fpath)\n" >> "$zshrc"
            updated_rc="true"
        fi
    fi

    echo ""
    print_success "vget est désormais installé et configuré globalement !"
    echo "  binary     : $target_bin/vget"
    echo "  libraries  : $target_lib"
    echo "  completions: Bash, Zsh (_vget), Fish (vget.fish)"
    [[ "${VGET_PLATFORM:-linux}" == "linux" ]] && echo "  desktop    : $target_apps/vget.desktop"
    echo ""

    if [[ "$updated_rc" == "true" ]]; then
        print_info "Fichier(s) shell configurés pour le PATH global."
    fi

    echo ""
    print_info "Diagnostic des dépendances système :"
    check_dependencies "all" "false" || true

    print_success "Vous pouvez désormais exécuter 'vget' depuis n'importe quel dossier !"
}
