#!/bin/bash
set -e

backup_path="$HOME/.backup"
dconf dump / >"$XDG_RUNTIME_DIR/dconf_dump"
nvim -d "${backup_path}/install_scripts/post_install/dconf_settings.txt" \
    "$XDG_RUNTIME_DIR/dconf_dump"
