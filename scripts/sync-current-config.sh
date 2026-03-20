#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$DOTFILES_DIR/.config/zsh/modules" \
         "$DOTFILES_DIR/.config/Code/User/snippets" \
         "$DOTFILES_DIR/.config/VSCodium/User" \
         "$DOTFILES_DIR/.local/share/plasma"

cp -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$DOTFILES_DIR/.config/plasma-org.kde.plasma.desktop-appletsrc" 2>/dev/null || true
rm -f "$DOTFILES_DIR/.config/old-plasma-org.kde.plasma.desktop-appletsrc"

if [[ -d "$HOME/.local/share/plasma/plasmoids" && ! -L "$HOME/.local/share/plasma/plasmoids" ]]; then
  rm -rf "$DOTFILES_DIR/.local/share/plasma/plasmoids"
  cp -r "$HOME/.local/share/plasma/plasmoids" "$DOTFILES_DIR/.local/share/plasma/"
fi

if [[ -f "$HOME/.config/zsh/modules/adb-device.zsh" ]]; then
  cp -f "$HOME/.config/zsh/modules/adb-device.zsh" "$DOTFILES_DIR/.config/zsh/modules/adb-device.zsh" 2>/dev/null || true
elif [[ -f "$HOME/.config/zsh/scripts/adb-phone.zsh" ]]; then
  cp -f "$HOME/.config/zsh/scripts/adb-phone.zsh" "$DOTFILES_DIR/.config/zsh/modules/adb-device.zsh" 2>/dev/null || true
fi

if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
  cp -f "$HOME/.config/Code/User/settings.json" "$DOTFILES_DIR/.config/Code/User/settings.json" 2>/dev/null || true
fi
if [[ -f "$HOME/.config/Code/User/keybindings.json" ]]; then
  cp -f "$HOME/.config/Code/User/keybindings.json" "$DOTFILES_DIR/.config/Code/User/keybindings.json" 2>/dev/null || true
fi
if [[ -f "$HOME/.config/Code/User/snippets/typescript.json" ]]; then
  cp -f "$HOME/.config/Code/User/snippets/typescript.json" "$DOTFILES_DIR/.config/Code/User/snippets/typescript.json" 2>/dev/null || true
fi

if [[ -f "$HOME/.config/VSCodium/User/settings.json" ]]; then
  cp -f "$HOME/.config/VSCodium/User/settings.json" "$DOTFILES_DIR/.config/VSCodium/User/settings.json" 2>/dev/null || true
fi
if [[ -f "$HOME/.config/VSCodium/User/keybindings.json" ]]; then
  cp -f "$HOME/.config/VSCodium/User/keybindings.json" "$DOTFILES_DIR/.config/VSCodium/User/keybindings.json" 2>/dev/null || true
fi

echo "synced current config into dotfiles repo"
