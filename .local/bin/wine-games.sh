#!/bin/bash
set -e
export DXVK_HDR=1
export WINEPREFIX="$HOME/.wine/games"
unset DISPLAY

if ! [[ "$1" =~ wineboot(\.exe)? ]] && ! [[ "$1" =~ winecfg(\.exe)? ]] && ! [[ "$1" =~ regedit(\.exe)? ]]; then
    if pgrep -x Hyprland >/dev/null; then
        hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null
    fi
fi

exec wine "$@"
