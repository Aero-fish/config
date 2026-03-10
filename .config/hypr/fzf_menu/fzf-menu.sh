#!/usr/bin/sh
current_script_dir="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 0
    pwd -P
)"
SELECTED="$(
    fd -t f -I --exact-depth 1 . "$current_script_dir" -x basename -- {} |
        sort |
        grep '^_' |
        sed 's@\.@ @g' |
        column -s ',' -t |
        fzf -i --delimiter _ --with-nth='2..' --prompt="fzf-menu: " --info=default \
            --layout=reverse --tiebreak=index |
        cut -d ' ' -f1
)"
eval "TERMINAL_COMMAND=kitty ${current_script_dir}/${SELECTED},*"
