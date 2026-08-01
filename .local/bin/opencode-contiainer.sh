#!/usr/bin/bash
set -e

exec bash <(sed 's:"$agent_path"/opencode:bash:' "$HOME/.local/bin/opencode.sh") "$@"
