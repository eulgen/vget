#!/usr/bin/env bash
# ==============================================================================
# vget - Universal System Notification Module
# Role: Envoi de notifications natives (Linux notify-send, macOS osascript, Windows PowerShell)
# ==============================================================================

[[ -n "${VGET_NOTIFY_LOADED:-}" ]] && return 0
readonly VGET_NOTIFY_LOADED=1

send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"

    [[ "${VGET_ENABLE_NOTIFY:-true}" == "false" ]] && return 0

    # 1. Linux Desktop
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" -a "vget" -i "video-x-generic" "$title" "$message" 2>/dev/null || true
    # 2. macOS Notification Center
    elif command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    # 3. Windows PowerShell Toast / Balloon
    elif command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command \
            "[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null" 2>/dev/null || true
    # 4. Android Termux
    elif command -v termux-notification >/dev/null 2>&1; then
        termux-notification --title "$title" --content "$message" 2>/dev/null || true
    fi
}
