#!/usr/bin/bash
set -e

exec bash <(
    sed 's:"$agent_path"/opencode:bash:' \
        -e 's:^current_path=.*:current_path="$HOME":' \
        "$HOME/.local/bin/opencode.sh"
) "$@"
