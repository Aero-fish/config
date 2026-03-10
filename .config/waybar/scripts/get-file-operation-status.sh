#!/bin/bash
set -e

arr=()
readarray -td '' arr < <(fd --print0 --exact-depth 1 --type executable --glob "*.sh" "$XDG_RUNTIME_DIR/lf_progress")

[ "${#arr[@]}" -eq 0 ] && exit 1

tooltip=""
for f in "${arr[@]}"; do
    filename="$(basename -- "$f")"
    action="${filename%%_*}"
    dest="$(head -n 1 "$f" | sed -E "s:^#::")"
    [ -z "$dest" ] && dest="Unknown"

    if [ -z "$tooltip" ]; then
        tooltip="$filename:  $dest"
    else
        tooltip="$tooltip\n\n$filename: $dest"
    fi

    filename="${filename//./_}"
    if tmux list-sessions 2>/dev/null | rg -q -F "$filename"; then
        if [ "$action" = "rm" ]; then
            tooltip="$tooltip\n$(tmux capture-pane -peC -t "$filename":0 | grep -v -e '^$' | tail -n1)"

        else
            tooltip="$tooltip\n$(tmux capture-pane -peC -t "$filename":0 | grep -v -e '^$' | tail -n1 | awk '{print $1, $2, $3, $4}')"

        fi
    fi

done

printf '{"text":"%s", "tooltip": "%s"}' "${#arr[@]}" "$tooltip"
