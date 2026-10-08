#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# WALLPAPER & DYNAMIC COLOR THEME CONTROLLER
# Sets wallpaper via awww, generates colors via matugen,
# and reloads UI components.
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# Cache & Defaults
CACHE_FOLDER="$HOME/.cache/dotfiles/wallpaper"
CACHE_FILE="$CACHE_FOLDER/current_wallpaper"
BLURRED_WALLPAPER="$CACHE_FOLDER/blurred_wallpaper.png"
SQUARE_WALLPAPER="$CACHE_FOLDER/square_wallpaper.png"
RASI_FILE="$CACHE_FOLDER/current_wallpaper.rasi"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_WALLPAPERS="$(cd "$SCRIPT_DIR/../../../../assets/wallpapers" 2>/dev/null && pwd || echo "$HOME/dotfiles/assets/wallpapers")"
if [[ ! -d "$DOTFILES_WALLPAPERS" ]]; then
    for candidate in "$HOME/.dotfiles/assets/wallpapers" "$HOME/dotfiles/assets/wallpapers"; do
        if [[ -d "$candidate" ]]; then
            DOTFILES_WALLPAPERS="$candidate"
            break
        fi
    done
fi
DEFAULT_WALLPAPER="$DOTFILES_WALLPAPERS/a_woman_sitting_in_a_chair_under_a_tent.png"
TRANSITION_EFFECT="fade"

IMAGE_PATH=""
SKIP_WALLPAPER=false
SKIP_THEMING=false

show_help() {
    cat <<EOF
Usage: wallpaper.sh [PATH_TO_IMAGE] [OPTIONS]

Options:
  --restore           Restore wallpaper from cache or default
  --random [DIR]      Select random image from directory
  --skip-wallpaper    Run color generation only (skip awww)
  --skip-theming      Set wallpaper only (skip matugen)
  -h, --help          Show this message
EOF
}

# Parameter Parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --restore)
            if [[ -f "$CACHE_FILE" ]]; then
                IMAGE_PATH="$(cat "$CACHE_FILE")"
            fi
            if [[ -z "$IMAGE_PATH" || ! -f "$IMAGE_PATH" ]]; then
                IMAGE_PATH="$DEFAULT_WALLPAPER"
            fi
            shift ;;
        --random)
            shift
            search_dir="${1:-$DOTFILES_WALLPAPERS}"
            if [[ -n "${1:-}" && "${1:-}" != -* ]]; then
                shift
            fi
            if [[ -d "$search_dir" ]]; then
                # Find image files, excluding mp4/video files that awww cannot display
                IMAGE_PATH=$(find "$search_dir" -maxdepth 2 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | shuf -n 1)
            fi
            ;;
        --skip-wallpaper)
            SKIP_WALLPAPER=true
            shift ;;
        --skip-theming)
            SKIP_THEMING=true
            shift ;;
        -h|--help)
            show_help
            exit 0 ;;
        -*)
            echo "Unknown option: $1" >&2
            show_help
            exit 1 ;;
        *)
            IMAGE_PATH="$1"
            shift ;;
    esac
done

# Validate image path
if [[ -z "$IMAGE_PATH" ]]; then
    if [[ -f "$CACHE_FILE" ]]; then
        IMAGE_PATH="$(cat "$CACHE_FILE")"
    else
        IMAGE_PATH="$DEFAULT_WALLPAPER"
    fi
fi

if [[ ! -f "$IMAGE_PATH" ]]; then
    # Fallback to any valid wallpaper from assets
    if [[ -d "$DOTFILES_WALLPAPERS" ]]; then
        IMAGE_PATH=$(find "$DOTFILES_WALLPAPERS" -maxdepth 2 -type f \( -iname "*.png" -o -iname "*.jpg" \) | head -n 1)
    fi
fi

if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "Error: Image file does not exist at -> $IMAGE_PATH" >&2
    exit 1
fi

mkdir -p "$CACHE_FOLDER"
echo "$IMAGE_PATH" > "$CACHE_FILE"

# 1. Start awww-daemon if needed & set wallpaper
if [[ "$SKIP_WALLPAPER" != true ]]; then
    if ! pgrep -x "awww-daemon" > /dev/null 2>&1; then
        echo "Starting awww-daemon..."
        awww-daemon &
        sleep 0.5
    fi

    echo "Setting wallpaper: $IMAGE_PATH"
    awww img "$IMAGE_PATH" --transition-type "$TRANSITION_EFFECT" 2>/dev/null || true
fi

# 2. Run Matugen Color Generation
if [[ "$SKIP_THEMING" != true ]]; then
    echo "Generating color schemes with matugen..."
    mode="dark"
    if [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]]; then
        if grep -q "gtk-application-prefer-dark-theme=0" "$HOME/.config/gtk-3.0/settings.ini"; then
            mode="light"
        fi
    fi

    matugen_bin="matugen"
    if [[ -f "$HOME/.cargo/bin/matugen" ]]; then
        matugen_bin="$HOME/.cargo/bin/matugen"
    fi

    if command -v "$matugen_bin" >/dev/null 2>&1; then
        "$matugen_bin" image "$IMAGE_PATH" --source-color-index 0 -m "$mode" || true
    else
        echo "Warning: matugen not found in PATH" >&2
    fi

    # 3. Generate ImageMagick thumbnails for menus/lockscreen
    if command -v magick >/dev/null 2>&1; then
        magick "$IMAGE_PATH" -resize 75% -blur 0x12 "$BLURRED_WALLPAPER" 2>/dev/null || true
        magick "$IMAGE_PATH" -gravity Center -extent 1:1 "$SQUARE_WALLPAPER" 2>/dev/null || true
        echo "* { current-image: url(\"$BLURRED_WALLPAPER\", height); }" > "$RASI_FILE"
    fi

    # 4. Reload components
    if pgrep -x "waybar" > /dev/null 2>&1; then
        bash -c "$HOME/.config/waybar/launch.sh" > /dev/null 2>&1 &
    fi

    if command -v swaync-client >/dev/null 2>&1; then
        swaync-client -rs 2>/dev/null || true
    fi

    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload 2>/dev/null || true
    fi

    pkill -SIGUSR1 kitty 2>/dev/null || true
fi

echo "Wallpaper and color updates applied successfully."