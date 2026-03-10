#!/bin/bash
set -e

## Prevent multiple instances
for pid in $(pgrep -f "bash $0"); do
    # echo "check PID $pid, my PID $$, PPID $PPID"
    if [ -n "$pid" ] && [ "$pid" -ne $$ ] && [ "$pid" -ne $PPID ]; then
        echo "download-youtube-watchlist is already running"
        exit 0
    fi
done

if pgrep -x sway >/dev/null 2>&1; then
    ## Do not use systemd-inhibit, which also stops monitor turning off
    ## Check by other means
    :
elif pgrep -x gnome-shell >/dev/null 2>&1; then
    if [ "$(cat /proc/$PPID/comm)" != "gnome-session-i" ]; then
        echo "'exec' with gnome-session-inhibit"
        exec gnome-session-inhibit --inhibit suspend bash "$0"
    fi
fi

trap 'rv=$?; [ ! -z $ytdl_pid ] && kill -INT $ytdl_pid; exit $rv' EXIT

TMP_DIR="$(mktemp -d "$XDG_RUNTIME_DIR/tmp.XXXXXXXXXX")"
DOWNLOAD_DIR="$HOME"/Downloads/youtube
LOG_DIR="$HOME"/Documents/youtube-log

OUTPUT_EXT="mp4"
WAIT_BETWEEN_DOWNLOADS_SEC=5

MEMBERS_ONLY_CONTENT_KEYWORDS=" members-only "
NOT_YET_PREMIERES_MESSAGE_REGEX=".* ?(premieres|will begin) ?.*"
MAX_DISK_USAGE=95
COOKIE_PATH="$(find "$HOME/Documents/youtube-log/mozilla-ytdl" -type d -regex '.*default-release' | head -n 1)"

check_disk_usage() {
    disk_usage="$(
        df -B GB "$DOWNLOAD_DIR" |
            sed -n 2p |
            sed -E 's:.*\s([0-9]+)%.*:\1:'
    )"

    if [ "$disk_usage" -gt "$MAX_DISK_USAGE" ]; then
        echo -e "\e[31mDisk usage over $MAX_DISK_USAGE%. Abort\e[0m"
        exit 1
    fi
}

ytdl() {
    /usr/local/bin/generic_bwrap \
        --bind-try "$COOKIE_PATH" "$HOME/.cache/yt" \
        --ro-bind "$HOME"/misc/repo/ffmpeg-yt-dlp "$HOME"/misc/repo/ffmpeg-yt-dlp \
        --ro-bind "$HOME"/misc/repo/yt-dlp "$HOME"/misc/repo/yt-dlp \
        "$HOME"/misc/repo/yt-dlp/bin/yt-dlp \
        --ffmpeg-location "$HOME"/misc/repo/ffmpeg-yt-dlp \
        --js-runtimes node \
        --cookies-from-browser firefox:"$HOME/.cache/yt" \
        "$@"
}

if [ ! -d "$LOG_DIR" ]; then
    echo "No youtube log."
    exit
elif [ ! -f "${LOG_DIR}/channel" ]; then
    echo "No channel specified."
    exit
fi

mkdir -p "$DOWNLOAD_DIR" "$LOG_DIR"/history "$LOG_DIR"/member_only

while read -r line; do
    channel_link=$(echo "$line" | cut -d',' -f1 | sed -e 's/^\s*//' | sed -e 's/\s*$//')
    channel_name=$(echo "$line" | cut -d',' -f2 | sed -e 's/^\s*//' | sed -e 's/\s*$//')
    video_downloaded="$LOG_DIR/history/$channel_name"
    video_no_access="$LOG_DIR/member_only/$channel_name"

    if [ ! -f "$video_downloaded" ]; then
        echo "History for $channel_name does not exist"
        touch "$video_downloaded"
    fi

    # col1=date, col2=video_id, col3=name. Strip leading and tailing spaces.
    cut -d',' -f2 "$video_downloaded" |
        sed -e 's/^\s*//' |
        sed -e 's/\s*$//' \
            >"$TMP_DIR"/videos_ids_to_skip

    if [ -f "$video_no_access" ]; then
        cut -d',' -f1 "$video_no_access" |
            sed -e 's/^\s*//' |
            sed -e 's/\s*$//' >>"$TMP_DIR"/videos_ids_to_skip
    fi

    sort -u -o "$TMP_DIR/videos_ids_to_skip"{,}

    echo "Fetching new videos from '$channel_name'"
    ytdl --print filename --output "%(id)s,%(title).40s" \
        --no-restrict-filenames --windows-filenames \
        --flat-playlist \
        "$channel_link" >"${TMP_DIR}"/all_video_ids_and_names

    cut -d',' -f1 "${TMP_DIR}"/all_video_ids_and_names |
        sed -e 's/^\s*//' |
        sed -e 's/\s*$//' |
        sort -u >"$TMP_DIR"/all_video_ids

    # Compare download videos and all the videos to find new uploads.
    comm -23 "$TMP_DIR"/all_video_ids "$TMP_DIR"/videos_ids_to_skip >"$TMP_DIR"/new_video_ids

    num_of_new_videos="$(wc -l <"$TMP_DIR"/new_video_ids)"
    echo "There are $num_of_new_videos new videos."

    if [ "$num_of_new_videos" -gt 0 ]; then
        mkdir -p "$DOWNLOAD_DIR/$channel_name"
    else
        continue
    fi

    counter=1
    success=0
    while read -r video_id; do
        if [ "$success" -eq 1 ]; then
            sleep "$WAIT_BETWEEN_DOWNLOADS_SEC"
        fi

        check_disk_usage

        # Get video information
        set +e
        info="$(
            ytdl --print filename -o "%(upload_date)s,%(id)s,%(title).40s" \
                --no-restrict-filenames --windows-filenames \
                "https://www.youtube.com/watch?v=$video_id" 2> >(tee /tmp/yt-dl_error >&2)
        )"
        error_code=$?
        set -e

        error_msg=""
        if [ -f /tmp/yt-dl_error ]; then
            echo "https://www.youtube.com/watch?v=$video_id" >>/tmp/yt-dl_error
            echo "----------" >>/tmp/yt-dl_error
            error_msg="$(cat "/tmp/yt-dl_error")"
            error_msg_lower="$(echo "$error_msg" | tr "[:upper:]" "[:lower:]")"
            rm /tmp/yt-dl_error
        fi

        if [ $error_code -ne 0 ]; then
            if [[ "$error_msg_lower" == *"$MEMBERS_ONLY_CONTENT_KEYWORDS"* ]]; then
                echo -e "\e[31mMember only content, skip.\e[0m"
                full_line="$(grep --max-count=1 --no-messages -- "$video_id" "$TMP_DIR/all_video_ids_and_names")"
                if [ -n "$full_line" ]; then
                    echo "$full_line"
                    echo "$full_line" >>"$LOG_DIR/member_only/$channel_name"
                else
                    echo "$video_id"
                    echo "$video_id" >>"$LOG_DIR/member_only/$channel_name"
                fi
            elif [[ "$error_msg_lower" =~ $NOT_YET_PREMIERES_MESSAGE_REGEX ]]; then
                echo -e "\e[31mNot yet premieres\e[0m"

            else
                echo -e "\e[31mFetch info error.\e[0m"
                echo "$error_msg" >>"${DOWNLOAD_DIR}/${channel_name}_fail"
            fi
            success=0
            counter=$((counter + 1))
            echo
            echo "--------------------------------------------------------"
            continue
        fi

        # Set file name and date
        date="$(echo "$info" | sed -E 's:^([^,]+),.*:\1:')"
        name="$(echo "$info" | sed -E 's:^[^,]+,[^,]+,(.*):\1:')"
        file_name="$date $name.$OUTPUT_EXT"
        echo -e "\e[31mDownloading '$date: $name' ($counter/$num_of_new_videos)\e[0m"

        retry_num=0
        while true; do
            if [ ! -f "$DOWNLOAD_DIR/$channel_name/$file_name" ]; then
                set +e
                ytdl --merge-output-format "$OUTPUT_EXT" \
                    --continue -N 3 \
                    --all-subs --embed-subs --add-metadata --embed-thumbnail \
                    --no-restrict-filenames --windows-filenames \
                    --output "$DOWNLOAD_DIR/$channel_name/$file_name" \
                    "https://www.youtube.com/watch?v=$video_id"
                set -e

            else
                # Duplicate name
                {
                    echo "$info"
                    echo "https://www.youtube.com/watch?v=${video_id} (Duplicate name)"
                    echo "----------"
                } >>"${DOWNLOAD_DIR}/${channel_name}_fail"
                echo -e "\e[31mDuplicate name.\e[0m"
                break
            fi

            if [ -f "$DOWNLOAD_DIR/$channel_name/$file_name" ]; then
                # Download successes
                rm -f "$DOWNLOAD_DIR/$channel_name/"*.live_chat.json
                echo "$info" >>"$video_downloaded"
                break

            else
                # Other error
                check_disk_usage
                echo -e "\e[31mOther error $error_code, retry $retry_num\e[0m"

                if [ $((retry_num++)) -gt 5 ]; then
                    echo "$info" >>"${DOWNLOAD_DIR}/${channel_name}_fail"
                    echo "https://www.youtube.com/watch?v=$video_id (Other error)" >>"${DOWNLOAD_DIR}/${channel_name}_fail"
                    rm -f "$DOWNLOAD_DIR/$channel_name/$file_name"*
                    break
                fi
                # Wait a bit before try again
                sleep 3
            fi
        done

        success=1
        counter=$((counter + 1))
        echo
        echo "--------------------------------------------------------"

    done <"${TMP_DIR}/new_video_ids"

    # Sort the download history
    [ -f "$video_downloaded" ] && sort -u -o "$video_downloaded"{,}
    [ -f "$video_no_access" ] && sort -u -o "$video_no_access"{,}
    [ -d "$DOWNLOAD_DIR/$channel_name" ] && rmdir --ignore-fail-on-non-empty "$DOWNLOAD_DIR/$channel_name"

done < <(grep -v -E '^\s*((#|;).*)?$' "$LOG_DIR"/channel)

rm -r "$TMP_DIR"

echo "Download finished."
