#!/bin/bash
set -e
export WINEPREFIX="$HOME/.wine/default"
exec wine "$@"
