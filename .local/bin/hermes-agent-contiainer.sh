#!/usr/bin/bash
set -e
exec bash <(
    sed -e 's:"$bin_path" :bash :' \
        -e 's:^current_path=.*:current_path="$HOME":' \
        "$HOME/.local/bin/hermes-agent.sh"
) "$@"
