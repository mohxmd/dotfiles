#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# WAYBAR LAUNCHER
# ─────────────────────────────────────────────────────────────

# Prevent race conditions with flock
exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# Kill existing instances
killall waybar 2>/dev/null || true
pkill -x waybar 2>/dev/null || true
sleep 0.3

# Check if disabled
if [[ -f "$HOME/.config/waybar/.disabled" ]]; then
    echo "Waybar is disabled."
    flock -u 200
    exec 200>&-
    exit 0
fi

# Determine active theme (default: modern)
theme="modern"
theme_state="$HOME/.config/waybar/current_theme"
if [[ -f "$theme_state" ]]; then
    saved_theme="$(tr -d '[:space:]' < "$theme_state")"
    if [[ -d "$HOME/.config/waybar/themes/$saved_theme" ]]; then
        theme="$saved_theme"
    fi
fi

config_file="$HOME/.config/waybar/themes/$theme/config"
style_file="$HOME/.config/waybar/themes/$theme/style.css"

if [[ ! -f "$config_file" || ! -f "$style_file" ]]; then
    echo "Warning: Theme $theme missing config or style.css, falling back to modern..." >&2
    theme="modern"
    config_file="$HOME/.config/waybar/themes/modern/config"
    style_file="$HOME/.config/waybar/themes/modern/style.css"
fi

echo "Launching Waybar (theme: $theme)..."
waybar -c "$config_file" -s "$style_file" &

flock -u 200
exec 200>&-