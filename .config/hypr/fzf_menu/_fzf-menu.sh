#!/usr/bin/sh
current_script_dir="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 0
    pwd -P
)"

current_script_name="$(basename -- "$0")"

SELECTED="$(
    fd -tf --exact-depth 1 --exclude "$current_script_name" . "$current_script_dir" --format "{/}" |
        sort |
        sed "s:,:,--:" |
        column -s "," -t |
        fzf --layout=reverse --prompt="fzf-menu: " --no-multi |
        sed "s:\s*--:,:"
)"

"$current_script_dir/$SELECTED"
