#!/usr/bin/bash
set -e

cache_dir="$HOME/.cache/lf_thumbnails"
json_db="$cache_dir/db.json"
cache_file_limit=300

[ -d "$cache_dir" ] && find "$cache_dir" -size 0 -delete
[ ! -f "$json_db" ] && exit 0

num_of_line="$(wc -l <"$json_db")"

if [ "$num_of_line" -gt "$cache_file_limit" ]; then
    lines_to_be_del="$((num_of_line - cache_file_limit))"
else
    exit 0
fi

# Get the names of the thumbnails, must get them before
# editing the json.
files_to_delete=()
readarray -t files_to_delete < <(
    sed -ne "2,$((lines_to_be_del + 1))s/[^:]*:\s*\"\([^\"]*\)\".*/\1/" \
        -e "2,$((lines_to_be_del + 1))p" \
        "$json_db"
)

# Remove the thumbnail links from the json
sed -i "2,$((lines_to_be_del + 1))d" \
    "$json_db"


# Remove the thumbnails
(cd "$cache_dir"; rm -rf "${files_to_delete[@]}")
