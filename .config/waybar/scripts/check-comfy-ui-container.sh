#!/bin/bash
set -e

running_comfy_ui_container="$(podman container ls --filter label="comfy-ui" --format "{{.Names}}")"

if [ -n "$running_comfy_ui_container" ]; then
    printf '{"text":"%s", "tooltip": "%s"}' "󱄥 " "$running_comfy_ui_container"
else
    exit 1
fi
