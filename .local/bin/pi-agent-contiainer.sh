#!/usr/bin/bash
set -e

exec bash <(
    sed -e 's:"$agent_path"/pi:bash:' \
        -e 's:^current_path=.*:current_path="$HOME":' \
        "$HOME/.local/bin/pi-agent.sh"
) "$@"

