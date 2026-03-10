#!/bin/bash
set -e

[ "$#" -ne 1 ] && exit 0
mkdir -p "$HOME/Pictures/Screenshots"
msg=""

if [ "$1" = "screen" ]; then
    msg="Screenshot active output"

elif [ "$1" = "window" ]; then
    msg="Screenshot active window"
    if pgrep -x "Hyprland" >/dev/null 2>&1; then
        extra_cmd=("-g" "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')")

    elif pgrep -x "sway" >/dev/null 2>&1; then
        IFS=, read -r x y w h b <<<"$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]) | select(.nodes[].focused == true) | .nodes[0] | "\(.rect.x),\(.rect.y),\(.rect.width),\(.rect.height),\(.current_border_width)"')"
        x="$(($x + $b))"
        y="$(($y + $b))"
        w="$(($w - $b - $b))"
        h="$(($h - $b - $b))"
        extra_cmd=("-g" "$x,$y ${w}x${h}")

    else
        notify-send --icon="$HOME/.local/share/icons/Screenshot.svg" -- "Screenshot active window is not supported for current DE"
        exit 0
    fi

elif [ "$1" = "area" ]; then
    msg="Screenshot area"
    extra_cmd=("-g" "$(slurp)")

elif [ "$1" = "swappy" ]; then
    msg="Screenshot area and swappy"

else
    exit 1

fi

if [ "$1" = "swappy" ]; then
    grim -g "$(slurp)" -t png - | swappy --file - --output-file "$HOME/Pictures/Screenshots/$(date "+%Y-%m-%d %H_%M_%S.%2N").png"
else
    grim -t png "${extra_cmd[@]}" "$HOME/Pictures/Screenshots/$(date "+%Y-%m-%d %H_%M_%S.%2N").png"
fi

if pidof wf-recorder >/dev/null || pidof gpu-screen-recorder >/dev/null; then
    exit 0
fi

if pgrep -x "Hyprland" >/dev/null 2>&1; then
    focus_prog_is_fullscreen="$(hyprctl activewindow -j | jq -r '.fullscreen')"

elif pgrep -x "sway" >/dev/null 2>&1; then
    focus_prog_is_fullscreen="$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | .fullscreen_mode')"
fi

if [ "$focus_prog_is_fullscreen" = "0" ]; then
    notify-send --icon="$HOME/.local/share/icons/Screenshot.svg" -- "$msg"
fi

pw-play "$HOME/.config/my-config/notification_tones/Screenshot.wav"
