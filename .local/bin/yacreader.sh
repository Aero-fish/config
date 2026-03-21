#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && {
    echo "Do not run as root."
    exit 0
}

mkdir -p "$HOME"/.config/YACReader/YACReader
[ ! -f "$HOME"/.config/YACReader/YACReader/YACReader.ini ] && touch "$HOME"/.config/YACReader/YACReader/YACReader.ini
[ ! -f "$HOME"/.config/YACReader/YACReaderCommon.ini ] && touch "$HOME"/.config/YACReader/YACReaderCommon.ini

source /usr/local/share/bwrap_share/strict_rules

ro_bind_path+=(
    "$HOME/misc/repo/yacreader"
)

for f in "$@"; do last_arg="$f"; done
if [ -e "$last_arg" ]; then
    dir_path="$(
        cd "$(dirname -- "$f")"
        pwd
    )"
    ro_bind_path+=("$dir_path")
fi

generate_hide_default
generate_hide_rc
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
    --seccomp 9 \
    9</usr/local/share/seccomp-filter/seccomp_filter_allow_get_mempolicy.bpf \
    \
    --setenv LD_LIBRARY_PATH "$HOME/misc/repo/yacreader/lib" \
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
    --ro-bind-try "$XDG_RUNTIME_DIR/tray-proxy" "$dbus_address" \
    --perms 444 --ro-bind-data 8 /etc/machine-id 8< <(dbus-uuidgen) \
    --bind-try "$HOME"/.config/YACReader/YACReaderCommon.ini "$HOME"/.local/share/YACReader/YACReaderCommon.ini \
    --bind-try "$HOME"/.config/YACReader/YACReader/YACReader.ini "$HOME"/.local/share/YACReader/YACReader/YACReader.ini \
    "${remount_ro[@]}" \
    "$HOME/misc/repo/yacreader/YACReader" "$@"
