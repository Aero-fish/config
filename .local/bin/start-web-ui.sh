#!/usr/bin/bash
set -e
# ---------- Config ----------
storage_path="$HOME/Projects/AI/webUI"
venv_path="$HOME/misc/repo/web-ui"
port=8080

if [ ! -f "$venv_path/bin/cptr" ]; then
    echo "WebUI is not installed. Missing '$venv_path/bin/cptr'"
    exit 1
fi

daemon_mode=""
if [ "$1" == "-d" ]; then
    daemon_mode="-d"
fi

# ---------- Check conditions to run ----------
if podman container exists open-webui; then
    echo "Web UI is already running"
    notify-send "Web UI is already running"
    exit 0
fi
mkdir -p "$storage_path"

# ---------- Run ----------
podman run --rm -it --userns keep-id -u user "$daemon_mode" \
    --name web-ui --label web-ui \
    --network ai_internal --ip '192.168.0.3' --mac-address '44:33:22:11:00:03' -p "$port:$port" \
    --env "OPENAI_API_BASE_URL=http://192.168.0.1:8000/v1" \
    -v "$storage_path":/home/user/.cptr \
    -v "$venv_path":/home/user/venv \
    "localhost/archlinux-ai-agent-build" \
    /home/user/venv/bin/cptr run --host 0.0.0.0 --port "$port" --headless
