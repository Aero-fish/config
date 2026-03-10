#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && { echo "Do not run as root."; exit 0; }

mkdir -p "$HOME/.config/xnviewmp"

source /usr/local/share/bwrap_share/strict_rules

bind_path=(
    "$HOME"
    "/run/media"
)

generate_hide_default
source /usr/local/share/bwrap_share/generate_args

bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-net \
    --unshare-uts \
    --unshare-cgroup \
    \
    --disable-userns \
    --hostname my-pc \
    --proc /proc \
    --cap-drop ALL \
    --new-session \
    --die-with-parent \
    --seccomp 9 \
    9< /usr/local/share/seccomp-filter/seccomp_filter_allow_kcmp.bpf \
    \
    --dev /dev \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    --ro-bind-try "$XDG_RUNTIME_DIR"/tray-proxy "$dbus_address" \
    "$HOME/misc/programs/XnView/xnview.sh" "$@"

