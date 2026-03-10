#!/usr/bin/bash
set -e
export LESSHISTFILE="/dev/null"

PROG=$( basename "$0" )

TMP="$(mktemp "$XDG_RUNTIME_DIR/prop-XXXXX")"

trap 'rm $TMP' EXIT

hyprctl activewindow > "$TMP"

class_name_opt=""
if [ "$1" = "foot" ]; then
    class_name_opt="--app-id"
else
    class_name_opt="--class"
fi

"$1" "$class_name_opt" prop -e -- bash -c "less -f $TMP"

