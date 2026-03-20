#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$DOTFILES_DIR/.config/zsh/scripts" \
         "$DOTFILES_DIR/.config/Code/User/snippets" \
         "$DOTFILES_DIR/.config/VSCodium/User"

cp -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$DOTFILES_DIR/.config/plasma-org.kde.plasma.desktop-appletsrc"
rm -f "$DOTFILES_DIR/.config/old-plasma-org.kde.plasma.desktop-appletsrc"

if [[ -f "$HOME/.config/zsh/scripts/adb-phone.zsh" ]]; then
  cp -f "$HOME/.config/zsh/scripts/adb-phone.zsh" "$DOTFILES_DIR/.config/zsh/scripts/adb-phone.zsh"
fi

if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
  cp -f "$HOME/.config/Code/User/settings.json" "$DOTFILES_DIR/.config/Code/User/settings.json"
fi
if [[ -f "$HOME/.config/Code/User/keybindings.json" ]]; then
  cp -f "$HOME/.config/Code/User/keybindings.json" "$DOTFILES_DIR/.config/Code/User/keybindings.json"
fi
if [[ -f "$HOME/.config/Code/User/snippets/typescript.json" ]]; then
  cp -f "$HOME/.config/Code/User/snippets/typescript.json" "$DOTFILES_DIR/.config/Code/User/snippets/typescript.json"
fi

if [[ -f "$HOME/.config/VSCodium/User/settings.json" ]]; then
  cp -f "$HOME/.config/VSCodium/User/settings.json" "$DOTFILES_DIR/.config/VSCodium/User/settings.json"
fi
if [[ -f "$HOME/.config/VSCodium/User/keybindings.json" ]]; then
  cp -f "$HOME/.config/VSCodium/User/keybindings.json" "$DOTFILES_DIR/.config/VSCodium/User/keybindings.json"
fi

echo "synced current config into dotfiles repo"
