#!/bin/bash
set -e

readarray -d '' batteries < <(
    find /sys/class/power_supply -mindepth 1 -maxdepth 1 -name "CMB*" -print0
)

has_battery=0
for d in "${batteries[@]}"; do
    if [ -f "$d/type" ] && [ "$(cat "$d/type")" == "Battery" ] &&
        [ -f "$d"/status ] && [ -f "$d"/capacity ]; then
        has_battery=1
        break
    fi
done

if pidof Hyprland >/dev/null; then
    if [ "$has_battery" = 1 ]; then
        exec /usr/bin/hypridle -q -c "$HOME/.config/hypr/hypridle-battery.conf"

    else
        exec /usr/bin/hypridle -q -c "$HOME/.config/hypr/hypridle-desktop.conf"

    fi
fi
