#!/usr/bin/bash
set -e
trap 'echo -e "\e[31mUser interrupted.\e[0m"; exit 1' SIGINT

echo_red() {
    echo -e '\e[31m'"$1"'\e[0m'
}

linux_image_url="docker.io/library/archlinux:latest"

# Require 755 permission, since pacman download package as almp user.
mkdir -p "$HOME"/.snapshots/pacman-cache
chmod 755 "$HOME"/.snapshots/pacman-cache

## ---------- Container that include the GPU driver for running the LLM/Diffusion etc  ----------
image_name="archlinux-ai-model-build"
podman image rm --ignore "localhost/$image_name"
packages=(
    "base-devel" # Needed by comfy-ui as it calls gcc
    "git"
    "python" # sglang and vllm are python packages
    "ripgrep"
    "uv" # For installing older version of python. uv venv --python 3.12 --seed --managed-python
)

container=$(buildah from -v "$HOME"/.snapshots/pacman-cache:/var/cache/pacman/pkg "$linux_image_url")

echo_red "Ranking pacman mirrors"
buildah run "$container" pacman -Syu --noconfirm curl pacman-contrib
buildah run "$container" sh -c "echo '$(cat /etc/pacman.d/mirrorlist)' >/etc/pacman.d/mirrorlist"

echo_red "Installing packages"
buildah run "$container" sed -i -E 's:^#\s*ParallelDownloads\s*.*:ParallelDownloads = 5:' /etc/pacman.conf
buildah run "$container" pacman -Syu --noconfirm --needed "${packages[@]}"

if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
    echo_red "Install driver for Nvidia"
    buildah run "$container" pacman -Syu --noconfirm --needed nvidia-open
fi

buildah run "$container" paccache -rk1

echo_red "Adding 'user'"
buildah run "$container" useradd -m -u 1000 user
buildah run "$container" sh -c 'echo "123Ab2.9" | passwd --stdin user'
buildah run "$container" sed -i "$ a \ unset HISTFILE" /etc/bash.bashrc

echo_red "Starting path /home/user"
buildah config --workingdir /home/user "$container"

echo_red "Commit image '$image_name'"
buildah run "$container" \
    rm -f /etc/pacman.d/gnupg/S.gpg-agent /etc/pacman.d/gnupg/S.gpg-agent.browser \
    /etc/pacman.d/gnupg/S.gpg-agent.extra /etc/pacman.d/gnupg/S.gpg-agent.ssh

buildah config --cmd "/bin/bash" "$container"
buildah commit --squash "$container" "$image_name"

echo_red "Clean up"
buildah rm "$container"

## ---------- Create a network that allows internal access only  ----------
if ! podman network exists ai_internal; then
    podman network create --internal --driver=bridge \
        --gateway=192.168.0.254 --subnet=192.168.0.0/24 --interface-name=ai_internal \
        ai_internal >/dev/null
fi
