#!/usr/bin/bash
set -e

while IFS= read -r container_name; do
    if [ -z "$container_name" ]; then
        continue
    fi
    podman container stop "$container_name"
done <<< "$(podman container ls --filter label=llm --format "{{.Names}}")"

