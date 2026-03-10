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

elif pidof sway >/dev/null; then
    current_script_dir="$(
        cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 0
        pwd -P
    )"

    lock="$current_script_dir/lock.sh"
    systemctl="$current_script_dir/systemctl-inhibit-control.sh"

    if [ "$has_battery" = 1 ]; then
        screen_off_timer=300
        suspension_timer=600

    else
        screen_off_timer=600
        suspension_timer=900

    fi

    suspend_timeout=()
    if [ "$suspension_timer" -ne 0 ]; then
        suspend_timeout=("timeout" "$suspension_timer" "$systemctl suspend-then-hibernate" "resume" "$DPMS_ON")
    fi
    DPMS_ON="swaymsg 'output * power on'"
    DPMS_OFF="swaymsg 'output * power off'"

    exec swayidle -w \
        lock "$lock force" \
        before-sleep "$lock force" \
        after-resume "$DPMS_ON" \
        timeout 10 "if pidof swaylock >/dev/null 2>&1; then $DPMS_OFF || true; fi" \
        resume "$DPMS_ON" \
        timeout $screen_off_timer "$lock && $DPMS_OFF || true" \
        resume "$DPMS_ON" \
        "${suspend_timeout[@]}"
fi
