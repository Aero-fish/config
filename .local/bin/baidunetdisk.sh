#!/bin/bash

set -e
[ "${UID}" -eq 0 ] && { echo "Do not run as root."; exit 0; }

# /tmp is used for detecting and reusing running instance.
mkdir -p "$HOME/.config/baidunetdisk"

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon

ro_bind_path+=(
    "$HOME/.config/dconf"
    "$HOME/.config/fontconfig"
    "$HOME/.local/share/fonts"
    "$HOME/misc/programs/baidunetdisk"
)

bind_path=(
    "$HOME/.config/baidunetdisk"
    "$HOME/Downloads"
)

source /usr/local/share/bwrap_share/generate_args

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
    9< /usr/local/share/seccomp-filter/default_seccomp_filter.bpf \
    \
    --dev /dev \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    --bind-try "$XDG_RUNTIME_DIR/code" "$XDG_RUNTIME_DIR" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    --ro-bind-try "$XDG_RUNTIME_DIR/tray-proxy" "$dbus_address" \
    \
    "$HOME"/misc/programs/baidunetdisk/baidunetdisk --no-sandbox >/dev/null >/dev/null 2>&1
