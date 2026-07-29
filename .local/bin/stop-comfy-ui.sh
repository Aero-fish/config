#!/usr/bin/bash
set -e

if podman container exists comfy-ui; then
    podman container stop comfy-ui
fi

