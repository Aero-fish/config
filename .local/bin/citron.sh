#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && {
    echo "Do not run as root."
    exit 0
}

mkdir -p "$HOME/Pictures/switch" "$HOME"/Games/switch/{config,local}/{citron,"citron team"} "$HOME"/Games/switch/{firmware,games}

source /usr/local/share/bwrap_share/strict_rules

ro_bind_path+=(
    "$HOME/.config/dconf"
    "$HOME/.local/share/fonts"
    "$HOME/misc/programs/citron"
    "$HOME/Games/switch/games"
)

source /usr/local/share/bwrap_share/generate_args

if pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null

fi

user_config=()
user_config+=("--bind-try" "$HOME/Games/switch/config/citron" "$HOME/.config/citron")
user_config+=("--bind-try" "$HOME/Games/switch/config/citron team" "$HOME/.config/citron team")
user_config+=("--bind-try" "$HOME/Games/switch/local/citron" "$HOME/.local/share/citron")
user_config+=("--bind-try" "$HOME/Games/switch/local/citron team" "$HOME/.local/share/citron team")
user_config+=("--bind-try" "$HOME/Pictures/switch" "$HOME/.local/share/citron/screenshots")
user_config+=("--bind-try" "$HOME/Games/switch/firmware" "$HOME/.local/share/citron/nand")
user_config+=("--bind-try" "$HOME/Games/switch/keys" "$HOME/.local/share/citron/keys")

## Inhibit is handled by the custom lock and suspend scripts for hyprland.
## So it will not lock when citron is in focus only.
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
    --setenv LD_LIBRARY_PATH "$HOME/misc/programs/citron/lib:$LD_LIBRARY_PATH" \
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
    "$HOME"/misc/programs/citron/citron "$@"
