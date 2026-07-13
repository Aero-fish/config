#!/bin/bash
set -e
[ "${UID}" -eq 0 ] && {
    echo "Do not run as root."
    exit 0
}

proton_path="$HOME/misc/repo/proton-ge-custom-bin"
proton_prefix="$HOME/.wine/proton"
document_path="$HOME/.wine/games_documents"
appdata_path="$HOME/.wine/games_appdata"
cache_pool="$HOME/.cache/proton-cache-pool"

mkdir -p "$proton_prefix" "$document_path" "$cache_pool"

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
)

bind_path=(
    "$HOME/Desktop"
    "$HOME/win_d/Games"
    "$cache_pool"
    "$document_path"
    "$appdata_path"
    "$proton_prefix"
)
source /usr/local/share/bwrap_share/generate_args

if ! [[ "$1" =~ wineboot(\.exe)? ]] && ! [[ "$1" =~ winecfg(\.exe)? ]] && ! [[ "$1" =~ regedit(\.exe)? ]]; then
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
    --disable-userns \
    --hostname my-pc \
    --proc /proc \
    --cap-drop ALL \
    --new-session \
    \
    --setenv DXVK_LOG_LEVEL "none" \
    --setenv DXVK_STATE_CACHE_PATH "$cache_pool" \
    --setenv SteamAppId 0 \
    --setenv STEAM_COMPAT_CLIENT_INSTALL_PATH "$HOME/.local/share/Steam" \
    --setenv STEAM_COMPAT_DATA_PATH "$proton_prefix" \
    --setenv VKD3D_SHADER_CACHE_PATH "$cache_pool" \
    --setenv PROTON_DLSS_UPGRADE 0 \
    --setenv PROTON_DLSS_INDICATOR 0 \
    --setenv WINEDEBUG "-all" \
    --setenv PROTON_USE_WAYLAND 1 \
    --setenv PROTON_ENABLE_HDR 1 \
    --setenv VK_ADD_IMPLICIT_LAYER_PATH "$HOME/misc/repo/dxvk-nvapi/layer" \
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
    --perms 444 --file 8 /etc/machine-id \
    "$proton_path"/usr/bin/proton-ge run "$@" 8< <(dbus-uuidgen)
