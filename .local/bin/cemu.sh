#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && {
    echo "Do not run as root."
    exit 0
}

mkdir -p "$HOME/Pictures/yuzu"

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon

ro_bind_path+=(
    "$HOME/.config/dconf"
    "$HOME/.local/share/fonts"
    "$HOME/misc/programs/cemu"
    "$HOME/win_d/Games/Wii U/games"
)

source /usr/local/share/bwrap_share/generate_args

if pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null
fi

user_config=()
if [ -d "$HOME/win_d/Games/Wii U/cemu_config" ]; then
    mkdir -p "$HOME/win_d/Games/Wii U/cemu_config/"{config,local}
    user_config+=("--bind-try" "$HOME/win_d/Games/Wii U/cemu_config/config" "$HOME/.config/Cemu")
    user_config+=("--bind-try" "$HOME/win_d/Games/Wii U/cemu_config/local" "$HOME/.local/share/Cemu")

else
    mkdir -p "$HOME"/.config/cemu/{config,local}
    user_config+=("--bind-try" "$HOME/.config/cemu/config" "$HOME/.config/Cemu")
    user_config+=("--bind-try" "$HOME/.config/cemu/local" "$HOME/.local/share/Cemu")

fi

## Inhibit is handled by the custom lock and suspend scripts for hyprland.
## So it will not lock if cemu is in focus only.
bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-net \
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
    --seccomp 1 \
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
    "${user_config[@]}" \
    --ro-bind-try "$XDG_RUNTIME_DIR/tray-proxy" "$dbus_address" \
    --perms 444 --file 0 /etc/machine-id \
    "$HOME"/misc/programs/cemu/Cemu "$@" 1</usr/local/share/seccomp-filter/default_seccomp_filter.bpf 0< <(dbus-uuidgen)
