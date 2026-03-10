#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && { echo "Do not run as root."; exit 0; }


source /usr/local/share/bwrap_share/strict_rules

dev_bind_path=(
    "/dev"
)

ro_bind_path+=(
    "$HOME/.config/dconf"
    "$HOME/.local/share/fonts"
    "$HOME/misc/programs/ryujinx"
    "$HOME/win_d/Games/switch/games"
)


## Bubble wrap always trace a symbolic link instead of bind-mount to it.
## Cannot replace or do anything to symbolic links, so need to keep the source
## file / dir visible.
hide_path+=(
    "$HOME/.cache"
    "$HOME/misc/programs/ryujinx/Logs"
)

source /usr/local/share/bwrap_share/generate_args

user_config=()
if [ -d "$HOME/win_d/Games/switch/ryujinx_config" ]; then
    user_config+=("--bind-try" "$HOME/win_d/Games/switch/ryujinx_config" "$HOME/.config/Ryujinx")

else
    mkdir -p "$HOME"/.config/Ryujinx
    user_config+=("--bind-try" "$HOME/.config/Ryujinx" "$HOME/.config/Ryujinx")

fi

if [ -d "$HOME/win_d/Games/switch/firmware" ]; then
    user_config+=("--bind-try" "$HOME/win_d/Games/switch/firmware" "$HOME/.config/Ryujinx/bis")
fi


if [ -d "$HOME/win_d/Games/switch/keys" ]; then
    user_config+=("--bind-try" "$HOME/win_d/Games/switch/keys" "$HOME/.config/Ryujinx/system")
fi

inhibit_cmd=()

if pgrep -x sway >/dev/null; then
    inhibit_cmd+=("systemd-inhibit")
    active_output="$(swaymsg -t get_outputs | jq ".[] | select(.focused == true) | .name")"
    original_scale="$(swaymsg -t get_outputs | jq ".[] | select(.focused == true) | .scale")"

    "$HOME"/.config/sway/scripts/goto-empty-workspace.py
    if [ "$original_scale" != "1" ]; then
        swaymsg output "$active_output" scale 1
        sleep 0.5
    fi

elif pgrep -x Hyprland >/dev/null; then
    inhibit_cmd+=("systemd-inhibit")
    hyprctl dispatch workspace empty
    echo ho

elif pgrep -x gnome-shell >/dev/null; then
    inhibit_cmd+=("gnome-session-inhibit")

fi

# Need to run with xwayland
## Inhibit is handled by the custom lock and suspend scripts for sway and hyprland.
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
    \
    --setenv DOTNET_EnableAlternateStackCheck 1 \
    \
    --dev /dev \
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
    --ro-bind-try "$XDG_RUNTIME_DIR/tray-proxy" "$dbus_address" \
    --perms 444 --file 0 /etc/machine-id 0< <(dbus-uuidgen) \
    "$HOME/misc/programs/ryujinx/Ryujinx"

