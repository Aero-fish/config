#!/usr/bin/bash
set -e

# ---------- Config ----------
STORAGE_DIR="$HOME/AI/models"
VLLM_MEM_UTILISATION=0.85
SGLANG_MEM_UTILISATION=0.92
PORT=8000

# ---------- Variables ----------
daemon_mode=0
framework="sglang" # vllm or sglang
selected_model=""

# ---------- Call container ----------
run_container() {
    local model_name="${selected_model##*'/'}"
    local model_author="${selected_model%%'/'*}"
    local model_container_path="/root/.cache/huggingface/${model_author}_${model_name}"
    local container_image_url=""
    local container_args=()
    local framework_args=()

    echo "Launching LLM: $selected_model"

    # ----- Container arguments -----
    if [ "$daemon_mode" = 1 ]; then
        container_args+=("-d")
    fi

    if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
        container_args+=("--device" "nvidia.com/gpu=all")
    fi

    # ----- Framework arguments -----
    if [ "$framework" = "vllm" ]; then
        container_image_url="docker.io/vllm/vllm-openai:cu130-nightly"
        framework_args+=(
            "$model_container_path" "--served-model-name" "$model_name"
            "--host" "0.0.0.0" "--port" "$PORT"
            "--gpu_memory_utilization" "$VLLM_MEM_UTILISATION"
        )

    elif [ "$framework" = "sglang" ]; then
        container_image_url="docker.io/lmsysorg/sglang:dev-cu13"
        framework_args+=("sglang" "serve" "--model-path" "$model_container_path"
            "--served-model-name" "$model_name" "--host" "0.0.0.0" "--port" "$PORT"
            "--attention-backend" "triton" "--mem-fraction-static" "$SGLANG_MEM_UTILISATION"
        )

    else
        echo "Unknown serving framework: $framework"
        notify-send "Unknown serving framework: $framework"
        exit 1

    fi

    # ----- Create network with no internet access for LLM -----
    if ! podman network exists llm; then
        podman network create --internal --driver=bridge \
            --gateway=192.168.0.254 --subnet=192.168.0.0/24 --interface-name=llm llm
    fi

    # ----- Run container -----
    podman run --name "$model_name" --label llm \
        --network llm --ip "192.168.0.1" --mac-address "44:33:22:11:00:01" -p 8000:8000 \
        -v "$STORAGE_DIR":/root/.cache/huggingface \
        --rm -it --ipc=host "${container_args[@]}" \
        "$container_image_url" "${framework_args[@]}" "$@"
}

# ---------- Check conditions to run ----------
# Exit if llm is already running
running_llm="$(podman container ls --filter label=llm --format "{{.Names}}")"
if [ -n "$running_llm" ]; then
    echo "A LLM is already running"
    notify-send "A LLM is already running"
    exit 0
fi

# ---------- Process arguments ----------
if [ "$1" = "-d" ]; then
    daemon_mode=1
    shift
fi

if [[ "$1" =~ (vllm|sglang) ]]; then
    framework="$1"
    shift
fi

if [ -n "$1" ]; then
    selected_model="$1"
    shift
fi

if [ -z "$selected_model" ]; then
    selected_model="$(
        find "$STORAGE_DIR" -mindepth 1 -maxdepth 1 ! -name ".*" -type d -printf '%P\n' |
            sed -E "s:^([^_]*)_:\1/:" |
            sort |
            grep -v "^$" |
            fzf --ignore-case --exact --reverse --prompt="LLM in $STORAGE_DIR:" --no-multi
    )"
fi

# ---------- Run ----------

case "$selected_model" in

*/Qwen3-Coder-*)
    if [ "$framework" = "sglang" ]; then
        run_container --context-length 262144 --tool-call-parser qwen3_coder

    elif [ "$framework" = "vllm" ]; then
        run_container --max-model-len 262144 --enable-prefix-caching \
            --enable-auto-tool-choice --tool-call-parser qwen3_coder
    fi
    ;;

*/Qwen3.5-*)
    if [ "$framework" = "sglang" ]; then
        run_container --context-length 262144 --reasoning-parser qwen3 \
            --tool-call-parser qwen3_coder

    elif [ "$framework" = "vllm" ]; then
        run_container --max-model-len 262144 --enable-prefix-caching \
            --reasoning-parser qwen3\ --enable-auto-tool-choice \
            --tool-call-parser qwen3_coder
    fi
    ;;

*)
    echo "Unknown model $selected_model"
    notify-send "Unknown model $selected_model"
    exit 1
    ;;

esac
