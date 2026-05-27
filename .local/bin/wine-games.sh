#!/bin/bash
set -e
export ENABLE_HDR_WSI=1
export DXVK_HDR=1
export DISPLAY=
export WINEPREFIX="$HOME/.wine/games"

if pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null

fi

exec wine "$@"
