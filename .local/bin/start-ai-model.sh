#!/usr/bin/bash
set -e

# ---------- Config ----------
model_lib_path="$HOME/workspace/ai_models"
template_path="$HOME/.config/ai/templates"
framework_config_path="$HOME/.config/ai/framework_config"
draft_model_lib_path="$HOME/workspace/ai_draft_model"

template_path_in_container="/templates"
model_path_in_container="/model"
draft_model_path_in_container="/draft_model"
container_label="AI"
serving_model_name="local_model"

port=8000

detach_mode=""
if [ "$1" == "-d" ]; then
    detach_mode="-d"
fi

# ---------- Check conditions to run ----------
if [ -n "$(podman container ls --filter label="$container_label" --format "{{.Names}}")" ]; then
    echo "Container with $container_label label is already running"
    notify-send "Container with $container_name label is already running"
    exit 0
fi

# ---------- Choose framework and model ----------
framework_name="$(
    find "$framework_config_path/" -mindepth 1 -maxdepth 1 -type d -printf '%P\n' |
        fzf --exact --reverse --prompt="Choose a framework:" --no-multi
)"

config_with_available_model=()
while read -r file; do
    file_basename="$(basename -s .conf -- "$file")"
    model_name="${file_basename##*'_'}"
    model_author="${file_basename%%'_'*}"
    if [ -d "$model_lib_path/${model_author}_${model_name}" ]; then
        config_with_available_model+=("$file")
    fi
done < <(find "$framework_config_path/$framework_name/" -mindepth 1 -maxdepth 1 -name "*.conf" -printf '%P\n')

if [ "${#config_with_available_model[@]}" -le 0 ]; then
    echo "No config, or all config has no corresponding model available."
    exit 0
fi

model_config_path="$(
    printf "%s\n" "${config_with_available_model[@]}" |
        grep -v -e "^$" |
        fzf --exact --reverse --prompt="Choose a model:" --no-multi
)"

file_basename="$(basename -s .conf -- "$model_config_path")"
model_name="${file_basename##*'_'}"
model_author="${file_basename%%'_'*}"

cache_path="$HOME/.cache/$framework_name"

mkdir -p "$model_lib_path" "$template_path" "$cache_path"

# ---------- pre-processing ----------

container_name="${framework_name}_${model_author}_${model_name}"
model_config_path="$framework_config_path/$framework_name/$model_config_path"

## Create internal network with no internet access
if ! podman network exists ai_internal; then
    podman network create --internal --driver=bridge \
        --gateway=192.168.0.254 --subnet=192.168.0.0/24 --interface-name=ai_internal \
        ai_internal >/dev/null
fi

## Container with internal network only
podman_cmd="podman run --rm -it --cap-drop=all $detach_mode"
podman_cmd+=" --shm-size=-0 --detach-keys='ctrl-q' --init"
podman_cmd+=" --name '$container_name' --label '$container_label'"

podman_cmd+=" --network ai_internal --ip '192.168.0.1' --mac-address '44:33:22:11:00:01' -p $port:$port"
# podman_cmd+=" --network host"

if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
    podman_cmd+=" --device 'nvidia.com/gpu=all'"
fi

podman_cmd+=" -v '$model_lib_path/${model_author}_${model_name}':'$model_path_in_container'"
podman_cmd+=" -v '$template_path':'$template_path_in_container'"
podman_cmd+=" -v '$cache_path':'/root/.cache'"
# podman_cmd+=" -v '$HOME/misc/repo/$framework_name':'/home/user/venv'"

config_args="$(grep -v -e "^#.*" "$model_config_path" | grep -v -e "^\s*$")"

if grep -v -e "^#.*" "$model_config_path" | grep -q "DRAFT_MODEL_PATH"; then
    draft_models=()
    base_model_name="$(echo "$model_name" | sed -E "s:(-UD)?-(NVFP4|FP8|GGUF|BF16|(MLX|unsloth-bnb)-[0-9]bit)$::")"

    readarray -d '' draft_models < <(find "$draft_model_lib_path" -name "*_${base_model_name}-*" -printf '%P\0')
    num_of_draft_models="${#draft_models[@]}"

    if [ "$num_of_draft_models" -eq 0 ]; then
        msg="Using draft model in config for '$base_model_name', but no matching draft model in '$draft_model_lib_path'."
        echo "$msg"
        notify-send "$msg"
        exit 1
    elif [ "$num_of_draft_models" -eq 1 ]; then
        draft_model_path="${draft_models[0]}"

    else
        draft_model_path="$draft_model_lib_path/$(
            printf "%s\n" "${draft_models[@]}" |
                fzf --exact --reverse --prompt="Choose a draft model:" --no-multi
        )"
    fi

    podman_cmd+=" -v '$draft_model_path':'$draft_model_path_in_container'"

    unset draft_models base_model_name num_of_draft_models msg draft_model_path
fi

config_args="$(
    grep -v -e "^#.*" "$model_config_path" |
        grep -v -e "^\s*$" |
        tr "\n" " " |
        sed -e "s:MODEL_PATH:$model_path_in_container:" \
            -e "s:TEMPLATE_PATH:$template_path_in_container:" \
            -e "s:DRAFT_MODEL_PATH:$draft_model_path_in_container:"
)"

# ---------- Run the framework  ----------

case "$framework_name" in

vllm)
    podman_cmd+=" --env 'VLLM_SERVER_DEV_MODE=1'"          ## Enable sleep, clear prefix cache etc.
    podman_cmd+=" --env 'VLLM_ALLOW_LONG_MAX_MODEL_LEN=1'" ## Enable 1M context
    # podman_cmd+=" --entrypoint '/bin/bash'"
    podman_cmd+=" docker.io/vllm/vllm-openai:latest"

    ## Model path must be the first argument, and currently is defined in config.
    vllm_cmd=" $config_args"
    vllm_cmd+="--enable-sleep-mode --served-model-name '$serving_model_name' "
    vllm_cmd+=" --host '0.0.0.0' --port $port"

    # echo "$podman_cmd $vllm_cmd"
    eval "$podman_cmd $vllm_cmd"
    ;;

sglang)
    # podman_cmd+=" --entrypoint '/bin/bash'"
    podman_cmd+=" docker.io/lmsysorg/sglang:latest-runtime"

    sgland_cmd="sglang serve --enable-memory-saver --served-model-name '$serving_model_name'"
    sgland_cmd+=" --host '0.0.0.0' --port $port"
    sgland_cmd+=" $config_args"

    # echo "$podman_cmd $sgland_cmd"
    eval "$podman_cmd $sgland_cmd"
    ;;

*)
    echo "Unknown framework $framework_name"
    notify-send "Unknown framework $framework_name"
    exit 1
    ;;

esac
