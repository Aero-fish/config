#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && {
    echo "Do not run as root."
    exit 0
}

mkdir -p "$HOME/Pictures/yuzu"

source /usr/local/share/bwrap_share/strict_rules

ro_bind_path+=(
    "$HOME/.config/dconf"
    "$HOME/.local/share/fonts"
    "$HOME/misc/programs/yuzu"
    "$HOME/win_d/Games/switch/games"
)

source /usr/local/share/bwrap_share/generate_args

if pgrep -x sway >/dev/null; then
    active_output="$(swaymsg -t get_outputs | jq ".[] | select(.focused == true) | .name")"
    original_scale="$(swaymsg -t get_outputs | jq ".[] | select(.focused == true) | .scale")"

    "$HOME"/.config/sway/scripts/goto-empty-workspace.py
    if [ "$original_scale" != "1" ]; then
        swaymsg output "$active_output" scale 1
        sleep 0.5
    fi

elif pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch workspace empty >/dev/null

fi

user_config=()
if [ -d "$HOME/win_d/Games/switch/yuzu_config" ]; then
    mkdir -p "$HOME/win_d/Games/switch/yuzu_config/"{config,local}
    user_config+=("--bind-try" "$HOME/win_d/Games/switch/yuzu_config/config" "$HOME/.config/yuzu")
    user_config+=("--bind-try" "$HOME/win_d/Games/switch/yuzu_config/local" "$HOME/.local/share/yuzu")

else
    mkdir -p "$HOME"/.config/yuzu/config "$HOME"/.config/yuzu/local
    user_config+=("--bind-try" "$HOME/.config/yuzu/config" "$HOME/.config/yuzu")
    user_config+=("--bind-try" "$HOME/.config/yuzu/local" "$HOME/.local/share/yuzu")

fi

user_config+=("--bind-try" "$HOME/Pictures/yuzu" "$HOME/.local/share/yuzu/screenshots")

if [ -d "$HOME/win_d/Games/switch/firmware" ]; then
    user_config+=("--bind-try" "$HOME/win_d/Games/switch/firmware" "$HOME/.local/share/yuzu/nand")
fi

if [ -d "$HOME/win_d/Games/switch/keys" ]; then
    user_config+=("--bind-try" "$HOME/win_d/Games/switch/keys" "$HOME/.local/share/yuzu/keys")
fi

## Inhibit is handled by the custom lock and suspend scripts for sway and hyprland.
## So it will not lock if yuzu is in focus only.
## May need  "--setenv QT_QPA_PLATFORM "xcb"' to run on xwayland
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
    9</usr/local/share/seccomp-filter/default_seccomp_filter.bpf \
    \
    --setenv LD_LIBRARY_PATH "$HOME/misc/programs/yuzu/lib:$LD_LIBRARY_PATH" \
    \
    --dev /dev \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${user_config[@]}" \
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    --ro-bind-try "$XDG_RUNTIME_DIR"/tray-proxy "$dbus_address" \
    --perms 444 --file 8 /etc/machine-id 8< <(dbus-uuidgen) \
    "$HOME"/misc/programs/yuzu/yuzu "$@"
