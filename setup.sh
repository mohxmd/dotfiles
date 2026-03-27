#!/usr/bin/env bash
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
  --profile <kde|gnome|mac|minimal|auto>  Choose link profile (default: auto)
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

link_file() {
  local rel="$1"
  local src="$DOTFILES_DIR/$rel"
  local dst="$HOME_DIR/$rel"

  if [[ ! -e "$src" ]]; then
    echo "skip (missing source): $rel"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "ln -sfn $src $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "linked: $dst -> $src"
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
  echo "Use profile-based setup instead: ./setup.sh --profile <kde|gnome|mac|minimal>" >&2
  exit 1
fi

if [[ "$PROFILE" == "auto" ]]; then
  case "$(uname -s)" in
    Darwin) PROFILE="mac" ;;
    Linux)
      if [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]]; then
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
  *)
    echo "Invalid profile: $PROFILE" >&2
    usage
    exit 1
    ;;
esac

# Apply --with overrides
for g in "${WITH_GROUPS[@]:-}"; do
  [[ -z "$g" ]] && continue
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
fi

should_link() {
  local group="$1"
  has_group "$group" "${ACTIVE_GROUPS[@]}"
}

echo "profile: $PROFILE"
echo "groups: ${ACTIVE_GROUPS[*]}"

should_link core && link_file ".zshrc"
should_link core && link_file ".config/starship.toml"
should_link core && link_file ".config/zsh/modules/adb-device.zsh"
should_link core && link_file ".local/bin/fix-hdmi-audio"
should_link core && link_file ".local/bin/search"
should_link core && link_file ".local/bin/image-request"
should_link core && link_file ".local/bin/video-to-ascii"
should_link core && link_file ".local/bin/cfd-init"
should_link core && link_file ".config/pgcli/config"

should_link nvim && link_file ".config/nvim"

should_link code && link_file ".config/Code/User/settings.json"
should_link code && link_file ".config/Code/User/keybindings.json"
should_link code && link_file ".config/Code/User/snippets/typescript.json"

should_link vscodium && link_file ".config/VSCodium/User/settings.json"
should_link vscodium && link_file ".config/VSCodium/User/keybindings.json"

should_link plasma && link_file ".config/plasma-org.kde.plasma.desktop-appletsrc"
should_link plasma && link_file ".local/share/plasma/plasmoids"
should_link plasma && link_file ".local/share/color-schemes"
should_link plasma && link_file ".local/share/konsole"
should_link plasma && link_file ".local/share/org.kde.syntax-highlighting/themes"

echo "setup complete"
