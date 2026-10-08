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

config_file="$HOME/.config/waybar/themes/modern/config"
style_file="$HOME/.config/waybar/themes/modern/style.css"

echo "Launching Waybar..."
waybar -c "$config_file" -s "$style_file" &

flock -u 200
exec 200>&-