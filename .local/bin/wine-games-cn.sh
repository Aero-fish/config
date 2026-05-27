#!/bin/bash
set -e
export LC_ALL=zh_CN.UTF-8
export WINEPREFIX="$HOME/.wine/games"

if pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null

fi

exec wine "$@"


