if [ -z "$DISPLAY" ] && [[ "$XDG_VTNR" =~ "^1$" ]]; then
    sway_installed=0
    hyprland_installed=0
    [ -x /usr/bin/sway ] && sway_installed=1
    [ -x /usr/bin/Hyprland ] && hyprland_installed=1

    if uwsm check may-start; then
        if [ "$hyprland_installed" = 1 ] && [ "$sway_installed" = 1 ]; then
            uwsm select
            exec uwsm start default

        elif [ "$hyprland_installed" = 1 ]; then
            exec uwsm start -- hyprland.desktop

        elif [ "$sway_installed" = 1 ]; then
            sway_args=()
            if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -q NVIDIA; then
                sway_args+=("--unsupported-gpu")
            fi
            uwsm start -- sway.desktop "${sway_args[@]}"
        fi
    fi
fi
