#!/usr/bin/bash
set -e
exec bash <(
    sed "s:HOME/misc/repo/ingetrazo/ingetrazo:HOME/misc/repo/ingetrazo/ingetrazo-mcp:" \
        "$HOME/.local/bin/ingetrazo.sh"
) "$@"
