#!/bin/bash
set -e

if [ ! -f "$HOME/.config/tz" ]; then
    echo '## Use tzselect to find the name of time zone' >"$HOME/.config/tz"
    echo 'export TZ="Pacific/Auckland"' >>"$HOME/.config/tz"
fi
source "$HOME/.config/tz"

# time="$(date '+%Z %a %b-%d %I:%M %p')"
# time="$(date '+%a %b-%d %I:%M %p')"
time="$(date '+%a %b-%d %H:%M')"

tooltip="$(cal -n 9 --span --monday --color=always | sed 's:.\[0m:</span>:' | sed "s:.\\[7m:<span weight='bold' foreground='#43dfb8'>:" | sed -z 's:\n:  \\n  :g')"

if [ -x /usr/bin/khal ]; then
    cal_content="$(khal --no-color list 2>/dev/null | sed '{:q;N;s/\n/\\n  /g;t q}')"
    if [ -n "$cal_content" ]; then
        tooltip="${tooltip}\\n  -------------------------\\n  $cal_content\\n"
    fi
fi

tooltip="${tooltip}\\n  -------------------------\\n<span weight='bold'>  HKG: $(TZ='Asia/Hong_Kong' date '+%a %b-%d %H:%M')</span>\\n"

#tooltip="$(printf "%s\nHKG %s\n" "$tooltip" "$(TZ='Asia/Hong_Kong' date '+%a %b-%d %I:%M %p')")"
# year="<span size='larger' weight='bold' >                         $(date +"%Y")</span>\n"
printf '{"text": "%s", "tooltip": "\\n%s"}' "$time" "$tooltip"
