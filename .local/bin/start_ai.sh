#!/usr/bin/bash
set -e

# ---------- Config ----------
MODEL_DIR="$HOME/workspace/AI/models"
TEMPLATE_DIR="$HOME/workspace/AI/templates"
TEMPLATE_CONTAINER_PATH="/templates"
AI_CONTAINER_LABEL="AI"
VLLM_MEM_UTILISATION=0.90
SGLANG_MEM_UTILISATION=0.92
PORT=8000
UNIVERSAL_MODEL_NAME="local_model"
AI_READY_FLAG="$XDG_RUNTIME_DIR/ai_ready"

declare -A AVAILABLE_FRAMEWORKS=(
    ["sglang"]=1
    ["vllm"]=1
    ["llama.cpp"]=1
)

# ---------- Variables ----------
daemon_mode=0
framework="vllm" # sglang, vllm or llama.cpp
selected_model=""

# ---------- Functions ----------
##### Run container #####
run_container() {
    local model_source_path="$MODEL_DIR/$selected_model"
    local model_container_path="/models"
    local input_path_for_framework="/models"
    local model_name="${selected_model##*'/'}"
    local container_args=()
    local framework_args=()
    local container_image_url
    local gguf_file_name

    # Convert 'selected_model' to lower case before comparison
    if [[ "${selected_model,,}" =~ .*-gguf([$|-])* ]]; then
        gguf_file_name="$(find "$MODEL_DIR/$selected_model" -name "*.gguf" -printf "%P\n" | head -n1)"
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
            "--served-model-name" "$UNIVERSAL_MODEL_NAME" "--host" "0.0.0.0" "--port" "$PORT"
            "--attention-backend" "triton" "--mem-fraction-static" "$SGLANG_MEM_UTILISATION"
        )

    elif [ "$framework" = "vllm" ]; then
        container_image_url="docker.io/vllm/vllm-openai:cu130-nightly"
        framework_args+=(
            "$input_path_for_framework" "--served-model-name" "$UNIVERSAL_MODEL_NAME"
            "--host" "0.0.0.0" "--port" "$PORT"
            "--gpu_memory_utilization" "$VLLM_MEM_UTILISATION"
        )

    elif [ "$framework" = "llama.cpp" ]; then
        container_image_url="ghcr.io/ggml-org/llama.cpp:full-cuda"
        framework_args+=(
            "--server" "--model" "$input_path_for_framework" "--alias" "$UNIVERSAL_MODEL_NAME"
            "--host" "0.0.0.0" "--port" "$PORT" "--parallel" "2"
        )

    else
        if [ "$daemon_mode" -eq 1 ]; then
            notify-send "Unknown serving framework: $framework"
        else
            echo "Unknown serving framework: $framework"
        fi
        exit 1

    fi

    # ----- Create network with no internet access for LLM -----
    if ! podman network exists llm; then
        podman network create --internal --driver=bridge \
            --gateway=192.168.0.254 --subnet=192.168.0.0/24 --interface-name=llm llm
    fi

    # ----- Run container -----
    podman run --name "$framework-$model_name" --label "$AI_CONTAINER_LABEL" \
        --network llm --ip "192.168.0.1" --mac-address "44:33:22:11:00:01" -p 8000:8000 \
        -v "$model_source_path":"$model_container_path" \
        -v "$TEMPLATE_DIR":"$TEMPLATE_CONTAINER_PATH" \
        --rm -it --ipc=host "${container_args[@]}" \
        "$container_image_url" "${framework_args[@]}" "$@"
}

##### Wait for openAI compatible model to be ready #####
notify_on_open_ai_compatable_model_ready() {
    cat <<EOF >"$XDG_RUNTIME_DIR/wait_open_ai_compatible_model_ready.sh"
#!/usr/bin/bash
while true; do
    sleep 3
    curl "127.0.0.1:8000/v1/models"
    exit_code="\$?"
    echo "\$exit_code"
    if [ "\$exit_code" -eq 7 ]; then
        notify-send "AI container is not running"
        break
    elif [ "\$exit_code" -eq 0 ]; then
        touch "$AI_READY_FLAG"
        break
    fi
done

rm "\$0"
EOF

    setsid /usr/bin/bash "$XDG_RUNTIME_DIR/wait_open_ai_compatible_model_ready.sh" >/dev/null 2>&1 </dev/null &

}

# ---------- Check conditions to run ----------
# Exit if AI model is already running
running_model="$(podman container ls --filter label="$AI_CONTAINER_LABEL" --format "{{.Names}}")"
if [ -n "$running_model" ]; then
    if [ "$daemon_mode" = 1 ]; then
        notify-send "AI container is already running"
    else
        echo "AI container is already running"
    fi
    exit 0
fi

# ---------- House keeping ----------
mkdir -p "$MODEL_DIR" "$TEMPLATE_DIR"
rm -f "$AI_READY_FLAG"

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
            fzf --ignore-case --exact --reverse --prompt="LLM in $MODEL_DIR:" --no-multi
    )"

    selected_model="$(
        find "$MODEL_DIR" -mindepth 1 -maxdepth 1 ! -name ".*" -type d -printf '%P\n' |
            sort |
            grep -v "^$" |
            fzf --ignore-case --exact --reverse --prompt="LLM in $MODEL_DIR:" --no-multi
    )"
fi

# ---------- Run ----------
case "$selected_model" in

*_Qwen3-Coder-*)

    if [ "$framework" = "sglang" ]; then
        ## WARNING server_args.py:2046: Disabling overlap schedule since
        ## mamba no_buffer is not compatible with overlap schedule, try to
        ## use --disable-radix-cache if overlap schedule is necessary
        ## Temp solution: --mamba-scheduler-strategy extra_buffer

        run_container --context-length 262144 --kv-cache-dtype fp8_e4m3 \
            --tool-call-parser qwen3_coder \
            --mamba-scheduler-strategy extra_buffer

    elif [ "$framework" = "vllm" ]; then
        run_container --max-model-len 262144 --enable-prefix-caching \
            --kv_cache_dtype fp8_e4m3 \
            --enable-auto-tool-choice --tool-call-parser qwen3_coder

    elif [ "$framework" = "llama.cpp" ]; then
        run_container --ctx-size 262144 --cache-type-k q8_0 --cache-type-v q8_0

    fi

    if [ "$daemon_mode" -eq 1 ]; then
        notify_on_open_ai_compatable_model_ready
    fi
    ;;

*_Qwen3.5-*)
    if [ "$framework" = "sglang" ]; then
        ## WARNING server_args.py:2046: Disabling overlap schedule since
        ## mamba no_buffer is not compatible with overlap schedule, try to
        ## use --disable-radix-cache if overlap schedule is necessary
        ## Temp solution: --mamba-scheduler-strategy extra_buffer

        ## Use customised template to disable thinking. However, disable thinking
        ## is in conflict with --reasoning-parser qwen3

        run_container --context-length 262144 --kv-cache-dtype fp8_e4m3 \
            --tool-call-parser qwen3_coder \
            --chat-template "$TEMPLATE_CONTAINER_PATH/qwen3.5_no_thinking.jinja" \
            --mamba-scheduler-strategy extra_buffer

    elif [ "$framework" = "vllm" ]; then
        ## Disable thinking is in conflict with --reasoning-parser qwen3
        run_container --max-model-len 262144 --enable-prefix-caching \
            --kv_cache_dtype fp8_e4m3 \
            --enable-auto-tool-choice --tool-call-parser qwen3_coder \
            --default-chat-template-kwargs '{"enable_thinking":false}'

    elif [ "$framework" = "llama.cpp" ]; then
        if [ "$daemon_mode" -eq 1 ]; then
            notify_on_open_ai_compatable_model_ready
        fi
        run_container --ctx-size 262144 --cache-type-k q8_0 --cache-type-v q8_0 \
            --chat-template-kwargs '{"enable_thinking":false}'

    fi

    if [ "$daemon_mode" -eq 1 ]; then
        notify_on_open_ai_compatable_model_ready
    fi
    ;;

*)
    echo "Unknown model $selected_model"
    notify-send "Unknown model $selected_model"
    exit 1
    ;;

esac
