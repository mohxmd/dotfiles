#!/usr/bin/env bash

# Sync utility: copy selected live user configuration into this repository.
# Usage: ./scripts/sync-current-config.sh
# Warning: writes into the repository; review git diff afterward.
# Existing repository files are never deleted by this script. Remove stale
# files manually after confirming that the live configuration is complete.
# Scope: Plasma, KWin, Konsole, pgcli, Zsh modules, and VS Code configuration.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$DOTFILES_DIR/.config/zsh/modules" \
         "$DOTFILES_DIR/.config/Code/User/snippets" \
         "$DOTFILES_DIR/.config/VSCodium/User" \
         "$DOTFILES_DIR/.config/pgcli" \
         "$DOTFILES_DIR/.local/share/plasma" \
         "$DOTFILES_DIR/.local/share/konsole" \
         "$DOTFILES_DIR/.local/share/org.kde.syntax-highlighting/themes"

if [[ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]]; then
  cp -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
    "$DOTFILES_DIR/.config/plasma-org.kde.plasma.desktop-appletsrc"
fi

if [[ -f "$HOME/.config/kwinrulesrc" && ! -L "$HOME/.config/kwinrulesrc" ]]; then
  cp -f "$HOME/.config/kwinrulesrc" "$DOTFILES_DIR/.config/kwinrulesrc"
fi

if [[ -d "$HOME/.local/share/plasma/plasmoids" && ! -L "$HOME/.local/share/plasma/plasmoids" ]]; then
  mkdir -p "$DOTFILES_DIR/.local/share/plasma/plasmoids"
  cp -a "$HOME/.local/share/plasma/plasmoids/." \
    "$DOTFILES_DIR/.local/share/plasma/plasmoids/"
fi

if [[ -d "$HOME/.local/share/color-schemes" && ! -L "$HOME/.local/share/color-schemes" ]]; then
  mkdir -p "$DOTFILES_DIR/.local/share/color-schemes"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --copy-links \
      "$HOME/.local/share/color-schemes/" \
      "$DOTFILES_DIR/.local/share/color-schemes/"
  else
    echo "rsync not found; using cp fallback for color-schemes." >&2
    cp -af "$HOME/.local/share/color-schemes/." "$DOTFILES_DIR/.local/share/color-schemes/"
  fi
fi

if [[ -d "$HOME/.local/share/konsole" && ! -L "$HOME/.local/share/konsole" ]]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --copy-links \
      "$HOME/.local/share/konsole/" \
      "$DOTFILES_DIR/.local/share/konsole/"
  else
    echo "rsync not found; using cp fallback for konsole." >&2
    cp -af "$HOME/.local/share/konsole/." "$DOTFILES_DIR/.local/share/konsole/"
  fi
fi

if [[ -d "$HOME/.local/share/org.kde.syntax-highlighting/themes" && ! -L "$HOME/.local/share/org.kde.syntax-highlighting/themes" ]]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --copy-links \
      "$HOME/.local/share/org.kde.syntax-highlighting/themes/" \
      "$DOTFILES_DIR/.local/share/org.kde.syntax-highlighting/themes/"
  else
    echo "rsync not found; using cp fallback for kate theme." >&2
    cp -af "$HOME/.local/share/org.kde.syntax-highlighting/themes/." "$DOTFILES_DIR/.local/share/org.kde.syntax-highlighting/themes/"
  fi
fi

if [[ -f "$HOME/.config/pgcli/config" ]]; then
  cp -f "$HOME/.config/pgcli/config" "$DOTFILES_DIR/.config/pgcli/config"
fi

if [[ -f "$HOME/.config/zsh/modules/adb-device.zsh" ]]; then
  cp -f "$HOME/.config/zsh/modules/adb-device.zsh" \
    "$DOTFILES_DIR/.config/zsh/modules/adb-device.zsh"
elif [[ -f "$HOME/.config/zsh/scripts/adb-phone.zsh" ]]; then
  cp -f "$HOME/.config/zsh/scripts/adb-phone.zsh" \
    "$DOTFILES_DIR/.config/zsh/modules/adb-device.zsh"
fi

if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
  cp -f "$HOME/.config/Code/User/settings.json" \
    "$DOTFILES_DIR/.config/Code/User/settings.json"
fi
if [[ -f "$HOME/.config/Code/User/keybindings.json" ]]; then
  cp -f "$HOME/.config/Code/User/keybindings.json" \
    "$DOTFILES_DIR/.config/Code/User/keybindings.json"
fi
if [[ -f "$HOME/.config/Code/User/snippets/typescript.json" ]]; then
  cp -f "$HOME/.config/Code/User/snippets/typescript.json" \
    "$DOTFILES_DIR/.config/Code/User/snippets/typescript.json"
fi

if [[ -f "$HOME/.config/VSCodium/User/settings.json" ]]; then
  cp -f "$HOME/.config/VSCodium/User/settings.json" \
    "$DOTFILES_DIR/.config/VSCodium/User/settings.json"
fi
if [[ -f "$HOME/.config/VSCodium/User/keybindings.json" ]]; then
  cp -f "$HOME/.config/VSCodium/User/keybindings.json" \
    "$DOTFILES_DIR/.config/VSCodium/User/keybindings.json"
fi

echo "synced current config into dotfiles repo"
