#!/bin/bash
set -e
exec bash <(
    sed -e '/\/usr\/local\/share\/bwrap_share\/strict_rules/a\source /usr/local/share/bwrap_share/net_addon\n' \
        -e '/--unshare-net/d' \
        "$HOME"/.local/bin/proton.sh
) "$@"
