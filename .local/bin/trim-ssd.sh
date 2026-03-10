#!/bin/bash
set -e
[ "${UID}" -eq 0 ] || exec sudo "$0" "$@"

fstrim -av
