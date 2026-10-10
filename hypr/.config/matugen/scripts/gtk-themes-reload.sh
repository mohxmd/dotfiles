#!/usr/bin/env bash

# Reload GTK interface color-scheme to trigger live style reload
current=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'prefer-dark'")

if [[ "$current" == "'prefer-dark'" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null || true
fi
