#!/bin/bash
set -e
[ "${UID}" -eq 0 ] || exec sudo "$0" "$@"

if [ -z "${SUDO_USER}" ]; then
    echo "Do not call as root"
    exit 1
else
    user_home=$(eval echo ~${SUDO_USER})
    user="${SUDO_USER}"
fi

win_c_mount_point="${user_home}/win_c"
win_c_device="/dev/$(lsblk -o 'NAME,FSTYPE,UUID' --json --noempty | jq -r '.blockdevices[] | select(.children and .children[].fstype==null) | .children[] | select( .fstype=="ntfs" and (.name | endswith("p4"))) | .name')"

if [ ! -b "$win_c_device" ]; then
    echo "Guess $win_c_device is the c drive, but it is not a block device"
    exit 1
fi

sudo -u ${user} mkdir -p "$win_c_mount_point"

if rg -q -F "$win_c_mount_point" /proc/mounts; then
    echo "'$win_c_mount_point' is already mounted."
elif rg -q -F "$win_c_device" /proc/mounts; then
    echo "'$win_c_device' is already mounted."
fi

mount -t ntfs3 -o uid="$(id -u ${user})",gid="$(id -g ${user})",umask=077,noatime,prealloc,noexec,nodev,nosuid,iocharset=utf8,discard,windows_names,nocase,nofail "$win_c_device" "$win_c_mount_point"
