#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo -e "\e[31mRename photos and videos from iPhone by their time and date.\nUsage: rename-iphone-photos.sh {File|Directories}\e[0m"
    exit 0
fi

files=()
if [ -d "$1" ]; then
    files=()
    readarray -t files < <(
        fd -t f -iI --exact-depth 1 ".*\.(heic|jpg|png|webp|webm|mp4|mov|gif|arw)" "$1"
    )

elif [ -f "$1" ]; then
    files+=("$1")

else
    echo "No such file/directory: '$1'"
fi

# Get date and time from EXIF tags in the order of the array
tags=(
    "DateTimeOriginal"
    "CreationDate"
    "FileModifyDate"
)

rename_file() {
    for t in "${tags[@]}"; do
        datetime=$(exiftool -ee -"$t" -d "%Y-%m-%d %H.%M.%S" "$1" | head -n 1 | cut -d':' -f2 | sed -e 's/^[ \t]*//')
        [ -n "${datetime}" ] && [ "${datetime}" != "0000" ] && break
    done

    if [ -n "${datetime}" ]; then
        ext="${f##*.}"
        dir="${f%/*}"
        [ "$1" == "${dir}/${datetime}.${ext}" ] && return
        mv --backup=t "$1" "${dir}/${datetime}.${ext}"

    else
        echo "'$1 has no date and time."
    fi
}

rename_file_with_index() {
    dir="${1%/*}"
    fullname="${1##*/}"
    basename="${fullname%.*}" # Remove .~[digit]~ at the end
    ext="${basename##*.}"     # Get extension
    basename="${basename%.*}" # Remove extension
    index="$(sed -E 's:^[^0-9]*([0-9]+).*:\1:' <<<"${1##*.}")"

    if [ "$ext" = "" ]; then
        [ "$1" == "${dir}/${basename}_${index}" ] && return
        echo "$1 to ${dir}/${basename}_${index}"
        mv "$1" "${dir}/${basename}_${index}"

    else
        [ "$1" == "${dir}/${basename}_${index}.${ext}" ] && return
        echo "$1 to ${dir}/${basename}_${index}.${ext}"
        mv "$1" "${dir}/${basename}_${index}.${ext}"
    fi
}

N=8
for f in "${files[@]}"; do
    if [[ $(jobs -r -p | wc -l) -ge $N ]]; then wait -n; fi
    rename_file "$f" &
done

wait

if [ -d "$1" ]; then
    for f in "$1"/*.~*~; do
        [ ! -f "$f" ] && break
        if [[ $(jobs -r -p | wc -l) -ge $N ]]; then wait -n; fi
        rename_file_with_index "$f" &
    done
fi
