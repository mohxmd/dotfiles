#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# INSTALL HYPRLAND PACKAGES
# Parses hypr/packages.txt and installs via pacman & paru.
# Usage: ./install-packages.sh [--dry-run]
# ─────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/packages.txt"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo "Error: packages.txt not found at $PACKAGES_FILE" >&2
    exit 1
fi

PACMAN_PKGS=()
AUR_PKGS=()

while IFS= read -r line || [[ -n "$line" ]]; do
    # Strip comments and empty lines
    line="$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue

    # Check for AUR tag
    is_aur=false
    if [[ "$line" =~ \[AUR\] ]]; then
        is_aur=true
    fi

    # Extract base package name (strip annotations like [unverified], [AUR])
    pkg_name="$(echo "$line" | awk '{print $1}')"

    if [[ "$is_aur" == true ]]; then
        AUR_PKGS+=("$pkg_name")
    else
        PACMAN_PKGS+=("$pkg_name")
    fi
done < "$PACKAGES_FILE"

echo "=== Official Repository Packages (${#PACMAN_PKGS[@]}) ==="
echo "${PACMAN_PKGS[*]}"
echo
echo "=== AUR Packages (${#AUR_PKGS[@]}) ==="
echo "${AUR_PKGS[*]}"
echo

if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] Would execute:"
    echo "  sudo pacman -S --needed --noconfirm ${PACMAN_PKGS[*]}"
    echo "  paru -S --needed ${AUR_PKGS[*]}"
    exit 0
fi

read -rp "Proceed with installation? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

if [[ ${#PACMAN_PKGS[@]} -gt 0 ]]; then
    echo "Installing official packages..."
    sudo pacman -S --needed "${PACMAN_PKGS[@]}"
fi

if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
    if command -v paru >/dev/null 2>&1; then
        echo "Installing AUR packages via paru..."
        paru -S --needed "${AUR_PKGS[@]}"
    elif command -v yay >/dev/null 2>&1; then
        echo "Installing AUR packages via yay..."
        yay -S --needed "${AUR_PKGS[@]}"
    else
        echo "Error: Neither paru nor yay found to install AUR packages: ${AUR_PKGS[*]}" >&2
        echo "To install paru: sudo pacman -S --needed base-devel git && git clone https://aur.archlinux.org/paru.git /tmp/paru && cd /tmp/paru && makepkg -si" >&2
        exit 1
    fi
fi

echo "Package installation complete."
