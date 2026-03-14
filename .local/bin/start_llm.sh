#!/usr/bin/bash
set -e

# ---------- Config ----------
STORAGE_DIR="$HOME/workspace/AI/models"
VLLM_MEM_UTILISATION=0.85
SGLANG_MEM_UTILISATION=0.92
PORT=8000
declare -A AVAILABLE_FRAMEWORKS=(
    ["sglang"]=1
    ["vllm"]=1
    ["llama.cpp"]=1
)

# ---------- Variables ----------
daemon_mode=0
framework="sglang" # sglang, vllm or llama.cpp
selected_model=""

# ---------- Call container ----------
run_container() {
    local model_source_path="$STORAGE_DIR/$selected_model"
    local model_container_path="/models"
    local input_path_for_framework="/models"
    local model_name="${selected_model##*'/'}"
    local container_args=()
    local framework_args=()
    local container_image_url
    local gguf_file_name

    # Convert 'selected_model' to lower case before comparison
    if [[ "${selected_model,,}" =~ .*-gguf([$|-])* ]]; then
        gguf_file_name="$(find "$STORAGE_DIR/$selected_model" -name "*.gguf" -printf "%P\n" | head -n1)"
        input_path_for_framework="$input_path_for_framework/$gguf_file_name"
        model_name="$(basename --suffix=.gguf -- "$model_name")"
    fi
    echo "Launching LLM: $selected_model"

    # ----- Container arguments -----
    if [ "$daemon_mode" = 1 ]; then
        container_args+=("-d")
    fi

    if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
        container_args+=("--device" "nvidia.com/gpu=all")
    fi

    # ----- Framework arguments -----

    if [ "$framework" = "sglang" ]; then
        container_image_url="docker.io/lmsysorg/sglang:dev-cu13"
        framework_args+=(
            "sglang" "serve" "--model-path" "$input_path_for_framework"
            "--served-model-name" "$model_name" "--host" "0.0.0.0" "--port" "$PORT"
            "--attention-backend" "triton" "--mem-fraction-static" "$SGLANG_MEM_UTILISATION"
        )

    elif [ "$framework" = "vllm" ]; then
        container_image_url="docker.io/vllm/vllm-openai:cu130-nightly"
        framework_args+=(
            "$input_path_for_framework" "--served-model-name" "$model_name"
            "--host" "0.0.0.0" "--port" "$PORT"
            "--gpu_memory_utilization" "$VLLM_MEM_UTILISATION"
        )

    elif [ "$framework" = "llama.cpp" ]; then
        container_image_url="ghcr.io/ggml-org/llama.cpp:full-cuda"
        framework_args+=(
            "--server" "--model" "$input_path_for_framework" "--alias" "$model_name"
            "--host" "0.0.0.0" "--port" "$PORT" "--parallel" "2"
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
        -v "$model_source_path":"$model_container_path" \
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

if [ -n "$1" ] && [[ ${AVAILABLE_FRAMEWORKS["$1"]} ]]; then
    framework="$1"
    shift
fi

if [ -n "$1" ]; then
    selected_model="$1"
    shift
fi

if [ -z "$selected_model" ]; then
    framework="$(
        printf '%s\n' "${!AVAILABLE_FRAMEWORKS[@]}" |
            grep -v "^$" |
            fzf --ignore-case --exact --reverse --prompt="LLM in $STORAGE_DIR:" --no-multi
    )"

    selected_model="$(
        find "$STORAGE_DIR" -mindepth 1 -maxdepth 1 ! -name ".*" -type d -printf '%P\n' |
            sort |
            grep -v "^$" |
            fzf --ignore-case --exact --reverse --prompt="LLM in $STORAGE_DIR:" --no-multi
    )"
fi

# ---------- Run ----------

case "$selected_model" in

*_Qwen3-Coder-*)

    if [ "$framework" = "sglang" ]; then
        run_container --context-length 262144 --tool-call-parser qwen3_coder

    elif [ "$framework" = "vllm" ]; then
        run_container --max-model-len 262144 --enable-prefix-caching \
            --enable-auto-tool-choice --tool-call-parser qwen3_coder

    elif [ "$framework" = "llama.cpp" ]; then
        run_container --ctx-size 262144

    fi
    ;;

*_Qwen3.5-*)
    if [ "$framework" = "sglang" ]; then
        run_container --context-length 262144 --reasoning-parser qwen3 \
            --tool-call-parser qwen3_coder

    elif [ "$framework" = "vllm" ]; then
        run_container --max-model-len 262144 --enable-prefix-caching \
            --reasoning-parser qwen3\ --enable-auto-tool-choice \
            --tool-call-parser qwen3_coder

    elif [ "$framework" = "llama.cpp" ]; then
        run_container --ctx-size 262144

    fi
    ;;

*)
    echo "Unknown model $selected_model"
    notify-send "Unknown model $selected_model"
    exit 1
    ;;

esac
