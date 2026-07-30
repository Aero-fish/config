#!/usr/bin/bash
set -e

images_url=(
    "docker.io/library/archlinux:latest"
    "ghcr.io/open-webui/open-webui:main"
    "docker.io/vllm/vllm-openai:latest"
    "docker.io/lmsysorg/sglang:latest-runtime"
)

for url in "${images_url[@]}"; do
    podman pull "$url"
done
rebuild_ai_container_images.sh
rebuild_aur_container_images.sh
