#!/bin/bash
set -e

STORAGE_DIR="$HOME/AI/models"

# E.g., "RedHatAI/Qwen3-Coder-Next-NVFP4"
MODEL="$1"
MODEL_NAME="${MODEL##*'/'}"
MODEL_AUTHOR="${MODEL%%'/'*}"
MODEL_PATH="$STORAGE_DIR/${MODEL_AUTHOR}_${MODEL_NAME}"

if [ -d "$MODEL_PATH" ]; then
    read -n 1 -r -p "$MODEL_PATH already exits. Do you want ot remove it and re-download? [y/n] " res
    echo
    if [ "$res" != "y" ]; then
        echo -e "Cancelled\n"
        exit 0
    fi
    rm -rf "$MODEL_PATH"
fi

mkdir -p "$MODEL_PATH"
HF_HUB_DISABLE_TELEMETRY=1 hf download --local-dir "$MODEL_PATH" "$MODEL"
