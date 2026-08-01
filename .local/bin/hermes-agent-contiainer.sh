#!/usr/bin/bash
set -e
exec bash <(sed 's:"$bin_path" :bash :' "$HOME/.local/bin/hermes-agent.sh") "$@"
