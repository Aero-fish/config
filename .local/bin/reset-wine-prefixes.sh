#!/bin/bash
set -e

prefix_names=("default" "games" "net" "proton")
if [ $# -eq 0 ]; then
    echo -e "\e[35mUsage: reset-prefixes <prefix_name>\e[0m"
    echo -e "\e[35mPrefix_name: (${prefix_names[*]} )\e[0m"
    echo -e "\e[35mUse 'ALL' for all prefixes, and 'all' for all except 'net'\e[0m"
    exit 0
fi

args=()
for input_name in "$@"; do
    if [ "$input_name" = "ALL" ]; then
        args=("${prefix_names[@]}")
        break
    elif [ "$input_name" = "all" ]; then
        for prefix_name in "${prefix_names[@]}"; do
            [ "$prefix_name" != "net" ] && args+=("$prefix_name")
        done
        break
    fi

    found_name=false
    for valid_name in "${prefix_names[@]}"; do
        if [ "$input_name" = "$valid_name" ]; then
            args+=("$input_name")
            found_name=true
            break
        fi
    done
    if ! "$found_name"; then
        echo -e "\e[35mUnknown prefix '$input_name'\e[0m"
        exit 1
    fi
done

# Create necessary folders and variables
wine_misc_folder="$HOME/misc/wine"
mkdir -p "$HOME/.wine"
mkdir -p "$HOME/win_d"
user_name="$(whoami)"
dxvk_version_file="$(
    fd --unrestricted -t f --exact-depth 1 --glob "dxvk_*.txt" "$HOME/misc/repo/dxvk" |
        sort |
        tail -n 1
)"

dxvk_nvapi_version_file="$(
    fd --unrestricted -t f --exact-depth 1 --glob "dxvk_nvapi_*.txt" \
        "$HOME/misc/repo/dxvk-nvapi" |
        sort |
        tail -n 1
)"

vkd3d_proton_version_file="$(
    fd --unrestricted -t f --exact-depth 1 --glob "vkd3d_proton_*.txt" \
        "$HOME/misc/repo/vkd3d-proton" |
        sort |
        tail -n 1
)"

# ========== Functions ==========
remake-symbolic_links() {
    [ -z "$WINEPREFIX" ] && echo -e "\e[31m'WINEPREFIX' is not set, cannot delete/create symbolic links\e[0m" && exit 1
    local user_dir="$WINEPREFIX/drive_c/users/$user_name"

    # Recreate all symbolic links into actual directories.
    for d in "$user_dir"/*/; do
        # Strip tailing /
        d="${d%/}"

        # Exist and it is a symbolic link
        if [ -L "$d" ]; then
            rm "$d"
            mkdir "$d"
        fi
    done

    # Create symbolic link for accessing files outside of the prefix
    rm -rf "$user_dir/Desktop"
    ln -s "../../../../../Desktop" "$user_dir/Desktop"

    if [ "$separated_document_folder" -eq 1 ]; then
        mkdir -p "$HOME/.wine/${prefix_name}_documents"
        rm -rf "$user_dir/Documents"
        ln -s "../../../../${prefix_name}_documents" "$user_dir/Documents"
    fi

    if [ "$separated_appdata_folder" -eq 1 ]; then
        mkdir -p "$HOME/.wine/${prefix_name}_appdata"
        rm -rf "$user_dir/AppData"
        ln -s "../../../../${prefix_name}_appdata" "$user_dir/AppData"
    fi

    rm "$WINEPREFIX/dosdevices"/*
    ln -s "../drive_c/" "$WINEPREFIX/dosdevices/c:"
    ln -s "/" "$WINEPREFIX/dosdevices/z:"
    if [ -d "$HOME/win_d" ]; then ln -s "../../../win_d" "$WINEPREFIX/dosdevices/d:"; fi
    if [ -d "$HOME/Downloads" ]; then ln -s "../../../Downloads" "$WINEPREFIX/dosdevices/e:"; fi
    if [ -d "$HOME/kingston" ]; then ln -s "../../../kingston" "$WINEPREFIX/dosdevices/f:"; fi
}

create-baseline() {
    [ -z "$WINEPREFIX" ] && echo -e "\e[31m'WINEPREFIX' is not set, cannot create baseline\e[0m" && exit 1

    rm -rf "$WINEPREFIX"
    override_dll=()

    wineboot -i
    # Wait 15 seconds for wine to finish Initialisation
    sleep 15

    cp "$wine_misc_folder/wine.reg" "$WINEPREFIX"
    wine regedit "$WINEPREFIX/wine.reg"

    # # Wait 15 seconds for wine to finish Initialisation
    sleep 15

    rm "$WINEPREFIX/wine.reg"

    ## ---------- Install DXVK ----------
    if [ -d "$HOME/misc/repo/dxvk/x32" ] && [ -d "$HOME/misc/repo/dxvk/x64" ]; then
        echo -e "\e[31mInstall DXVK.\e[0m"

        cp "$HOME/misc/repo/dxvk/x64"/*.dll "$WINEPREFIX/drive_c/windows/system32"
        cp "$HOME/misc/repo/dxvk/x32"/*.dll "$WINEPREFIX/drive_c/windows/syswow64"

        override_dll+=("d3d10core" "d3d11" "d3d8" "d3d9" "dxgi")

        if [ -f "$dxvk_version_file" ]; then
            cp "$dxvk_version_file" "$HOME/.wine/$prefix_name/"
        else
            echo "$dxvk_version_file"
            echo -e "\e[31mDXVK has no version.\e[0m"
        fi
    fi

    ## ---------- Install DXVK-nvapi ----------
    if (pacman -Q nvidia-open 1>/dev/null 2>&1 || pacman -Q nvidia 1>/dev/null 2>&1); then
        if [ -d /lib64/nvidia/wine ]; then
            echo -e "\e[31mInstall nvidia dll.\e[0m"
            for dll in /lib64/nvidia/wine/*.dll; do
                cp "$dll" "$WINEPREFIX/drive_c/windows/system32"
                override_dll+=("$(basename -- "$dll")")
            done
        fi

        ## This should mirror lib64, no need to reg again
        if [ -d /lib/nvidia/wine ]; then
            for dll in /lib64/nvidia/wine/*.dll; do
                cp "$dll" "$WINEPREFIX/drive_c/windows/syswow64"
            done
        fi

        if [ -d "$HOME"/misc/repo/dxvk-nvapi ]; then
            echo -e "\e[31mInstall DXVK-nvapi.\e[0m"

            cp "$HOME"/misc/repo/dxvk-nvapi/x32/nvapi.dll "$WINEPREFIX/drive_c/windows/syswow64"
            cp "$HOME"/misc/repo/dxvk-nvapi/x64/nvapi64.dll "$WINEPREFIX/drive_c/windows/system32"
            cp "$HOME"/misc/repo/dxvk-nvapi/x64/nvofapi64.dll "$WINEPREFIX/drive_c/windows/system32"

            override_dll+=("nvapi" "nvapi64" "nvofapi64")
        fi

        if [ -f "$dxvk_nvapi_version_file" ]; then
            cp "$dxvk_nvapi_version_file" "$HOME/.wine/$prefix_name/"
        else
            echo -e "\e[31mDXVK-nvapi has no version.\e[0m"
        fi
    fi

    ## ---------- Install vkd3d-proton ----------
    if [ -d "$HOME"/misc/repo/vkd3d-proton ]; then
        echo -e "\e[31mInstall vkd3d-proton.\e[0m"

        if [ -f "$vkd3d_proton_version_file" ]; then
            cp "$vkd3d_proton_version_file" "$HOME/.wine/$prefix_name/"
        else
            echo -e "\e[31mvkd3d-proton has no version.\e[0m"
        fi

        # (cd "$HOME"/misc/repo/vkd3d-proton && WINEPREFIX="$HOME/.wine/$prefix_name" ./setup_vkd3d_proton.sh install)

        cp "$HOME/misc/repo/vkd3d-proton/x64"/*.dll "$WINEPREFIX/drive_c/windows/system32"
        cp "$HOME/misc/repo/vkd3d-proton/x86"/*.dll "$WINEPREFIX/drive_c/windows/syswow64"

        override_dll+=("d3d12" "d3d12core")
    fi

    ## ---------- Install Visual C++ runtime ----------
    # echo -e "\e[31mInstall Visual C++ runtime.\e[0m"
    # if [ -d "$wine_misc_folder/VC DX" ]; then
    #     mkdir -p "$WINEPREFIX/drive_c/VC"
    #     for f in "$wine_misc_folder/VC DX/"*.{exe,msi}; do
    #         if [ -f "$f" ]; then
    #             cp "$f" "$WINEPREFIX/drive_c/VC"
    #             echo -e "\e[31mInstalling ${f##*/}\e[0m"
    #             vc_path="$WINEPREFIX/drive_c/VC/$(basename -- "$f")"
    #             sh -c "WINEPREFIX=${WINEPREFIX@Q} wine ${vc_path@Q} /q" || true
    #             sleep 5
    #         fi
    #     done
    #     rm -r "$WINEPREFIX/drive_c/VC"
    # fi

    if [ -f "$HOME/.local/share/fonts/MS/arial.ttf" ]; then
        install -m 600 "$HOME/.local/share/fonts/MS/arial.ttf" "$WINEPREFIX/drive_c/windows/Fonts/"
    fi

    ## ---------- Register dll to be native ----------
    for dll in "${override_dll[@]}"; do
        echo -e "\e[31mReg $dll\e[0m"
        /usr/bin/wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v \
            "$dll" /d native /f >/dev/null 2>&1
    done
    sleep 5
}

# ========== main ==========
# Create wine prefixes
for prefix_name in "${args[@]}"; do
    [ "$prefix_name" = "" ] && continue

    # Initialise variables
    WINEPREFIX="$HOME/.wine/$prefix_name"
    separated_document_folder=0
    separated_appdata_folder=0

    echo -e "\e[31mCreating prefix $WINEPREFIX\e[0m"

    case "$prefix_name" in
    games)
        separated_document_folder=1
        separated_appdata_folder=1
        create-baseline
        ;;
    proton)
        rm -rf "$WINEPREFIX"
        mkdir -p "$HOME/.wine/games_documents" "$HOME/.wine/games_appdata"
        "$HOME"/.local/bin/proton.sh wineboot.exe
        sleep 5
        rm -rf "$WINEPREFIX/pfx/drive_c/users/steamuser/"{Desktop,Documents,AppData}
        ln -s "$HOME/Desktop" "$WINEPREFIX/pfx/drive_c/users/steamuser/Desktop"
        ln -s "../../../../../games_documents" "$WINEPREFIX/pfx/drive_c/users/steamuser/Documents"
        ln -s "../../../../../games_appdata" "$WINEPREFIX/pfx/drive_c/users/steamuser/AppData"

        rm "$WINEPREFIX/pfx/dosdevices"/*
        ln -s "../drive_c/" "$WINEPREFIX/pfx/dosdevices/c:"
        [ -d "$HOME/win_d" ] && ln -s "$HOME/win_d" "$WINEPREFIX/pfx/dosdevices/d:"
        [ -d "$HOME/Downloads" ] && ln -s "$HOME/Downloads" "$WINEPREFIX/pfx/dosdevices/e:"
        [ -d "$HOME/kingston" ] && ln -s "$HOME/kingston" "$WINEPREFIX/pfx/dosdevices/f:"

        # No need to create symbolic link using generic function, already done. Also,
        # it causes error.
        continue
        ;;
    *)
        separated_document_folder=0
        separated_appdata_folder=0
        create-baseline
        ;;
    esac

    # Wait three seconds before creating next prefix
    sleep 3
    remake-symbolic_links
done
