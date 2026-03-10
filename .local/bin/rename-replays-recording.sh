#!/bin/bash
set -e

src_dir="$HOME/Pictures/ScreenRecording"

if [ ! -d "$src_dir" ]; then
    echo "'$src_dir' does not exist."
    exit 1
fi

for f in "$src_dir"/Replay_*.mkv; do
    [ ! -f "$f" ] && continue
    org_time="$(date --rfc-3339='ns' -r "$f")"
    video_length="$(ffprobe -i "$f" -show_entries format=duration -v quiet -of csv="p=0")"
    touch -d "$org_time - $video_length seconds" "$XDG_RUNTIME_DIR/shifted_time"

    shifted_time="$(date --rfc-3339='ns' -r "$XDG_RUNTIME_DIR/shifted_time")"
    new_file_name="$(date "+%Y-%m-%d_%H-%M-%S.%2N" -r "$XDG_RUNTIME_DIR/shifted_time")"

    if [ ! -e "$src_dir/$new_file_name.mkv" ]; then
        mv "$f" "$src_dir/$new_file_name.mkv"
        touch -d "$shifted_time" "$src_dir/$new_file_name.mkv"
    else
        echo "Cannot rename '$(basename -- "$f")' to '$new_file_name.mkv', file already exist"
    fi
done

rm -f "$XDG_RUNTIME_DIR/shifted_time"
