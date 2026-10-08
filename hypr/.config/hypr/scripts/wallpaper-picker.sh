#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# ROFI WALLPAPER PICKER
# Selects a wallpaper from dotfiles assets/wallpapers
# ─────────────────────────────────────────────────────────────

set -euo pipefail

WALLPAPERS_DIR="$HOME/dotfiles/assets/wallpapers"

if [[ ! -d "$WALLPAPERS_DIR" ]]; then
    # Fallback to repo directory if located elsewhere
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WALLPAPERS_DIR="$(cd "$SCRIPT_DIR/../../../../assets/wallpapers" 2>/dev/null && pwd || echo "$HOME/dotfiles/assets/wallpapers")"
fi

if [[ ! -d "$WALLPAPERS_DIR" ]]; then
    notify-send "Wallpaper Picker" "Wallpaper directory not found: $WALLPAPERS_DIR" 2>/dev/null || true
    exit 1
fi

# Find image files supported by awww (png, jpg, jpeg, webp; excluding mp4 video)
mapfile -t files < <(find "$WALLPAPERS_DIR" -maxdepth 2 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort)

if [[ ${#files[@]} -eq 0 ]]; then
    notify-send "Wallpaper Picker" "No supported wallpapers found." 2>/dev/null || true
    exit 1
fi

# Build entries with thumbnail icons if available, otherwise relative name
entries=""
for f in "${files[@]}"; do
    rel_name="${f#$WALLPAPERS_DIR/}"
    entries+="$rel_name\0icon\x1f$f\n"
done

chosen=$(echo -en "$entries" | rofi -dmenu -i -p "Select Wallpaper" -config ~/.config/rofi/config-compact.rasi || true)

if [[ -n "$chosen" ]]; then
    selected_file="$WALLPAPERS_DIR/$chosen"
    if [[ -f "$selected_file" ]]; then
        ~/.config/hypr/scripts/wallpaper.sh "$selected_file"
    fi
fi
