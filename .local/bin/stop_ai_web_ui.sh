#!/usr/bin/sh
set -e

if podman container exists open-webui; then
    podman container stop open-webui
fi

