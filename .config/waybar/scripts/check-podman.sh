#!/bin/bash
set -e

running_container="$(podman container ls --format "{{.Names}}")"

if [ -n "$running_container" ]; then
    printf '{"text":"%s", "tooltip": "%s"}' " " "${running_container/$'\n'/\\\n}"
else
    exit 1
fi
