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

# Ensure hyprpaper daemon is running
if ! pgrep -x hyprpaper >/dev/null 2>&1; then
  hyprpaper &
  # Wait up to 2 seconds for hyprpaper socket
  for _ in {1..20}; do
    if hyprctl hyprpaper listloaded >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done
fi

# Preload and set wallpaper on all monitors
hyprctl hyprpaper preload "$WALLPAPER" 2>/dev/null || true
hyprctl hyprpaper wallpaper ",$WALLPAPER" 2>/dev/null || true

# Update hyprpaper.conf so future cold boots load it immediately
CONF_FILE="$SCRIPT_DIR/hyprpaper.conf"
if [[ -w "$CONF_FILE" ]]; then
  cat <<EOF > "$CONF_FILE"
preload = $WALLPAPER
wallpaper = ,$WALLPAPER
splash = false
ipc = on
EOF
fi
