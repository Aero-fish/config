#!/bin/bash
set -e

running_ai_container="$(podman container ls --filter label="AI" --format "{{.Names}}")"

if [ -n "$running_ai_container" ]; then
    if [ -f "$XDG_RUNTIME_DIR/ai_ready" ]; then
        text="󰚩 "
    else
        text="󱙻 "
    fi
    printf '{"text":"%s", "tooltip": "%s"}' "$text" "$running_ai_container"
else
    exit 1
fi
