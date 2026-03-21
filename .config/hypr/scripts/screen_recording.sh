#!/bin/bash
set -e

## gpu-screen-recorder
[ $# != 1 ] && exit 0

## Arguments: toggle_replay, save_replay, screen, window, area, portal, save_and_stop, stop_all
## Use -w as the first arg for normal recording, and -r for replay to distinguish them.

mkdir -p "$HOME/Pictures/ScreenRecording"

mode="$1"
codec="av1_10bit"
extra_cmd=()

# Check whether monitor is in HDR mode
if [[ "$mode" =~ .*_hdr$ ]]; then
    mode="${mode:0:-4}"
    codec="av1_hdr"
fi

if [ "$mode" = "toggle_replay" ]; then
    if pgrep -f "^((/usr)?/bin)?gpu-screen-recorder -r" >/dev/null; then
        pkill -SIGINT -f "^((/usr)?/bin)?gpu-screen-recorder -r" >/dev/null
        pw-play "$HOME/.config/my-config/notification_tones/Recording_stop.wav"
        sleep 0.5
        pkill -SIGRTMIN+12 -u "$(id -n -u)" -x waybar
        exit 0
    else
        # 1200s=20min
        extra_cmd+=("-r" "1200" "-replay-storage" "ram" "-c" "mkv" "-restart-replay-on-save" "yes")
        extra_cmd+=("-w" "screen")
    fi

elif [ "$mode" = "save_replay" ]; then
    if pgrep -f "^((/usr)?/bin)?gpu-screen-recorder -r" >/dev/null; then
        pkill -SIGUSR1 -f "^((/usr)?/bin)?gpu-screen-recorder -r"
        pw-play "$HOME/.config/my-config/notification_tones/Save_replay.wav"
    fi
    exit 0

elif [ "$mode" = "save_and_stop" ]; then
    if pkill -SIGINT -f "^((/usr)?/bin)?gpu-screen-recorder -w" >/dev/null; then
        pw-play "$HOME/.config/my-config/notification_tones/Recording_stop.wav"
        sleep 0.5
        pkill -SIGRTMIN+12 -u "$(id -n -u)" -x waybar
    fi
    exit 0

elif [ "$mode" = "stop_all" ]; then
    if pkill -SIGINT -f "^((/usr)?/bin)?gpu-screen-recorder" >/dev/null; then
        pw-play "$HOME/.config/my-config/notification_tones/Recording_stop.wav"
        sleep 0.5
        pkill -SIGRTMIN+12 -u "$(id -n -u)" -x waybar
    fi
    exit 0

else
    ## Requested normal recording
    # Exit if already running
    if pgrep -f "^((/usr)?/bin)?gpu-screen-recorder -w" >/dev/null; then
        exit 0
    fi

    if [ "$mode" = "screen" ]; then
        extra_cmd+=("-w" "screen")

    elif [ "$mode" = "window" ]; then
        extra_cmd+=("-w" "region" "-region")
        extra_cmd+=("$(hyprctl -j activewindow | jq -r "\"\(.size[0])x\(.size[1])+\(.at[0])+\(.at[1]) \"")")

    elif [ "$mode" = "area" ]; then
        extra_cmd+=("-w" "region" "-region" "$(slurp -f "%wx%h+%x+%y")")

    elif [ "$mode" = "portal" ]; then
        extra_cmd+=("-w" "portal")

    else
        echo "Unknown argument."
        exit 1
    fi
fi

# ----- GPU specific settings -----
if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
    # Treat input as yuv444, default is yuv420
    extra_cmd+=("-ffmpeg-video-opts" "-rgb_mode=yuv444;-tune=uhq")
fi

# ----- Play start sound -----
if [[ "$codec" =~ .*_hdr ]]; then
    if [ "$mode" = "toggle_replay" ]; then
        pw-play "$HOME/.config/my-config/notification_tones/Replay_start_hdr.wav"
    else
        pw-play "$HOME/.config/my-config/notification_tones/Recording_start_hdr.wav"
    fi
else
    if [ "$mode" = "toggle_replay" ]; then
        pw-play "$HOME/.config/my-config/notification_tones/Replay_start.wav"
    else
        pw-play "$HOME/.config/my-config/notification_tones/Recording_start.wav"
    fi
fi

# ----- Start recording -----
# Replay save using end time, normal recording uses start time, therefore
# overlap if transition from replay to normal.
# Replay default has "Replay" prefix in the file name, and normal recording don't
if [ "$mode" = "toggle_replay" ]; then
    output="$HOME/Pictures/ScreenRecording"
else
    output="$HOME/Pictures/ScreenRecording/$(date "+%Y-%m-%d_%H-%M-%S.%2N").mkv"
fi

# setsid gpu-screen-recorder "${extra_cmd[@]}" -pixfmt yuv444 -f 60 \
#     -a default_output -ac opus -ab 256 -v no \
#     -k "$codec" -q very_high -bm qp -fm vfr -cr full -encoder gpu \
#     -o "$output" \
#     >/dev/null 2>&1 </dev/null &

gpu-screen-recorder "${extra_cmd[@]}" -pixfmt yuv444 -f 60 \
    -a default_output -ac opus -ab 256 -v no \
    -k "$codec" -q very_high -bm vbr -fm vfr -cr full -encoder gpu \
    -o "$output"

# sleep 0.5

# pkill -SIGRTMIN+12 -u "$(id -n -u)" -x waybar
