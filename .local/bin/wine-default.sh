#!/bin/bash
set -e
export WINEPREFIX="$HOME/.wine/default"
unset DISPLAY
exec wine "$@"
