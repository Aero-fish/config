#!/bin/bash
set -e

if [ $# -eq 1 ]; then
    info="$(
        df -H |
            grep -E "^(/|Filesystem)" |
            grep -E -v "^/(home|run/media)/" |
            cut -d" " -f 2- |
            sed -E -e "s:^\s*::" -e "s:Mounted on:Path:" -e "s:\s+:\t:g" 
    )"

    # echo "$info"
    # echo "------"
    remain="$(echo "$info" | grep -E "\s$1$" | awk '{print $3}')"
    # echo "$remain"
    # echo "------"
    info="$(echo "$info" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
    printf '{"text":"%s", "tooltip": "%s"}' "$remain" "$info"

else
    exit 1
fi
