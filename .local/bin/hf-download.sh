#!/usr/bin/bash
set -e

storage_path="$HOME/Projects/AI/models"
hf_path="$HOME/misc/repo/huggingface-hub"
hf_bin="$HOME/misc/repo/huggingface-hub/bin/hf"
token_path="$HOME/.config/my-config/hf_token"

if [ ! -x "$hf_bin" ]; then
    echo "'hf' executable not found"
    exit 1
fi

model="$1"
model_name="${model##*'/'}"
model_author="${model%%'/'*}"
model_path="$storage_path/${model_author}_${model_name}"
shift

include_paths=()
for p in "$@"; do
    if [[ "$p" != *.* ]] && [[ "$p" != */ ]]; then
        p="$p/"
    fi
    include_paths+=("--include" "$p")
done

if [ -d "$model_path" ]; then
    download_date="$(find "$model_path" -regex ".*/Download_[0-9-]*" -printf "%f\n" | head -n1 | sed "s:^Download_::")"
    if [ -n "$download_date" ]; then
        read -n 1 -r -p "Model was download on $download_date, do you want to remove it and re-download? [y/n] " res
        echo
        if [ "$res" != "y" ]; then
            echo -e "Cancelled\n"
            exit 0
        fi
    fi
    rm -rf "$model_path"
fi

mkdir -p "$model_path"
token_args=()
if [ -f "$token_path" ]; then
    token_args+=("--token" "$(cat "$token_path")")
fi

/usr/local/bin/generic_bwrap \
    --setenv HF_HUB_DISABLE_TELEMETRY 1 \
    --bind "$model_path" "$model_path" \
    --ro-bind "$hf_path" "$hf_path" \
    "$hf_bin" download "${token_args[@]}" --local-dir "$model_path" "$model" "${include_paths[@]}"

exit_code="$?"
if [ "$exit_code" = 0 ]; then
    touch "$model_path/Downloaded_$(date "+%Y-%m-%d")"
fi
