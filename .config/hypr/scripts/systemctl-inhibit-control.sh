#!/bin/bash
set -e
current_script_dir="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 0
    pwd -P
)"

inhibit_programs=(
    "^($HOME/misc/programs/115Browser/|)115Browser"
    "^($HOME/misc/programs/baidunetdisk/|)baidunetdisk"
    "^(/usr/bin/|/bin/|)(bash|sh) (/usr/local/share/|)wine-net .*115(chrome)?\\.exe"
    "^(/usr/bin/|/bin/|)(bash|sh) (/usr/local/share/|)wine-net .*PikPak\\.exe"
    "^(/usr/bin/|/bin/|)bash $HOME/.local/bin/cemu.sh"
    "^(/usr/bin/|/bin/|)bash $HOME/.local/bin/download-youtube-watchlist.sh"
    "^(/usr/bin/|/bin/|)bash $HOME/.local/bin/jdownloader.sh"
    "^(/usr/bin/|/bin/|)bash $HOME/.local/bin/yuzu.sh"
    "^(/usr/bin/|/bin/|)bash -c sleep infinity; echo no-suspension ended\$"
    "^(/usr/bin/|/bin/|)cp ?"
    "^(/usr/bin/|/bin/|)mv ?"
    "^(/usr/bin/|/bin/|)qbittorrent ?"
    "^(/usr/bin/|/bin/|)qemu-system-x86_64 ?"
    "^(/usr/bin/|/bin/|)rclone ?"
    "^(/usr/bin/|/bin/|)rm ?"
    "^(/usr/bin/|/bin/|)rsync ?"
    "yt-dlp ?"
)

for prog in "${inhibit_programs[@]}"; do
    if pgrep -u "$(id -n -u)" -f "$prog" >/dev/null; then
        hyprctl --quiet dispatch forceidle 0
        exit 0
    fi
done

if ! "$current_script_dir/lock.sh"; then
    exit 0
fi

if [ "$1" == "suspend-then-hibernate" ] && [ "$(tail -n +2 </proc/swaps)" == "" ]; then
    systemctl suspend || true

else
    systemctl "$1" || true

fi
