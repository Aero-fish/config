#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Take only one file, $# are given"
else
    read -r -p "Hash type: 1.md5 2.sha1 3.sha256 4.sha512: " hash_type
    case "${hash_type}" in

    1)
        hash_exe=md5sum
        hash_type=md5
        ;;

    2)
        hash_exe=sha1sum
        hash_type=sha1
        ;;

    3)
        hash_exe=sha256sum
        hash_type=sha256
        ;;

    4)
        hash_exe=sha512sum
        hash_type=sha512
        ;;
    *)
        echo "Hash type must be 1-4."
        exit
        ;;
    esac

    fileHash=$(${hash_exe} "$1"|cut -d" " -f1)
    echo "File ${hash_type}: ${fileHash}"
    read -r -p "Hash for comparison: " user_hash
    # Trim heading and tailing space, and convert all letters to lower case
    user_hash_trimed="$(echo -e "${user_hash}" | sed -e 's/^\s*//' -e 's/\s*$//' -e 's/\(.*\)/\L\1/')"
    if [ "${user_hash_trimed}" = "${fileHash}" ]; then
        echo -e "\e[31mHashes match.\e[0m"
    else
        echo -e "\e[31mHashes do not match.\e[0m"
    fi
fi
