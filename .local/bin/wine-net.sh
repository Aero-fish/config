#!/bin/bash
set -e
export WINEPREFIX="$HOME/.wine/net"
unset DISPLAY
exec /usr/local/share/wine-net "$@"
