#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && { echo "Do not run as root."; exit 0; }

mkdir -p "$HOME/Desktop" "$HOME/.config/localsend"

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon

ro_bind_path+=(
    "$HOME/.config/fontconfig"
    "$HOME/.local/share/fonts"
    "$HOME/misc/repo/localsend"
    "$dbus_address"
)

bind_path=(
    "$HOME/Desktop"
)

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
    9< /usr/local/share/seccomp-filter/seccomp_filter_allow_chroot_kcmp.bpf \
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
    --bind-try "$HOME/.config/localsend/shared_preferences.json" "$HOME/.local/share/localsend_app/shared_preferences.json" \
    "$HOME/misc/repo/localsend/AppRun"
