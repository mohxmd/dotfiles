#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# WAYBAR THEME SWITCHER
# Interactive Rofi menu to switch between Waybar themes.
# ─────────────────────────────────────────────────────────────

set -euo pipefail

THEME_DIR="$HOME/.config/waybar/themes"
STATE_FILE="$HOME/.config/waybar/current_theme"

if [[ $# -gt 0 ]]; then
    chosen="$1"
else
    options="$(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort)"
    [[ -z "$options" ]] && options="modern"$'\n'"minimal"
    chosen="$(echo "$options" | rofi -dmenu -i -p "Waybar Theme" -config "$HOME/.config/rofi/config-compact.rasi")"
fi

[[ -z "$chosen" ]] && exit 0

if [[ -d "$THEME_DIR/$chosen" ]]; then
    echo "$chosen" > "$STATE_FILE"
    echo "Switched Waybar theme to: $chosen"
    "$HOME/.config/waybar/launch.sh"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Waybar Theme" "Switched to $chosen" -i preferences-desktop-theme
    fi
else
    echo "Unknown theme: $chosen" >&2
    exit 1
fi
