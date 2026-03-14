#!/bin/bash
set -e

STORAGE_DIR="$HOME/workspace/AI/models"

MODEL="$1"
MODEL_NAME="${MODEL##*'/'}"
MODEL_AUTHOR="${MODEL%%'/'*}"
MODEL_PATH="$STORAGE_DIR/${MODEL_AUTHOR}_${MODEL_NAME}"
shift

include_paths=()
for p in "$@"; do
    if [[ "$p" != *.* ]] && [[ "$p" != */ ]]; then
        p="$p/"
    fi
    include_paths+=("--include" "$p")
done

if [ -d "$MODEL_PATH" ]; then
    download_date="$(find "$MODEL_PATH" -regex ".*/Download_[0-9-]*" -printf "%f\n" | head -n1 | sed "s:^Download_::")"
    if [ -n "$download_date" ]; then
        read -n 1 -r -p "Model was download on $download_date, do you want to remove it and re-download? [y/n] " res
        echo
        if [ "$res" != "y" ]; then
            echo -e "Cancelled\n"
            exit 0
        fi
    fi
    rm -rf "$MODEL_PATH"
fi

mkdir -p "$MODEL_PATH"
HF_HUB_DISABLE_TELEMETRY=1 hf download --local-dir "$MODEL_PATH" "$MODEL" "${include_paths[@]}"

exit_code="$?"
if [ "$exit_code" = 0 ]; then
    touch "$MODEL_PATH/Download_$(date "+%Y-%m-%d")"
fi
