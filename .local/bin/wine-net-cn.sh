#!/bin/bash
set -e
export LC_ALL=zh_CN.UTF-8
export WINEPREFIX="$HOME/.wine/net"
exec /usr/local/share/wine-net "$@"
