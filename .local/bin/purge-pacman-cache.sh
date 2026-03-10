#!/bin/bash
set -e
[ "${UID}" -eq 0 ] || exec sudo "$0" "$@"

# Remove orphan packages
pacman -Qdt && pacman -Rns "$(pacman -Qtdq)"
# Keep only most recent two version
paccache -rk2
# Remove cache for all uninstalled packages
pacman -Sc
