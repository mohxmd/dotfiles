#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# GAME MODE TOGGLER
# Disables animations, blur, shadows, and gaps for performance
# ─────────────────────────────────────────────────────────────

STATE_FILE="$HOME/.cache/dotfiles/gamemode"
mkdir -p "$(dirname "$STATE_FILE")"

if [[ -f "$STATE_FILE" ]]; then
    rm -f "$STATE_FILE"
    hyprctl reload >/dev/null 2>&1 || true
    notify-send -a "Game Mode" -i "joystick" "Gamemode deactivated" "Animations and blur re-enabled." 2>/dev/null || true
else
    touch "$STATE_FILE"
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0" >/dev/null 2>&1 || true
    notify-send -a "Game Mode" -i "joystick" "Gamemode activated" "Animations and blur disabled." 2>/dev/null || true
fi