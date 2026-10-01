#!/usr/bin/env bash

# Set Hyprland wallpaper dynamically via hyprpaper

set -euo pipefail

# Derive the dotfiles directory from this script's real path (follows symlinks)
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DEFAULT_WALLPAPER="$DOTFILES_DIR/assets/wallpapers/a_woman_sitting_in_a_chair_under_a_tent.png"

WALLPAPER="${1:-$DEFAULT_WALLPAPER}"

if [[ ! -f "$WALLPAPER" ]]; then
  echo "Wallpaper not found: $WALLPAPER" >&2
  exit 1
fi

if ! pgrep -x hyprpaper >/dev/null 2>&1; then
  hyprpaper &
  sleep 0.4
fi

hyprctl hyprpaper preload "$WALLPAPER" 2>/dev/null || true
hyprctl hyprpaper wallpaper ",$WALLPAPER" 2>/dev/null || true
