#!/usr/bin/env bash

# Toggle Waybar visibility
STATE_FILE="$HOME/.config/waybar/.disabled"

if [[ -f "$STATE_FILE" ]]; then
    rm -f "$STATE_FILE"
else
    touch "$STATE_FILE"
fi

"$HOME/.config/waybar/launch.sh" &
