#!/bin/bash
set -e
export DXVK_HDR=1
export WINEPREFIX="$HOME/.wine/games"
unset DISPLAY

if pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null

fi

exec wine "$@"
