#!/bin/bash
set -e
export WINEPREFIX="$HOME/.wine/net"
exec /usr/local/share/wine-net "$@"
