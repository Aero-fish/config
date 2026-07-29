#!/usr/bin/bash
set -e
trap 'echo -e "\e[31mUser interrupted.\e[0m"; exit 1' SIGINT

echo_red() {
    echo -e '\e[31m'"$1"'\e[0m'
}

linux_image_url="docker.io/library/archlinux:latest"

## ---------- Container for AI agents ----------
ai_agent_image_name="archlinux-ai-agent-build"
ai_model_image_name="archlinux-ai-model-build"

podman image rm --ignore \
    "localhost/$ai_agent_image_name" "localhost/$ai_model_image_name"

packages=(
    "base-devel"
    "python"
    "git"
    "ripgrep"
)

# Require 755 permission, since pacman download package as almp user.
mkdir -p "$HOME"/.snapshots/pacman-cache
chmod 755 "$HOME"/.snapshots/pacman-cache

container=$(buildah from -v "$HOME"/.snapshots/pacman-cache:/var/cache/pacman/pkg "$linux_image_url")

echo_red "Ranking pacman mirrors"
buildah run "$container" pacman -Syu --noconfirm curl pacman-contrib
buildah run "$container" sh -c "echo '$(cat /etc/pacman.d/mirrorlist)' >/etc/pacman.d/mirrorlist"

echo_red "Installing base-devel"
buildah run "$container" sed -i -E 's:^#\s*ParallelDownloads\s*.*:ParallelDownloads = 5:' /etc/pacman.conf
buildah run "$container" pacman -Syu --noconfirm --needed "${packages[@]}"
buildah run "$container" paccache -rk1

echo_red "Adding 'user'"
buildah run "$container" useradd -m -u 1000 user
buildah run "$container" sh -c 'echo "123Ab2.9" | passwd --stdin user'
buildah run "$container" sed -i "$ a \ unset HISTFILE" /etc/bash.bashrc

echo_red "Starting path /home/user"
buildah config --workingdir /home/user "$container"

echo_red "Commit image '$ai_agent_image_name'"
buildah run "$container" \
    rm -f /etc/pacman.d/gnupg/S.gpg-agent /etc/pacman.d/gnupg/S.gpg-agent.browser \
    /etc/pacman.d/gnupg/S.gpg-agent.extra /etc/pacman.d/gnupg/S.gpg-agent.ssh

buildah config --cmd "/bin/bash" "$container"
buildah commit "$container" "$ai_agent_image_name"

## ---------- Container that include the GPU driver for running the LLM/Diffusion etc  ----------
if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
    echo_red "Install driver for Nvidia"
    buildah run "$container" pacman -Syu --noconfirm --needed nvidia-open
fi

echo_red "Commit image '$ai_model_image_name'"
buildah run "$container" \
    rm -f /etc/pacman.d/gnupg/S.gpg-agent /etc/pacman.d/gnupg/S.gpg-agent.browser \
    /etc/pacman.d/gnupg/S.gpg-agent.extra /etc/pacman.d/gnupg/S.gpg-agent.ssh

buildah config --cmd "/bin/bash" "$container"
buildah commit "$container" "$ai_model_image_name"

echo_red "Clean up"
buildah rm "$container"

## ---------- Network that allows internal access only  ----------
if ! podman network exists ai_internal; then
    podman network create --internal --driver=bridge \
        --gateway=192.168.0.254 --subnet=192.168.0.0/24 --interface-name=ai_internal \
        ai_internal >/dev/null
fi
