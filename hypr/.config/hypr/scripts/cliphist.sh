#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# CLIPBOARD MANAGER (CLIPHIST + ROFI)
# ─────────────────────────────────────────────────────────────

case "${1:-}" in
    d)
        # Delete selected entry
        cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi -p "Delete Item" | cliphist delete
        ;;
    w)
        # Wipe clipboard
        cliphist wipe
        ;;
    *)
        # Select and copy to clipboard
        cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi -p "Clipboard" | cliphist decode | wl-copy
        ;;
esac
