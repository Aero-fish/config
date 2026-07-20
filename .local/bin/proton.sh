#!/usr/bin/bash
set -e

[ "${UID}" -eq 0 ] && {
    echo "Do not run as root."
    exit 0
}

proton_path="$HOME/misc/repo/proton-ge"
proton_prefix="$HOME/.wine/proton"
document_path="$HOME/.wine/games_documents"
appdata_path="$HOME/.wine/games_appdata"
cache_pool="$HOME/.cache/proton-cache-pool"
umu_data_path="$HOME/.local/share/umu"

mkdir -p "$proton_prefix" "$document_path" "$cache_pool" "$umu_data_path"

source /usr/local/share/bwrap_share/strict_rules

tmpfs_path+=(
    "$HOME/.local/share/Steam"
    "$HOME/.config/protonfixes"
    "$proton_prefix/pfx/drive_c/users/steamuser/Temp"
    "$proton_prefix/pfx/drive_c/windows/temp"
)

ro_bind_path+=(
    "$HOME/.config/fontconfig"
    "$HOME/.local/share/fonts"
    "$HOME/misc/repo/dxvk-nvapi/layer"
    "$proton_path"
    "/etc/ld.so.cache"
)

bind_path=(
    "$HOME/Desktop"
    "$cache_pool"
    "$document_path"
    "$appdata_path"
    "$proton_prefix"
    "$umu_data_path"
)
source /usr/local/share/bwrap_share/generate_args

overlay=()

## 'workdir' needs to be on the same filesystem as the 'upperdir'
game_overlay_lower="$HOME/win_d/Games"
game_overlay_upper="$HOME/.wine/win_d_games_upper"
game_overlay_workdir="$HOME/.cache/win_d_games"

if [ -d "$game_overlay_lower" ]; then
    mkdir -p "$game_overlay_upper" "$game_overlay_workdir"
    overlay+=(
        "--overlay-src" "$game_overlay_lower"
        "--overlay" "$game_overlay_upper" "$game_overlay_workdir" "$game_overlay_lower"
    )
fi

if [ "$1" != "" ]; then
    if pgrep -x Hyprland >/dev/null; then
        hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })' >/dev/null
    fi
fi

## Set PROTON_DLSS_UPGRADE=1 to download the latest DLSS, need internet to run

bwrap \
    --unshare-user \
    --unshare-pid \
    --unshare-uts \
    --unshare-net \
    --unshare-cgroup \
    \
    --hostname my-pc \
    --proc /proc \
    --cap-drop ALL \
    --new-session \
    \
    --setenv DXVK_STATE_CACHE_PATH "$cache_pool" \
    --setenv VKD3D_SHADER_CACHE_PATH "$cache_pool" \
    --setenv WINEPREFIX "$proton_prefix" \
    --setenv PROTONPATH "$proton_path" \
    \
    --setenv DXVK_LOG_LEVEL "none" \
    --setenv PROTON_USE_D7VK 1 \
    --setenv PROTON_DLSS_UPGRADE 0 \
    --setenv PROTON_DLSS_INDICATOR 0 \
    --setenv WINEDEBUG "-all" \
    --setenv PROTON_USE_WAYLAND 1 \
    --setenv PROTON_ENABLE_HDR 1 \
    --setenv VK_ADD_IMPLICIT_LAYER_PATH "$HOME/misc/repo/dxvk-nvapi/layer" \
    \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${overlay[@]}" \
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    --ro-bind-try "$XDG_RUNTIME_DIR/tray-proxy" "$dbus_address" \
    --perms 444 --file 6 /etc/group \
    --perms 444 --file 7 /etc/passwd \
    --perms 444 --file 8 /etc/machine-id \
    umu-run "$@" \
    6< <(echo "hugh:x:1000:") \
    7< <(echo "hugh:x:1000:1000::/home:/usr/bin/nologin") \
    8< <(dbus-uuidgen)
