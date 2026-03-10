#!/bin/bash
set -e

source /usr/local/share/bwrap_share/strict_rules

ro_bind_path+=(
    "$HOME/misc/repo/wdisplays"
    "$HOME/.config/fontconfig/fonts.conf"
    "$SWAYSOCK"
)

source /usr/local/share/bwrap_share/generate_args

bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-net \
    --unshare-uts \
    --unshare-cgroup \
    \
    --disable-userns \
    --hostname my-pc \
    --proc /proc \
    --cap-drop ALL \
    --new-session \
    --die-with-parent \
    --seccomp 1 \
    1< /usr/local/share/seccomp-filter/default_seccomp_filter.bpf \
    \
    --dev /dev \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    "$HOME"/misc/repo/wdisplays/wdisplays

