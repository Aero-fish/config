#!/usr/bin/bash
set -e

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon
source /usr/local/share/bwrap_share/printer_addon

mkdir -p "$HOME/.config/IngeTrazo" "$HOME/.local/"{share,state}"/IngeTrazo"

ro_bind_path+=(
    "/etc"
    "/opt"
    "$HOME/misc/repo/ingetrazo"
)

bind_path=(
    "$HOME/.config/IngeTrazo"
    "$HOME/.config/blender"
    "$HOME/.local/share/IngeTrazo"
    "$HOME/.local/state/IngeTrazo"
    "$HOME/workspace/3d"
)

generate_hide_default
generate_hide_rc
source /usr/local/share/bwrap_share/generate_args

bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
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
    9</usr/local/share/seccomp-filter/seccomp_filter_tiocsti.bpf \
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
    "${remount_ro[@]}" \
    "$HOME/misc/repo/ingetrazo/ingetrazo" "$@"
