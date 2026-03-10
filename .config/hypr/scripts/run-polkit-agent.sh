#!/bin/bash
set -e

if pidof Hyprland >/dev/null; then
    exec /usr/lib/hyprpolkitagent/hyprpolkitagent

elif pid of sway >/dev/null; then
    # pantheon-polkit-agent has an auto star entry
    # /etc/xdg/autostart/io.elementary.desktop.agent-polkit.desktop
    :
fi
