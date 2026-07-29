#!/usr/bin/bash
set -e
trap 'echo -e "\e[31mUser interrupted.\e[0m"; exit 1' SIGINT

echo_red() {
    echo -e '\e[31m'"$1"'\e[0m'
}

linux_image_url="docker.io/library/archlinux:latest"
image_name="archlinux-aur-build"
packages=(
    "base-devel"
    "vim"
    "vifm"
    "git"
    "cmake"
    "patchelf"
    "less"
)

podman image rm --ignore "localhost/$image_name"

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
buildah run "$container" sed -i "$ a user ALL=(ALL) NOPASSWD: ALL" /etc/sudoers
buildah run "$container" sed -i "$ a \ unset HISTFILE" /etc/bash.bashrc

echo_red "Starting path /home/user"
buildah config --workingdir /home/user "$container"

echo_red "Commit image '$image_name'"
buildah run "$container" \
    rm -f /etc/pacman.d/gnupg/S.gpg-agent /etc/pacman.d/gnupg/S.gpg-agent.browser \
    /etc/pacman.d/gnupg/S.gpg-agent.extra /etc/pacman.d/gnupg/S.gpg-agent.ssh

buildah config --cmd "/bin/bash" "$container"
buildah commit "$container" "$image_name"

echo_red "Clean up"
buildah rm "$container"
