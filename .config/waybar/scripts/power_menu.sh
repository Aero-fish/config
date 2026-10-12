#!/usr/bin/bash
set -e

[ "$#" -ne 1 ] && exit 0

if [ "$1" != "lock" ]; then
    blocking_programs=(
        "^$HOME/misc/repo/huggingface-hub/bin/python3"
        "^$HOME/misc/repo/yt-dlp/bin/python3"
        "^(/usr/bin/|/bin/|)(7z|cp|ffmpeg|mv|qemu-system-x86_64|rclone|rm|rsync|tar|zip) ?"
        "^(/usr/bin/|/bin/|)bash .*/(download-hugging-face.sh|download-youtube-watchlist.sh)"
    )

    for prog in "${blocking_programs[@]}"; do
        if pgrep -u "$(id -n -u)" --quiet -f "$prog"; then
            notify-send "Cannot $1, blocking program is running."
            exit 1
        fi
    done
fi

case "$1" in

"lock")
    "$HOME/.config/hypr/scripts/lock.sh" force
    ;;

"logout")
    hyprshutdown --top-label "Logging out..."
    ;;

"suspend")
    "$HOME/.config/hypr/scripts/lock.sh" force
    if [ "$(cat /proc/swaps | tail -n +2)" = "" ]; then
        systemctl suspend
    else
        systemctl suspend-then-hibernate
    fi
    ;;

"hibernate")
    if [ "$(cat /proc/swaps | tail -n +2)" = "" ]; then
        notify-send "No swap space, cannot hibernate"
    else
        "$HOME/.config/hypr/scripts/lock.sh" force
        systemctl hibernate
    fi
    ;;

"soft-reboot")
    hyprshutdown --top-label 'Restarting...' --post-cmd 'systemctl soft-reboot'
    ;;

"reboot")
    hyprshutdown --top-label 'Restarting...' --post-cmd 'systemctl reboot'
    ;;

"shutdown" | "poweroff")
    hyprshutdown --top-label "Shutting down..." --post-cmd "systemctl -i poweroff"
    ;;

*)
    :
    ;;
esac
