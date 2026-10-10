#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# POWER & SESSION MANAGEMENT
# ─────────────────────────────────────────────────────────────

terminate_clients() {
    TIMEOUT=5
    client_pids=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | .pid' 2>/dev/null || true)

    for pid in $client_pids; do
        kill -15 "$pid" 2>/dev/null || true
    done

    start_time=$(date +%s)
    for pid in $client_pids; do
        while kill -0 "$pid" 2>/dev/null; do
            current_time=$(date +%s)
            elapsed_time=$((current_time - start_time))
            if [ "$elapsed_time" -ge "$TIMEOUT" ]; then
                break
            fi
            sleep 0.5
        done
    done
}

case "${1:-}" in
    exit)
        terminate_clients
        sleep 0.5
        hyprctl dispatch exit
        ;;
    lock)
        pidof hyprlock || hyprlock
        ;;
    reboot)
        terminate_clients
        sleep 0.5
        systemctl reboot
        ;;
    shutdown)
        terminate_clients
        sleep 0.5
        systemctl poweroff
        ;;
    suspend)
        sleep 0.2
        systemctl suspend
        ;;
    hibernate)
        sleep 0.2
        systemctl hibernate
        ;;
    *)
        echo "Usage: power.sh {exit|lock|reboot|shutdown|suspend|hibernate}" >&2
        exit 1
        ;;
esac
