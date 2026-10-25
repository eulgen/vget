#!/usr/bin/env bash
# ==============================================================================
# vget - Universal Clipboard Detection Module
# Role: Détection multi-plateforme des URLs (Wayland, X11, macOS, Windows Git Bash/WSL)
# ==============================================================================

[[ -n "${VGET_CLIPBOARD_LOADED:-}" ]] && return 0
readonly VGET_CLIPBOARD_LOADED=1

# Récupère le texte brut du presse-papier selon l'OS et l'environnement
get_clipboard_text() {
    # 1. Wayland Linux
    if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-paste >/dev/null 2>&1; then
        wl-paste --no-newline 2>/dev/null || true
    # 2. X11 Linux
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard -o 2>/dev/null || true
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --output 2>/dev/null || true
    # 3. macOS
    elif command -v pbpaste >/dev/null 2>&1; then
        pbpaste 2>/dev/null || true
    # 4. Windows Git Bash / MSYS2 (/dev/clipboard natif ultra-rapide)
    elif [[ -r /dev/clipboard ]]; then
        cat /dev/clipboard 2>/dev/null || true
    # 5. Windows WSL / PowerShell CLI
    elif command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command Get-Clipboard 2>/dev/null | tr -d '\r' || true
    # 6. Android Termux
    elif command -v termux-clipboard-get >/dev/null 2>&1; then
        termux-clipboard-get 2>/dev/null || true
    else
        return 1
    fi
}

# Extrait la première URL valide (http ou https) trouvée dans le presse-papier
get_clipboard_url() {
    local content
    content="$(get_clipboard_text 2>/dev/null || true)"
    if [[ -z "$content" ]]; then
        return 1
    fi

    local url
    url="$(grep -Eo 'https?://[^ ]+' <<< "$content" | head -n 1 || true)"
    if [[ -n "$url" ]]; then
        echo "$url"
        return 0
    fi
    return 1
}
