#!/bin/bash
set -e
verify() {
    for f in "${@}"; do
        basename="${f%.*}"
        [ ! -f "${basename}" ] && {
            echo -e "\e[31m${basename}\e[0m does not exist"
            return
        }
        echo "---------- gpg check ----------"
        gpg --keyserver-options auto-key-retrieve --verify "$f"
        echo "---------- pacman check ----------"
        pacman-key -v "$f"
        echo -e "\e[31m========================================\e[0m"
    done
}
export -f verify
find . -type f -iname "*.sig" -exec bash -c 'verify "$@"' bash {} +
