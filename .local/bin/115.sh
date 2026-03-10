#!/bin/bash

set -e
[ "${UID}" -eq 0 ] && { echo "Do not run as root."; exit 0; }

# /tmp is used for detecting and reusing running instance.
mkdir -p "$HOME/.config/115" "/tmp/115"

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon

tmpfs_path=(
    "/boot"
    "/etc"
    "/home"
    "/mnt"
    "/opt"
    "/root"
    "/run"
    "/srv"
    "/sys"
    "/usr"
    "/var"
)

ro_bind_path+=(
    "$HOME/.config/dconf"
    "$HOME/.config/fontconfig"
    "$HOME/.local/share/fonts"
    "$HOME/misc/programs/115Browser"
)

bind_path=(
    "$HOME/Downloads"
)

source /usr/local/share/bwrap_share/generate_args

# Need to expose --dev-bind / /, or it will say insufficient disk when downloading.
bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --unshare-cgroup \
    \
    --hostname my-pc \
    --proc /proc \
    --cap-drop ALL \
    --new-session \
    --die-with-parent \
    --seccomp 9 \
    9< /usr/local/share/seccomp-filter/seccomp_filter_allow_chroot_kcmp.bpf \
    \
    --dev-bind / / \
    "${tmpfs[@]}" \
    --dev /dev \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    --bind-try "$HOME/.config/115" "$HOME/.config/chromium" \
    --ro-bind-try "$XDG_RUNTIME_DIR/tray-proxy" "$dbus_address" \
    --bind-try /tmp/115 /tmp \
    \
    --setenv LD_LIBRARY_PATH "$HOME/misc/programs/115Browser" \
    \
    --chdir $HOME/misc/programs/115Browser \
    "$HOME"/misc/programs/115Browser/115Browser \
    --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3 \
    >/dev/null 2>&1
