#!/usr/bin/bash
set -e

while IFS= read -r container_name; do
    podman container stop "$container_name"
done <<< "$(podman container ls --filter label=llm --format "{{.Names}}")"

