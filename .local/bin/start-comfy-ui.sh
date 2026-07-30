#!/usr/bin/bash
set -e
# ---------- Config ----------
comfy_ui_path="$HOME/misc/repo/comfy-ui"
venv_path="$HOME/Projects/AI/comfy-ui/venv"
model_path="$HOME/Projects/AI/comfy-ui/models"
output_path="$HOME/Projects/AI/comfy-ui/output"
input_path="$HOME/Projects/AI/comfy-ui/input"
port=8188

container_name="comfy-ui"

detach_mode=""
if [ "$1" == "-d" ]; then
    detach_mode="-d"
fi

## Container with internal network only
podman_cmd="podman run --rm -it --userns keep-id -u user --cap-drop=all $detach_mode"
podman_cmd+=" --shm-size=-0 --detach-keys='ctrl-q'  --init"
podman_cmd+=" --name '$container_name' --label '$container_name'"
podman_cmd+=" --network ai_internal --ip '192.168.0.2' --mac-address '44:33:22:11:00:02' -p $port:$port"

if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
    podman_cmd+=" --device 'nvidia.com/gpu=all'"
fi

podman_cmd+=" -v '$comfy_ui_path':/home/user/comfy-ui"
podman_cmd+=" -v '$venv_path':/home/user/venv"
podman_cmd+=" -v '$model_path':/home/user/comfy-ui/models"
podman_cmd+=" -v '$output_path':/home/user/comfy-ui/output"
podman_cmd+=" -v '$input_path':/home/user/comfy-ui/input"
podman_cmd+=" localhost/archlinux-ai-model-build"

## Container with internet, for downloading package for venv
podman_net_cmd="podman run --rm -it --userns keep-id -u user --cap-drop=all"
podman_net_cmd+=" --shm-size=-0 --detach-keys='ctrl-q'"
podman_net_cmd+=" --name '$container_name' --label '$container_name'"
podman_net_cmd+=" --network host"
podman_net_cmd+=" -v '$comfy_ui_path':/home/user/comfy-ui"
podman_net_cmd+=" -v '$venv_path':/home/user/venv"
podman_net_cmd+=" localhost/archlinux-ai-model-build"

# ---------- Check conditions to run ----------
if [ ! -f "$comfy_ui_path/main.py" ]; then
    echo "Comfy-UI is not installed. Missing '$comfy_ui_path/main.py'"
    exit 1
fi

if ! podman image exists "localhost/archlinux-ai-model-build"; then
    "$HOME/.local/bin/rebuild_ai_container_images.sh"
fi

if [ ! -d "$venv_path" ]; then
    echo "Creating venv..."
    mkdir -p "$venv_path"
    eval "$podman_net_cmd sh -c 'uv venv --seed --prompt comfy-ui --clear /home/user/venv; source /home/user/venv/bin/activate; uv pip install -r /home/user/comfy-ui/requirements.txt'"

    if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
        eval "$podman_net_cmd sh -c 'source /home/user/venv/bin/activate; uv pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130'"
    fi
fi

if podman container exists "$container_name"; then
    echo "$container_name is already running"
    notify-send "$container_name is already running"
    exit 0
fi

mkdir -p "$model_path" "$output_path" "$input_path"

# ---------- Run ----------
eval "$podman_cmd /home/user/venv/bin/python3 /home/user/comfy-ui/main.py --listen"
