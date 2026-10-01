#!/usr/bin/env bash

# Set Hyprland wallpaper dynamically via hyprpaper

set -euo pipefail

WALLPAPER="${1:-$HOME/dotfiles/assets/wallpapers/a_woman_sitting_in_a_chair_under_a_tent.png}"

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
