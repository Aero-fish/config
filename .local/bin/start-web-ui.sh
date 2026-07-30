#!/usr/bin/bash
set -e
# ---------- Config ----------
storage_path="$HOME/Projects/AI/web-ui"
port=8080
container_name="open-webui"

detach_mode=""
if [ "$1" == "-d" ]; then
    detach_mode="-d"
fi

# ---------- Check conditions to run ----------
if podman container exists "$container_name"; then
    echo "$container_name is already running"
    notify-send "$container_name is already running"
    exit 0
fi

mkdir -p "$storage_path"

# ---------- Run ----------
podman_cmd="podman run --rm -it --cap-drop=all $detach_mode"
podman_cmd+=" --shm-size=-0 --detach-keys='ctrl-q' --init"
podman_cmd+=" --name '$container_name' --label '$container_name'"
podman_cmd+=" --network ai_internal --ip '192.168.0.3' --mac-address '44:33:22:11:00:03' -p $port:$port"
# podman_cmd+=" --network host"
podman_cmd+=" --env 'OPENAI_API_BASE_URL=http://192.168.0.1:8000/v1'"
podman_cmd+=" --env 'CORS_ALLOW_ORIGIN=*'"
podman_cmd+=" --env 'WEB_SEARCH_TRUST_ENV=True'"
podman_cmd+=" --env 'OFFLINE_MODE=true'"
podman_cmd+=" -v '$storage_path':/app/backend/data"
podman_cmd+=" ghcr.io/open-webui/open-webui:main"

eval "$podman_cmd"
