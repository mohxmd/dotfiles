#!/usr/bin/env bash

# Installer: safely link selected configuration files into the user's home.
# Usage: ./setup.sh --profile <profile> [options].
# Profiles: auto, kde, gnome, mac, minimal, wsl.
# Safety: existing real files are moved to a timestamped backup first.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
DRY_RUN=false
PROFILE="auto"
USE_STOW=false
WITH_GROUPS=()
WITHOUT_GROUPS=()

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [options]

Options:
  --profile <kde|gnome|mac|minimal|wsl|server|auto>  Choose link profile (default: auto)
  --with <group1,group2>                  Force include groups
  --without <group1,group2>               Exclude groups
  --stow-all                               Disabled (kept for compatibility)
  --dry-run                                Print actions only
  -h, --help                               Show help

Groups:
  core, nvim, code, vscodium, plasma
USAGE
}

split_csv() {
  local csv="$1"
  local -n out_ref=$2
  IFS=',' read -r -a out_ref <<< "$csv"
}

has_group() {
  local needle="$1"
  shift
  local g
  for g in "$@"; do
    [[ "$g" == "$needle" ]] && return 0
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
    backup="$dst.pre-dotfiles-$(date +%Y%m%d%H%M%S)"
    suffix=0
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

link_file() {
  local rel="$1"
  link_file_to "$DOTFILES_DIR/$rel" "$HOME_DIR/$rel" "$rel"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --with)
      split_csv "${2:-}" WITH_GROUPS
      shift 2
      ;;
    --without)
      split_csv "${2:-}" WITHOUT_GROUPS
      shift 2
      ;;
    --stow-all)
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

if [[ "$USE_STOW" == true ]]; then
  echo "--stow-all is disabled to avoid linking non-dotfile assets/ into \$HOME." >&2
  echo "Use profile-based setup instead: ./setup.sh --profile <kde|gnome|mac|minimal|wsl>" >&2
  exit 1
fi

if [[ "$PROFILE" == "auto" ]]; then
  case "$(uname -s)" in
    Darwin) PROFILE="mac" ;;
    Linux)
      if [[ "$(uname -r)" == *microsoft-standard* || "$(uname -r)" == *WSL2* ]]; then
        PROFILE="wsl"
      elif [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" && -z "${XDG_CURRENT_DESKTOP:-}" ]]; then
        PROFILE="server"
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
  kde)
    ACTIVE_GROUPS=(core nvim code vscodium plasma)
    ;;
  gnome)
    ACTIVE_GROUPS=(core nvim code)
    ;;
  mac)
    ACTIVE_GROUPS=(core nvim code)
    ;;
  minimal)
    ACTIVE_GROUPS=(core)
    ;;
  wsl)
    ACTIVE_GROUPS=(core nvim)
    ;;
  server)
    ACTIVE_GROUPS=(core nvim)
    ;;
  *)
    echo "Invalid profile: $PROFILE" >&2
    usage
    exit 1
    ;;
esac

VALID_GROUPS=(core nvim code vscodium plasma)

# Apply --with overrides
for g in "${WITH_GROUPS[@]:-}"; do
  [[ -z "$g" ]] && continue
  if ! has_group "$g" "${VALID_GROUPS[@]}"; then
    echo "Unknown group for --with: $g" >&2
    usage
    exit 1
  fi
  if ! has_group "$g" "${ACTIVE_GROUPS[@]}"; then
    ACTIVE_GROUPS+=("$g")
  fi
done

# Apply --without overrides
if [[ ${#WITHOUT_GROUPS[@]} -gt 0 ]]; then
  FILTERED=()
  for g in "${ACTIVE_GROUPS[@]}"; do
    if ! has_group "$g" "${WITHOUT_GROUPS[@]}"; then
      FILTERED+=("$g")
    fi
  done
  ACTIVE_GROUPS=("${FILTERED[@]}")
  for g in "${WITHOUT_GROUPS[@]}"; do
    [[ -z "$g" ]] && continue
    if ! has_group "$g" "${VALID_GROUPS[@]}"; then
      echo "Unknown group for --without: $g" >&2
      usage
      exit 1
    fi
  done
fi

should_link() {
  local group="$1"
  has_group "$group" "${ACTIVE_GROUPS[@]}"
}

echo "profile: $PROFILE"
echo "groups: ${ACTIVE_GROUPS[*]}"

should_link core && link_file ".zshrc"
should_link core && link_file ".config/starship.toml"

if should_link core && [[ "$PROFILE" != "server" && "$PROFILE" != "minimal" ]]; then
  link_file ".config/zsh/modules/adb-device.zsh"
  link_file ".local/bin/search"
  link_file ".local/bin/image-request"
  link_file ".local/bin/video-to-ascii"
fi

if should_link core && [[ "$PROFILE" != "wsl" && "$PROFILE" != "mac" && "$PROFILE" != "server" && "$PROFILE" != "minimal" ]]; then
  link_file ".local/bin/fix-hdmi-audio"
fi

should_link core && link_file ".local/bin/cfd-init"
should_link core && link_file ".config/pgcli/config"
if should_link core && [[ "$PROFILE" != "server" ]]; then
  link_file ".config/paru/paru.conf"
fi

should_link nvim && link_file ".config/nvim"

should_link code && link_file ".config/Code/User/settings.json"
should_link code && link_file ".config/Code/User/keybindings.json"
should_link code && link_file ".config/Code/User/snippets/typescript.json"
should_link code && link_file ".local/share/applications/code.desktop"
should_link code && link_file ".local/share/applications/antigravity-ide.desktop"
should_link code && link_file ".config/code-flags.conf"
should_link code && link_file ".config/antigravity-ide-flags.conf"

should_link vscodium && link_file ".config/VSCodium/User/settings.json"
should_link vscodium && link_file ".config/VSCodium/User/keybindings.json"

should_link plasma && link_file ".config/plasma-org.kde.plasma.desktop-appletsrc"
should_link plasma && link_file ".config/kwinrulesrc"
should_link plasma && link_file ".local/share/plasma/plasmoids"
should_link plasma && link_file ".local/share/color-schemes"
should_link plasma && link_file ".local/share/konsole"
should_link plasma && link_file ".local/share/org.kde.syntax-highlighting/themes"

# Firefox: link user.js for KDE Global Menu support
if [[ "$PROFILE" == "kde" && -d "$HOME_DIR/.mozilla/firefox" && -f "$DOTFILES_DIR/.config/firefox/user.js" ]]; then
  for profile in "$HOME_DIR/.mozilla/firefox/"*.default-release "$HOME_DIR/.mozilla/firefox/"*.Profile*; do
    if [[ -d "$profile" ]]; then
      link_file_to "$DOTFILES_DIR/.config/firefox/user.js" "$profile/user.js"
    fi
  done
fi

echo "setup complete"
