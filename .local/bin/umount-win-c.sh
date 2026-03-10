#!/bin/bash
set -e
[ "${UID}" -eq 0 ] || exec sudo "$0" "$@"

if [ -z "${SUDO_USER}" ]; then
    user_home="${HOME}"
else
    user_home="$(eval echo ~${SUDO_USER})"
fi

if rg -q -F "${user_home}/win_c" /proc/mounts; then
    umount -R "${user_home}/win_c"
    rmdir "${user_home}/win_c"
fi
