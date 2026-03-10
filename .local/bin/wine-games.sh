#!/bin/bash
set -e
export ENABLE_HDR_WSI=1
export DXVK_HDR=1
export DISPLAY=
export WINEPREFIX="$HOME/.wine/games"

if pgrep -x sway >/dev/null 2>&1; then
    focused_output="$(swaymsg -t get_outputs | jq ".[] | select(.focused == true) | .name")"
    original_scale="$(swaymsg -t get_outputs | jq ".[] | select(.active == true) | .scale")"

    "$HOME"/.config/sway/scripts/goto-empty-workspace.py
    if [ "$original_scale" != "1.0" ]; then
        swaymsg output "$focused_output" scale 1
        sleep 0.5
    fi

elif pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch workspace empty >/dev/null

fi

exec wine "$@"
