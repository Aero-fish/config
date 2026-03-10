#!/bin/bash
set -e

running_llm="$(podman container ls --filter label=llm --format "{{.Names}}")"

if [ -n "$running_llm" ]; then
    printf '{"text":"%s", "tooltip": "%s"}' "󰬓 " "$running_llm"
else
    exit 1
fi
