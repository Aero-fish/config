#!/usr/bin/bash
set -e
exec bash <(
    sed -e '/PROTON_ENABLE_HDR/d' \
        -e '/PROTON_USE_WAYLAND/d' \
        "$HOME"/.local/bin/proton.sh
) "$@"
