#!/usr/bin/env bash

# Installer: safely link modular configuration packages into the user's home.
# Usage: ./setup.sh --profile <profile> [options].
# Profiles: auto, hyprland (or hypr), kde, gnome, mac, minimal, wsl, server.
# Packages: shared, hypr, kde, code.
# Safety: existing real files are moved to a timestamped backup first.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
DRY_RUN=false
PROFILE="auto"
USE_STOW=false
WITH_PACKAGES=()
WITHOUT_PACKAGES=()

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [options]

Options:
  --profile <hyprland|kde|gnome|mac|minimal|wsl|server|auto>  Choose link profile (default: auto)
  --with <pkg1,pkg2>                      Force include packages
  --without <pkg1,pkg2>                   Exclude packages
  --stow                                  Use GNU Stow if available
  --dry-run                               Print actions only
  -h, --help                              Show help

Packages:
  shared, hypr, kde, code
USAGE
}

split_csv() {
  local csv="$1"
  local -n out_ref=$2
  IFS=',' read -r -a out_ref <<< "$csv"
}

has_item() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

same_target() {
  local dst="$1"
  local src="$2"

  if [[ -e "$dst" && -e "$src" ]]; then
    local r_dst r_src
    r_dst="$(readlink -f "$dst" 2>/dev/null || true)"
    r_src="$(readlink -f "$src" 2>/dev/null || true)"
    if [[ -n "$r_dst" && "$r_dst" == "$r_src" ]]; then
      return 0
    fi
  fi
  [[ -L "$dst" ]] || return 1
  [[ "$(readlink -f "$dst" 2>/dev/null || true)" == "$(readlink -f "$src" 2>/dev/null || true)" ]]
}

link_file_to() {
  local src="$1"
  local dst="$2"
  local label="${3:-$dst}"

  if [[ ! -e "$src" ]]; then
    echo "skip (missing source): $label"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    if same_target "$dst" "$src"; then
      echo "already linked: $dst -> $src"
      return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
      if [[ -L "$dst" ]]; then
        echo "rm $dst"
      else
        echo "mv $dst $dst.pre-dotfiles-<timestamp>"
      fi
    fi
    echo "ln -s $src $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    if same_target "$dst" "$src"; then
      echo "already linked: $dst -> $src"
      return
    fi
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    local backup="$dst.pre-dotfiles-$(date +%Y%m%d%H%M%S)"
    local suffix=0
    while [[ -e "$backup" || -L "$backup" ]]; do
      suffix=$((suffix + 1))
      backup="$dst.pre-dotfiles-$(date +%Y%m%d%H%M%S)-$suffix"
    done
    mv "$dst" "$backup"
    echo "backed up: $dst -> $backup"
  fi

  ln -s "$src" "$dst"
  echo "linked: $dst -> $src"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --with)
      split_csv "${2:-}" WITH_PACKAGES
      shift 2
      ;;
    --without)
      split_csv "${2:-}" WITHOUT_PACKAGES
      shift 2
      ;;
    --stow)
      USE_STOW=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# Normalize profile aliases
[[ "$PROFILE" == "hypr" ]] && PROFILE="hyprland"

# Auto-detect profile based on host OS and running desktop session
if [[ "$PROFILE" == "auto" ]]; then
  case "$(uname -s)" in
    Darwin) PROFILE="mac" ;;
    Linux)
      if [[ "$(uname -r)" == *microsoft-standard* || "$(uname -r)" == *WSL2* ]]; then
        PROFILE="wsl"
      elif [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" && -z "${XDG_CURRENT_DESKTOP:-}" ]]; then
        PROFILE="server"
      elif [[ "${XDG_CURRENT_DESKTOP:-}" == *Hyprland* || "${DESKTOP_SESSION:-}" == *hyprland* ]]; then
        PROFILE="hyprland"
      elif [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]]; then
        PROFILE="kde"
      else
        PROFILE="gnome"
      fi
      ;;
    *) PROFILE="minimal" ;;
  esac
fi

case "$PROFILE" in
  hyprland)
    ACTIVE_PACKAGES=(shared hypr code)
    ;;
  kde)
    ACTIVE_PACKAGES=(shared kde code)
    ;;
  gnome)
    ACTIVE_PACKAGES=(shared code)
    ;;
  mac)
    ACTIVE_PACKAGES=(shared code)
    ;;
  minimal)
    ACTIVE_PACKAGES=(shared)
    ;;
  wsl)
    ACTIVE_PACKAGES=(shared)
    ;;
  server)
    ACTIVE_PACKAGES=(shared)
    ;;
  *)
    echo "Invalid profile: $PROFILE" >&2
    usage
    exit 1
    ;;
esac

VALID_PACKAGES=(shared hypr kde code)

# Apply --with overrides
for p in "${WITH_PACKAGES[@]:-}"; do
  [[ -z "$p" ]] && continue
  if ! has_item "$p" "${VALID_PACKAGES[@]}"; then
    echo "Unknown package for --with: $p" >&2
    usage
    exit 1
  fi
  if ! has_item "$p" "${ACTIVE_PACKAGES[@]}"; then
    ACTIVE_PACKAGES+=("$p")
  fi
done

# Apply --without overrides
if [[ ${#WITHOUT_PACKAGES[@]} -gt 0 ]]; then
  FILTERED=()
  for p in "${ACTIVE_PACKAGES[@]}"; do
    if ! has_item "$p" "${WITHOUT_PACKAGES[@]}"; then
      FILTERED+=("$p")
    fi
  done
  ACTIVE_PACKAGES=("${FILTERED[@]}")
  for p in "${WITHOUT_PACKAGES[@]}"; do
    [[ -z "$p" ]] && continue
    if ! has_item "$p" "${VALID_PACKAGES[@]}"; then
      echo "Unknown package for --without: $p" >&2
      usage
      exit 1
    fi
  done
fi

should_link() {
  local pkg="$1"
  has_item "$pkg" "${ACTIVE_PACKAGES[@]}"
}

echo "Profile: $PROFILE"
echo "Active packages: ${ACTIVE_PACKAGES[*]}"

# ─────────────────────────────────────────────────────────────
# 1. SHARED PACKAGE (Core shell, git, neovim, CLI tools)
# ─────────────────────────────────────────────────────────────
if should_link shared; then
  echo "Linking package: shared"
  link_file_to "$DOTFILES_DIR/shared/.zshrc" "$HOME_DIR/.zshrc" ".zshrc"
  link_file_to "$DOTFILES_DIR/shared/.gitconfig" "$HOME_DIR/.gitconfig" ".gitconfig"
  link_file_to "$DOTFILES_DIR/shared/.config/nvim" "$HOME_DIR/.config/nvim" ".config/nvim"
  link_file_to "$DOTFILES_DIR/shared/.config/starship.toml" "$HOME_DIR/.config/starship.toml" ".config/starship.toml"

  if [[ "$PROFILE" != "server" && "$PROFILE" != "minimal" ]]; then
    link_file_to "$DOTFILES_DIR/shared/.config/zsh" "$HOME_DIR/.config/zsh" ".config/zsh"
    link_file_to "$DOTFILES_DIR/shared/.local/bin/search" "$HOME_DIR/.local/bin/search" ".local/bin/search"
    link_file_to "$DOTFILES_DIR/shared/.local/bin/cfd-init" "$HOME_DIR/.local/bin/cfd-init" ".local/bin/cfd-init"
    link_file_to "$DOTFILES_DIR/shared/.local/bin/image-request" "$HOME_DIR/.local/bin/image-request" ".local/bin/image-request"
    link_file_to "$DOTFILES_DIR/shared/.local/bin/video-to-ascii" "$HOME_DIR/.local/bin/video-to-ascii" ".local/bin/video-to-ascii"
  fi

  link_file_to "$DOTFILES_DIR/shared/.config/pgcli" "$HOME_DIR/.config/pgcli" ".config/pgcli"
  if [[ "$PROFILE" != "server" ]]; then
    link_file_to "$DOTFILES_DIR/shared/.config/paru" "$HOME_DIR/.config/paru" ".config/paru"
  fi
  link_file_to "$DOTFILES_DIR/shared/.config/htop" "$HOME_DIR/.config/htop" ".config/htop"
  link_file_to "$DOTFILES_DIR/shared/.config/fastfetch" "$HOME_DIR/.config/fastfetch" ".config/fastfetch"
  link_file_to "$DOTFILES_DIR/shared/.config/fontconfig" "$HOME_DIR/.config/fontconfig" ".config/fontconfig"
  link_file_to "$DOTFILES_DIR/shared/.config/cava" "$HOME_DIR/.config/cava" ".config/cava"
  link_file_to "$DOTFILES_DIR/shared/.config/obs-studio" "$HOME_DIR/.config/obs-studio" ".config/obs-studio"

  # Obsidian: link vault configuration to ~/Notes or ~/vault if present
  if [[ -d "$HOME_DIR/Notes" ]]; then
    link_file_to "$DOTFILES_DIR/shared/.obsidian" "$HOME_DIR/Notes/.obsidian" "Notes/.obsidian"
  elif [[ -d "$HOME_DIR/vault" ]]; then
    link_file_to "$DOTFILES_DIR/shared/.obsidian" "$HOME_DIR/vault/.obsidian" "vault/.obsidian"
  fi
fi

# ─────────────────────────────────────────────────────────────
# 2. HYPRLAND PACKAGE (Laptop / Wayland environment)
# ─────────────────────────────────────────────────────────────
if should_link hypr; then
  echo "Linking package: hypr"
  link_file_to "$DOTFILES_DIR/hypr/.config/hypr" "$HOME_DIR/.config/hypr" ".config/hypr"
  link_file_to "$DOTFILES_DIR/hypr/.config/waybar" "$HOME_DIR/.config/waybar" ".config/waybar"
  link_file_to "$DOTFILES_DIR/hypr/.config/kitty" "$HOME_DIR/.config/kitty" ".config/kitty"
  link_file_to "$DOTFILES_DIR/hypr/.config/mako" "$HOME_DIR/.config/mako" ".config/mako"
  link_file_to "$DOTFILES_DIR/hypr/.config/rofi" "$HOME_DIR/.config/rofi" ".config/rofi"
  link_file_to "$DOTFILES_DIR/hypr/.config/wofi" "$HOME_DIR/.config/wofi" ".config/wofi"
  link_file_to "$DOTFILES_DIR/hypr/.config/gtk-3.0" "$HOME_DIR/.config/gtk-3.0" ".config/gtk-3.0"
  link_file_to "$DOTFILES_DIR/hypr/.config/gtk-4.0" "$HOME_DIR/.config/gtk-4.0" ".config/gtk-4.0"
  link_file_to "$DOTFILES_DIR/hypr/.config/kolourpaintrc" "$HOME_DIR/.config/kolourpaintrc" ".config/kolourpaintrc"
  link_file_to "$DOTFILES_DIR/hypr/.config/user-dirs.locale" "$HOME_DIR/.config/user-dirs.locale" ".config/user-dirs.locale"
fi

# ─────────────────────────────────────────────────────────────
# 3. KDE PLASMA PACKAGE (Main desktop environment)
# ─────────────────────────────────────────────────────────────
if should_link kde; then
  echo "Linking package: kde"
  link_file_to "$DOTFILES_DIR/kde/.config/plasma-org.kde.plasma.desktop-appletsrc" \
               "$HOME_DIR/.config/plasma-org.kde.plasma.desktop-appletsrc" \
               ".config/plasma-org.kde.plasma.desktop-appletsrc"
  link_file_to "$DOTFILES_DIR/kde/.config/kwinrulesrc" "$HOME_DIR/.config/kwinrulesrc" ".config/kwinrulesrc"
  link_file_to "$DOTFILES_DIR/kde/.local/bin/fix-hdmi-audio" "$HOME_DIR/.local/bin/fix-hdmi-audio" ".local/bin/fix-hdmi-audio"
  link_file_to "$DOTFILES_DIR/kde/.local/share/plasma" "$HOME_DIR/.local/share/plasma" ".local/share/plasma"
  link_file_to "$DOTFILES_DIR/kde/.local/share/color-schemes" "$HOME_DIR/.local/share/color-schemes" ".local/share/color-schemes"
  link_file_to "$DOTFILES_DIR/kde/.local/share/konsole" "$HOME_DIR/.local/share/konsole" ".local/share/konsole"
  link_file_to "$DOTFILES_DIR/kde/.local/share/org.kde.syntax-highlighting" \
               "$HOME_DIR/.local/share/org.kde.syntax-highlighting" \
               ".local/share/org.kde.syntax-highlighting"

  # Firefox: link user.js for KDE Global Menu support
  if [[ -d "$HOME_DIR/.mozilla/firefox" && -f "$DOTFILES_DIR/kde/.config/firefox/user.js" ]]; then
    for profile in "$HOME_DIR/.mozilla/firefox/"*.default-release "$HOME_DIR/.mozilla/firefox/"*.Profile*; do
      if [[ -d "$profile" ]]; then
        link_file_to "$DOTFILES_DIR/kde/.config/firefox/user.js" "$profile/user.js"
      fi
    done
  fi
fi

# ─────────────────────────────────────────────────────────────
# 4. CODE / DEV PACKAGE (VS Code & VSCodium configuration)
# ─────────────────────────────────────────────────────────────
if should_link code; then
  echo "Linking package: code"
  link_file_to "$DOTFILES_DIR/code/.config/Code/User/settings.json" \
               "$HOME_DIR/.config/Code/User/settings.json" \
               ".config/Code/User/settings.json"
  link_file_to "$DOTFILES_DIR/code/.config/Code/User/keybindings.json" \
               "$HOME_DIR/.config/Code/User/keybindings.json" \
               ".config/Code/User/keybindings.json"
  link_file_to "$DOTFILES_DIR/code/.config/Code/User/snippets/typescript.json" \
               "$HOME_DIR/.config/Code/User/snippets/typescript.json" \
               ".config/Code/User/snippets/typescript.json"
  link_file_to "$DOTFILES_DIR/code/.config/code-flags.conf" "$HOME_DIR/.config/code-flags.conf" ".config/code-flags.conf"
  link_file_to "$DOTFILES_DIR/code/.config/antigravity-ide-flags.conf" \
               "$HOME_DIR/.config/antigravity-ide-flags.conf" \
               ".config/antigravity-ide-flags.conf"
  link_file_to "$DOTFILES_DIR/code/.local/share/applications/code.desktop" \
               "$HOME_DIR/.local/share/applications/code.desktop" \
               ".local/share/applications/code.desktop"
  link_file_to "$DOTFILES_DIR/code/.local/share/applications/antigravity-ide.desktop" \
               "$HOME_DIR/.local/share/applications/antigravity-ide.desktop" \
               ".local/share/applications/antigravity-ide.desktop"
  link_file_to "$DOTFILES_DIR/code/.config/VSCodium/User/settings.json" \
               "$HOME_DIR/.config/VSCodium/User/settings.json" \
               ".config/VSCodium/User/settings.json"
  link_file_to "$DOTFILES_DIR/code/.config/VSCodium/User/keybindings.json" \
               "$HOME_DIR/.config/VSCodium/User/keybindings.json" \
               ".config/VSCodium/User/keybindings.json"
fi

echo "Setup completed successfully."
