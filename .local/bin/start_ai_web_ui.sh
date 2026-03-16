#!/usr/bin/bash
set -e

# ---------- Config ----------
STORAGE_DIR="$HOME/workspace/AI/webUI"

# ---------- Check conditions to run ----------
if podman container exists open-webui; then
    echo "Web UI is already running"
    notify-send "Web UI is already running"
    exit 0
fi
mkdir -p "$STORAGE_DIR"

# ----- Create network with no internet access for LLM -----
if ! podman network exists llm; then
    podman network create --internal --driver=bridge \
        --gateway=192.168.0.254 --subnet=192.168.0.0/24 --interface-name=llm llm
fi

# ---------- Run ----------
podman run -d --name open-webui \
    -v "$STORAGE_DIR":/app/backend/data \
    --network llm --ip "192.168.0.2" --mac-address "44:33:22:11:00:02" -p 8080:8080 \
    --rm -it \
    --env "OPENAI_API_BASE_URL=http://192.168.0.1:8000/v1" \
    ghcr.io/open-webui/open-webui:main
