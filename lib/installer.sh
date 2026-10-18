#!/usr/bin/env bash
# ==============================================================================
# vget - System Initializer & Global PATH Installer Module
# Role: Déploie vget, configure le PATH global et l'autocomplétion du shell
# ==============================================================================

[[ -n "${VGET_INSTALLER_LOADED:-}" ]] && return 0
readonly VGET_INSTALLER_LOADED=1

run_init() {
    print_banner
    print_info "Initialisation et intégration de vget dans le PATH global..."
    echo ""

    local target_bin="$HOME/.local/bin"
    local target_lib="$HOME/.local/share/vget/lib"
    local target_comp="$HOME/.local/share/bash-completion/completions"

    # Récupération du dossier source du projet
    local src_dir
    src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # 1. Création des répertoires cibles
    mkdir -p "$target_bin" "$target_lib" "$target_comp"

    # 2. Copie des bibliothèques et du binaire
    print_info "Copie des modules dans $target_lib..."
    cp "$src_dir"/lib/*.sh "$target_lib/"

    print_info "Installation de l'exécutable dans $target_bin/vget..."
    cp "$src_dir/bin/vget" "$target_bin/vget"
    chmod +x "$target_bin/vget"

    # 3. Installation de l'autocomplétion Bash
    if [[ -f "$src_dir/completions/vget.bash" ]]; then
        print_info "Configuration de l'autocomplétion Bash..."
        cp "$src_dir/completions/vget.bash" "$target_comp/vget"
    fi

    # 4. Configuration permanente du PATH dans les fichiers RC de shell
    local updated_rc="false"
    local path_export="export PATH=\"\$HOME/.local/bin:\$PATH\""
    local comp_source="[[ -f \"\$HOME/.local/share/bash-completion/completions/vget\" ]] && source \"\$HOME/.local/share/bash-completion/completions/vget\""

    # Configuration ~/.bashrc
    local bashrc="$HOME/.bashrc"
    if [[ -f "$bashrc" ]]; then
        if ! grep -q '\.local/bin' "$bashrc"; then
            printf "\n# Added by vget init\n%s\n" "$path_export" >> "$bashrc"
            updated_rc="true"
        fi
        if ! grep -q 'bash-completion/completions/vget' "$bashrc"; then
            printf "%s\n" "$comp_source" >> "$bashrc"
            updated_rc="true"
        fi
    fi

    # Configuration ~/.zshrc si présent
    local zshrc="$HOME/.zshrc"
    if [[ -f "$zshrc" ]] && ! grep -q '\.local/bin' "$zshrc"; then
        printf "\n# Added by vget init\n%s\n" "$path_export" >> "$zshrc"
        updated_rc="true"
    fi

    echo ""
    print_success "vget est désormais installé et configuré globalement !"
    echo ""
    echo "  📍 Emplacement binaire : $target_bin/vget"
    echo "  📚 Bibliothèques      : $target_lib"
    echo "  ⌨️  Autocomplétion     : $target_comp/vget"
    echo ""

    if [[ "$updated_rc" == "true" ]]; then
        print_info "Fichier(s) shell mis à jour (~/.bashrc)."
        print_info "Pour appliquer immédiatement dans ce terminal, exécutez :"
        printf "%b  source ~/.bashrc%b\n\n" "${CLR_PRIMARY}${CLR_BOLD}" "${CLR_RESET}"
    fi

    echo ""
    print_info "Diagnostic des dépendances système :"
    check_dependencies "all" "false" || true

    print_success "Vous pouvez désormais exécuter 'vget' depuis n'importe quel dossier !"
}
