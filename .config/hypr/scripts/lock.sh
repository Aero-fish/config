#!/bin/bash
set -e

if pidof hyprlock >/dev/null; then
    exit 0
fi

no_lock_if_running=(
    # "^(/usr/bin/|/bin/|)bash $HOME/.local/bin/yuzu.sh"
)

no_lock_if_focus=(
    "onion.torzu_emu.torzu"
)

if [ "$1" != "force" ]; then
    for prog in "${no_lock_if_running[@]}"; do
        if pgrep -u "$(id -n -u)" -f "$prog" >/dev/null; then
            hyprctl --quiet dispatch forceidle 0
            exit 1
        fi
    done

    if pidof Hyprland >/dev/null; then
        prog_in_focus="$(hyprctl activewindow -j | jq -r '.class')"

    elif pidof sway >/dev/null; then
        prog_in_focus="$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | .app_id')"
        if [ "$prog_in_focus" = "null" ]; then
            prog_in_focus="$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | .window_properties.class')"
        fi
    else
        notify-send "Unknown DE, cannot lock"
        exit 1
    fi

    # Do not lock if a steam game is in focus
    for prog in "${no_lock_if_focus[@]}"; do
        if [ "$prog_in_focus" == "$prog" ] || [[ "$prog_in_focus" == steam_app_* ]] || [[ "$prog_in_focus" == *.exe ]]; then
            hyprctl --quiet dispatch forceidle 0
            exit 1
        fi
    done
fi

# Lock all keepassxc database
if [ -x /usr/bin/qdbus ] &&
    /usr/bin/qdbus | grep -q org.keepassxc.KeePassXC.MainWindow; then

    qdbus org.keepassxc.KeePassXC.MainWindow /keepassxc \
        org.keepassxc.KeePassXC.MainWindow.lockAllDatabases

fi

if pidof Hyprland >/dev/null; then
    setsid hyprlock --quiet >/dev/null &

elif pidof sway >/dev/null; then
    swaylock --daemonize --ignore-empty-password \
        --indicator-caps-lock -c 000000 --scaling fit \
        --image "$(find "$HOME"/misc/BingWallpaper -maxdepth 1 -type f -name "*.jpg" | sort | tail -n 1)" || {
        notify-send "Lock fail"
        exit 1
    }
else
    notify-send "Lock fail"
    exit 1
fi
