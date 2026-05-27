#!/bin/bash
set -e

if pidof Hyprland >/dev/null; then
    exec /usr/lib/hyprpolkitagent/hyprpolkitagent
fi
