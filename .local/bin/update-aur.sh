#!/usr/bin/bash
set -e

## ----- Update aur based packages -----
repo_dir="$HOME/misc/repo"

pc_name="$(cat /proc/sys/kernel/hostname)"
main_pc="beast"
KEEP_BACKUPS=3

## Only update if it is the main PC. Other PC only check to installed newer package.
if [ "$pc_name" = "$main_pc" ]; then
    # Update from git repo
    for work_path in "$repo_dir"/*/; do
        [ ! -d "$work_path" ] && break # Break if no directories

        cd "$work_path"
        if [ -d ".git" ]; then
            git reset --hard >/dev/null
            git_pull_result=$(git pull) || continue
            pkg_name="$(basename -- "$work_path")"

            if [ "$git_pull_result" != "Already up to date." ]; then
                echo -ne "\e[31mPulled '$pkg_name' from repo\e[0m"
                if [ -f "PKGBUILD" ]; then
                    mkdir -p "$work_path/.backups"
                    pkgver="$(grep "pkgver=" PKGBUILD | sed -E 's:.*pkgver=([^ \t]*).*:\1:')"
                    pkgrel="$(grep "pkgrel=" PKGBUILD | sed -E 's:.*pkgrel=([^ \t]*).*:\1:')"
                    version="${pkgver}-${pkgrel}"
                    if [ ! -f "$work_path/.backups/${pkg_name}_${version}.tar.zst" ]; then
                        tar --anchored --exclude=".backups" --owner=0 --group=0 -C "$work_path" "-cpf" "-" -- * .* |
                            pv -s "$(du -cbs "$work_path" --exclude=.backups | tail -1 | awk '{print $1}')" |
                            zstdmt >"$work_path/.backups/${pkg_name}_${version}.tar.zst"
                    fi

                    all=("$work_path/.backups/${pkg_name}_"*.tar.zst) # names sort by date
                    if ((${#all[@]} > KEEP_BACKUPS)); then
                        rm -f -- "${all[@]:0:${#all[@]}-KEEP_BACKUPS}"
                    fi
                    git clean -f -d -e /.backups >/dev/null

                    echo -e "\e[31m, pending make.\e[0m"
                    echo "$pkg_name" >>"$repo_dir/pending_make.txt"
                else
                    echo -e "\e[31m.\e[0m"
                fi
            else
                echo "'$pkg_name' is already up to date."

            fi
        fi
    done

    ## Check icu update for libpdfium-nojs
    if ! grep --quiet "libpdfium-nojs" "$repo_dir/pending_make.txt" && [ -d "$work_path" ] && pacman -Q icu 1>/dev/null 2>&1; then
        work_path="$repo_dir/libpdfium-nojs"
        icu_installed_version="$(pacman -Q icu | cut -d" " -f2)"
        if [ ! -f "$repo_dir/libpdfium-nojs/icu_$icu_installed_version".txt ]; then
            echo -e "\e[31mRebuilding 'libpdfium-nojs' for new 'icu'\e[0m"

            ## Make backups
            mkdir -p "$work_path/.backups"
            pkgver="$(grep "pkgver=" PKGBUILD | sed -E 's:.*pkgver=([^ \t]*).*:\1:')"
            pkgrel="$(grep "pkgrel=" PKGBUILD | sed -E 's:.*pkgrel=([^ \t]*).*:\1:')"
            version="${pkgver}-${pkgrel}"

            if [ -f "$work_path/.backups/${pkg_name}_${version}.tar.zst" ]; then
                rm "$work_path/.backups/${pkg_name}_${version}.tar.zst"
            fi
            tar --anchored --exclude=".backups" --owner=0 --group=0 -C "$work_path" "-cpf" "-" -- * .* |
                pv -s "$(du -cbs "$work_path" --exclude=.backups | tail -1 | awk '{print $1}')" |
                zstdmt >"$work_path/.backups/${pkg_name}_${version}.tar.zst"

            all=("$work_path/.backups/${pkg_name}_"*.tar.zst) # names sort by date
            if ((${#all[@]} > KEEP_BACKUPS)); then
                rm -f -- "${all[@]:0:${#all[@]}-KEEP_BACKUPS}"
            fi
            git clean -f -d -e /.backups >/dev/null
            echo "libpdfium-nojs" >>"$repo_dir/pending_make.txt"
        fi
    fi

    ## Use container to build
    if [ -s "$repo_dir/pending_make.txt" ]; then
        #Create the image of the container if it does not exist.
        if ! podman image exists localhost/archlinux-aur-build; then
            "$HOME/.local/bin/rebuild_aur_container_images.sh"
        fi

        # Run the container
        podman run --rm -it --userns keep-id -u user \
            --name aur --label aur --network host \
            -v "$HOME/misc/repo":/home/user/aur \
            localhost/archlinux-aur-build \
            /home/user/aur/update-AUR-here.sh || echo "Container exit with $?"
    fi

    ## clean up packages
    clean_up_packages=(
        "steghide"
        "sworkstyle"
        "wdisplays"
        "yacreader"
    )
    for work_path in "${clean_up_packages[@]}"; do
        if [ -d "$repo_dir/$work_path/pkg" ]; then
            echo -e "\e[31mClean up $work_path.\e[0m"

            program_name="$work_path"
            if [[ "$work_path" == *-git ]]; then
                program_name="${work_path:0:-4}"
            fi

            if [[ "$work_path" == *-bin ]]; then
                program_name="${work_path:0:-4}"
            fi

            if [ -d "${repo_dir:?}/$work_path/$program_name" ]; then
                echo rm "${repo_dir:?}/$work_path/$program_name"
                rm -rf "${repo_dir:?}/$work_path/$program_name"
            fi

            rm -rf "${repo_dir:?}/$work_path/src"

            if [ -d "$repo_dir/$work_path/pkg/$work_path/opt/$program_name" ]; then
                app="$repo_dir/$work_path/pkg/$work_path/opt/$program_name"

            elif [ -d "$repo_dir/$work_path/pkg/$work_path/usr/bin" ]; then
                ## Sometime the program name has capital letter. E.g., YACReader
                app="$(find "$repo_dir/$work_path/pkg/$work_path/usr/bin/" -type f -iname "$program_name" | head -n1)"

            fi

            if [ -n "$app" ]; then
                chmod 700 "$app"
                mv "$app" "$repo_dir/$work_path/"
                rm -rf "$repo_dir/$work_path/pkg"
            fi

        fi
    done
fi

## ----- Update and install github based packages -----
_check_download_url() {
    if [ -z "$download_url" ]; then
        echo "Fail to fetch '$pkg_name' download link"
        exit 1
    fi
}

d7vk-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"d7vk-$version.zip\") | .browser_download_url"
    )"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.zip"
    unzip "$work_path/$version.zip" -d "$work_path"
    if [ -d "$work_path/d7vk-$version" ]; then
        mv "$work_path/d7vk-$version"/* "$work_path"
        rm -rf "$work_path/d7vk-$version"
    fi
    rm "$work_path/$version.zip"
    touch "$work_path/d7vk_$version.txt"
}

d7vk-update() {
    d7vk_version_file="$(find "$work_path" -type f -iname "d7vk_*.txt" | head -n1)"
    [ -z "$d7vk_version_file" ] && return
    d7vk_version_file="$(basename -- "$d7vk_version_file")"

    for work_path in "$HOME"/.wine/*/; do
        [ ! -d "$work_path" ] && break
        [ ! -d "$work_path/drive_c" ] && continue
        [ "$(basename -- "$work_path")" = "proton" ] && continue

        if [ ! -f "$work_path/$d7vk_version_file" ]; then
            echo -e "\e[31mUpdating wine prefix at '$work_path' for d7vk.\e[0m"
            rm -f "$work_path"/d7vk_*.txt
            touch "$work_path/$d7vk_version_file"

            cp "$work_path/x32"/*.dll "$work_path/drive_c/windows/syswow64"
        fi
    done

    # dll_path="$HOME/misc/repo/proton-ge/files/lib/wine/d7vk"
    # if [ -d "$dll_path" ] && [ ! -f "$dll_path/$d7vk_version_file" ]; then
    #     ## Default proton dll has permission 500, cp cannot override it.
    #     ## Need to remove it first.
    #     echo -e "\e[31mUpdating proton for d7vk.\e[0m"
    #     rm -f "$dll_path"/d7vk_*.txt
    #     for f in "$work_path/x32"/*.dll; do
    #         rm -f "$dll_path/i386-windows/$(basename -- "$f")"
    #         cp "$f" "$dll_path/i386-windows"
    #     done
    #     touch "$dll_path/$d7vk_version_file"
    # fi
}

dxvk-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"dxvk-${version#v}.tar.gz\") | .browser_download_url"
    )"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"
    touch "$work_path/dxvk_$version.txt"
}

dxvk-update() {
    dxvk_version_file="$(find "$work_path" -type f -iname "dxvk_*.txt" | head -n1)"
    [ -z "$dxvk_version_file" ] && return
    dxvk_version_file="$(basename -- "$dxvk_version_file")"

    for work_path in "$HOME"/.wine/*/; do
        [ ! -d "$work_path" ] && break
        [ ! -d "$work_path/drive_c" ] && continue
        [ "$(basename -- "$work_path")" = "proton" ] && continue

        if [ ! -f "$work_path/$dxvk_version_file" ]; then
            echo -e "\e[31mUpdating wine prefix at '$work_path' for dxvk.\e[0m"
            rm -f "$work_path"/dxvk_*.txt
            touch "$work_path/$dxvk_version_file"

            cp "$work_path/x64"/*.dll "$work_path/drive_c/windows/system32"
            cp "$work_path/x32"/*.dll "$work_path/drive_c/windows/syswow64"
        fi
    done

    # dll_path="$HOME/misc/repo/proton-ge/files/lib/wine/dxvk"
    # if [ -d "$dll_path" ] && [ ! -f "$dll_path/$dxvk_version_file" ]; then
    #     ## Default proton dll has permission 500, cp cannot override it.
    #     ## Need to remove it first.
    #     echo -e "\e[31mUpdating proton for dxvk.\e[0m"
    #     rm -f "$dll_path"/dxvk_*.txt
    #     for f in "$work_path/x64"/*.dll; do
    #         rm -f "$dll_path/x86_64-windows/$(basename -- "$f")"
    #         cp "$f" "$dll_path/x86_64-windows"
    #     done
    #     for f in "$work_path/x32"/*.dll; do
    #         rm -f "$dll_path/i386-windows/$(basename -- "$f")"
    #         cp "$f" "$dll_path/i386-windows"
    #     done
    #     touch "$dll_path/$dxvk_version_file"
    # fi
}

dxvk-nvapi-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"dxvk-nvapi-$version.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path"
    rm "$work_path/$version.tar.gz"
    touch "$work_path/dxvk_nvapi_$version.txt"
}

dxvk-nvapi-update() {
    dxvk_nvapi_version_file="$(find "$work_path" -type f -iname "dxvk_nvapi_*.txt" | head -n1)"
    [ -z "$dxvk_nvapi_version_file" ] && return
    dxvk_nvapi_version_file="$(basename -- "$dxvk_nvapi_version_file")"

    for work_path in "$HOME"/.wine/*/; do
        [ ! -d "$work_path" ] && break
        [ ! -d "$work_path/drive_c" ] && continue
        [ "$(basename -- "$work_path")" = "proton" ] && continue

        if [ ! -f "$work_path/$dxvk_nvapi_version_file" ]; then
            echo -e "\e[31mUpdating wine prefix at '$work_path' for nvapi.\e[0m"
            cp "$work_path/x32/nvapi.dll" "$work_path/drive_c/windows/syswow64"
            cp "$work_path/x64/nvapi64.dll" "$work_path/drive_c/windows/system32"
            cp "$work_path/x64/nvofapi64.dll" "$work_path/drive_c/windows/system32"

            rm -f "$work_path"/dxvk_nvapi_*.txt
            touch "$work_path/$dxvk_nvapi_version_file"
        fi
    done

    # dll_path="$HOME/misc/repo/proton-ge/files/lib/wine/nvapi"
    # if [ -d "$dll_path" ] && [ ! -f "$dll_path/$dxvk_version_file" ]; then
    #     ## Default proton dll has permission 500, cp cannot override it.
    #     ## Need to remove it first.
    #     echo -e "\e[31mUpdating proton for dxvk-nvapi.\e[0m"
    #     rm -f "$dll_path"/dxvk_nvapi_*.txt
    #     for f in "$work_path/x64"/*.dll; do
    #         rm -f "$dll_path/x86_64-windows/$(basename -- "$f")"
    #         cp "$f" "$dll_path/x86_64-windows"
    #     done
    #     for f in "$work_path/x32"/*.dll; do
    #         rm -f "$dll_path/i386-windows/$(basename -- "$f")"
    #         cp "$f" "$dll_path/i386-windows"
    #     done
    #     touch "$dll_path/$dxvk_version_file"
    # fi
}

vkd3d-proton-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"vkd3d-proton-${version#v}.tar.zst\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.zst"

    tar -xf "$work_path/$version.tar.zst" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.zst"
    touch "$work_path/vkd3d_proton_$version.txt"
}

vkd3d-proton-update() {
    vkd3d_proton_version_file="$(find "$work_path" -type f -iname 'vkd3d_proton_*.txt' | head -n1)"
    [ -z "$vkd3d_proton_version_file" ] && return
    vkd3d_proton_version_file="$(basename -- "$vkd3d_proton_version_file")"

    for work_path in "$HOME"/.wine/*/; do
        [ ! -d "$work_path" ] && break
        [ ! -d "$work_path/drive_c" ] && continue
        [ "$(basename -- "$work_path")" = "proton" ] && continue

        if [ ! -f "$work_path/$vkd3d_proton_version_file" ]; then
            echo -e "\e[31mUpdating wine prefix at '$work_path' for vkd3d-proton.\e[0m"
            cp "$work_path/x64"/*.dll "$work_path/drive_c/windows/system32"
            cp "$work_path/x86"/*.dll "$work_path/drive_c/windows/syswow64"

            rm -f "$work_path"/vkd3d_proton_*.txt
            touch "$work_path/$vkd3d_proton_version_file"
        fi
    done

    # dll_path="$HOME/misc/repo/proton-ge/files/lib/wine/vkd3d-proton"
    # if [ -d "$dll_path" ] && [ ! -f "$dll_path/$dxvk_version_file" ]; then
    #     ## Default proton dll has permission 500, cp cannot override it.
    #     ## Need to remove it first.
    #     echo -e "\e[31mUpdating proton for vkd3d-proton.\e[0m"
    #         rm -f "$dll_path"/vkd3d_proton_*.txt
    #     for f in "$work_path/x64"/*.dll; do
    #         rm -f "$dll_path/x86_64-windows/$(basename -- "$f")"
    #         cp "$f" "$dll_path/x86_64-windows"
    #     done
    #     for f in "$work_path/x86"/*.dll; do
    #         rm -f "$dll_path/i386-windows/$(basename -- "$f")"
    #         cp "$f" "$dll_path/i386-windows"
    #     done
    #     touch "$dll_path/$dxvk_version_file"
    # fi
}

proton-ge-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"$version-x86_64.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar --strip-components=1 -xf "$work_path/$version.tar.gz" -C "$work_path"
    rm "$work_path/$version.tar.gz"
}

ksmbd-tools-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"ksmbd-tools-${version#v}.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    mkdir -p "$work_path/src"
    curl -L "$download_url" --output "$work_path/src/$version.tar.gz"
    tar --strip-components=1 -xf "$work_path/src/$version.tar.gz" -C "$work_path"/src

    cd "$work_path/src"
    ./configure --prefix=/usr --sbindir=/usr/local/sbin --libexecdir=/usr/lib/ksmbd-tools --sysconfdir=/etc --with-rundir=/run
    make

    ## Keep only the binary
    if [ -f "$work_path/src/tools/ksmbd.tools" ]; then
        install -m 600 "$work_path/src/tools/ksmbd.tools" "$work_path"
        cd "$work_path"
        rm -rf "$work_path/src"
    fi
}

ksmbd-tools-update() {
    if [ -f /usr/local/sbin/ksmbd.tools ] && ! cmp --silent /usr/local/sbin/ksmbd.tools "$work_path"/ksmbd.tools; then
        echo -e "\e[31mUpdating /usr/local/sbin/ksmbd.tools\e[0m"
        sudo install --mode 755 "$work_path"/ksmbd.tools /usr/local/sbin
    fi
}

localsend-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r '.assets[] | select(.name | test(".*\\.AppImage$")) | .browser_download_url'
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.AppImage"

    chmod 700 "$work_path/$version.AppImage"
    echo "Extracting AppImage"
    bwrap \
        --unshare-user \
        --unshare-ipc \
        --unshare-pid \
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
        \
        --ro-bind-try "/usr" "/usr" \
        --symlink "/usr/bin" "/bin" \
        --symlink "/usr/bin" "/sbin" \
        --symlink "/usr/lib" "/lib" \
        --symlink "/usr/lib" "/lib64" \
        --bind-try "$work_path" "$work_path" \
        "$work_path/$version.AppImage" --appimage-extract \
        9</usr/local/share/seccomp-filter/default_seccomp_filter.bpf >/dev/null

    mv "$work_path/squashfs-root"/* "$work_path"
    rm -rf "$work_path/$version.AppImage" \
        "$work_path/squashfs-root" \
        "$work_path"/org.localsend.localsend_app.desktop

    find "$work_path" -type f -exec chmod 600 {} +
    find "$work_path" -mindepth 1 -type d -exec chmod 700 {} +
    chmod 700 "$work_path"/{AppRun,localsend_app}

}

pandoc-eisvogel-template-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"Eisvogel.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path"
    rm "$work_path/$version.tar.gz"
    find "$work_path" -type f -exec chmod 600 {} +
    find "$work_path" -mindepth 1 -type d -exec chmod 700 {} +
}

pandoc-eisvogel-template-update() {
    local template_path
    template_path="$(find "$HOME/misc/repo/pandoc-eisvogel-template" -maxdepth 2 -type f -iname 'eisvogel.latex')"
    if [ -z "$template_path" ]; then
        echo -e "\e[31mcannot find eisvogel template.\e[0m"
        return
    fi
    if [ -f "$HOME/.local/share/pandoc/templates/eisvogel.tex" ] &&
        ! cmp --silent "$HOME"/.local/share/pandoc/templates/eisvogel.tex "$template_path"; then
        echo -e "\e[31mupdating $HOME/.local/share/pandoc/templates/eisvogel.tex.\e[0m"
        cp "$template_path" "$HOME/.local/share/pandoc/templates/eisvogel.tex"
    fi
}

revealjs-download() {
    download_url="$(
        curl -s -l "$1" |
            jq -r ".tarball_url"
    )"
    _check_download_url

    curl -l "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -c "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"
    rm -r "$work_path/.github"
}

katex-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"katex.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"
}

ffmpeg-yt-dlp-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"ffmpeg-master-latest-linux64-gpl.tar.xz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.xz"
    tar -I pixz -xf "$work_path/$version.tar.xz" -C "$work_path"
    rm "$work_path/$version.tar.xz"
    chmod 700 "$work_path/ffmpeg-master-latest-linux64-gpl/bin/"*
    mv "$work_path/ffmpeg-master-latest-linux64-gpl/bin/"* "$work_path"
    rm -rf "$work_path/ffmpeg-master-latest-linux64-gpl"
}

ltex-ls-plus-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"ltex-ls-plus-$version-linux-x64.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path"
    rm "$work_path/$version.tar.gz"
    mv "$work_path"/*/* "$work_path"
    rmdir --ignore-fail-on-non-empty "$work_path"/*/
}

maple-mono-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"MapleMono-NF-CN-unhinted.zip\") | .browser_download_url"
    )"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.zip"
    unzip "$work_path/$version.zip" -d "$work_path"
    rm "$work_path/$version.zip"
}

maple-mono-update() {
    local dest_path="$HOME/.local/share/fonts/maple-mono"
    if [ -d "$dest_path" ]; then
        version_file="$(find "$work_path" -type f -iname 'v*.txt' | head -n1)"
        [ -z "$version_file" ] && return
        version_file="$(basename -- "$version_file")"
        if [ ! -f "$dest_path/$version_file" ]; then
            echo -e "\e[31mCopying maple mono to .local/share/fonts\e[0m"
            rm -rf "${dest_path:?}"/*
            cp "$work_path"/* "$dest_path"
        fi
    fi
}

yay-download() {
    download_url="$(curl -s -L "$1" | jq -r ".assets[] | select(.name==\"yay_${version#v}_x86_64.tar.gz\") | .browser_download_url")"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"
}

huggingface-hub-download() {
    python -m venv --prompt "huggingface-hub" "$work_path"
    source "$work_path/bin/activate"
    uv pip install "huggingface_hub"
    deactivate
}

web-ui-download() {
    if ! podman image exists "localhost/archlinux-ai-model-build"; then
        "$HOME/.local/bin/rebuild_ai_container_images.sh"
    fi

    podman_net_cmd="podman run --rm -it --userns keep-id -u user"
    podman_net_cmd+=" --network host"
    podman_net_cmd+=" -v '$work_path':/home/user/venv"
    podman_net_cmd+=" localhost/archlinux-ai-model-build"
    eval "$podman_net_cmd sh -c 'uv venv --prompt web-ui /home/user/venv; source /home/user/venv/bin/activate; uv pip install \"cptr[all]\"'"
}

sglang-download() {
    if ! podman image exists "localhost/archlinux-ai-model-build"; then
        "$HOME/.local/bin/rebuild_ai_container_images.sh"
    fi

    podman_net_cmd="podman run --rm -it --userns keep-id -u user"
    podman_net_cmd+=" --network host"
    podman_net_cmd+=" -v '$work_path':/home/user/venv"
    podman_net_cmd+=" localhost/archlinux-ai-model-build"
    eval "$podman_net_cmd sh -c 'uv venv --prompt sgland /home/user/venv; source /home/user/venv/bin/activate; uv pip install --prerelease=allow sglang'"
}

vllm-download() {
    if ! podman image exists "localhost/archlinux-ai-model-build"; then
        "$HOME/.local/bin/rebuild_ai_container_images.sh"
    fi

    podman_net_cmd="podman run --rm -it --userns keep-id -u user"
    podman_net_cmd+=" --network host"
    podman_net_cmd+=" -v '$work_path':/home/user/venv"
    podman_net_cmd+=" localhost/archlinux-ai-model-build"
    eval "$podman_net_cmd sh -c 'uv venv --prompt vllm /home/user/venv; source /home/user/venv/bin/activate; uv pip install vllm --torch-backend=auto'"
}

opencode-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"opencode-linux-x64.tar.gz\") | .browser_download_url"
    )"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path"
    rm "$work_path/$version.tar.gz"
    if [ -f "$work_path/opencode" ]; then
        chmod 700 "$work_path/opencode"
    fi
}

hermes-agent-download() {
    download_url="$(curl -s -L "$1" | jq -r ".tarball_url")"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"
}

comfy-ui-download() {
    download_url="$(curl -s -L "$1" | jq -r ".tarball_url")"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"
}

pi-agent-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"pi-linux-x64.tar.gz\") | .browser_download_url"
    )"
    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"
}

ingetrazo-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name | test(\"^IngeTrazo-.+-linux-x86_64.tar.gz$\")) | .browser_download_url"
    )"

    _check_download_url
    curl -L "$download_url" --output "$work_path/$version.tar.gz"
    tar -xf "$work_path/$version.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/$version.tar.gz"

    find "$work_path" -type f -exec chmod 600 {} +
    find "$work_path" -mindepth 1 -type d -exec chmod 700 {} +
    chmod 700 "$work_path"/{ingetrazo,ingetrazo-mcp}
}

declare -A non_aur_packages=(
    ## Update proton before dxvk etc, so its dxvk/dxvk-nvapi/vkd3d-proton dlls
    ## can be updated in subsequent dxvk/dxvk-nvapi/vkd3d-proton updates.
    ["proton-ge"]="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

    ["comfy-ui"]="https://api.github.com/repos/Comfy-Org/ComfyUI/releases/latest"
    ["d7vk"]="https://api.github.com/repos/WinterSnowfall/d7vk/releases/latest"
    ["dxvk"]="https://api.github.com/repos/doitsujin/dxvk/releases/latest"
    ["dxvk-nvapi"]="https://api.github.com/repos/jp7677/dxvk-nvapi/releases/latest"
    ["ffmpeg-yt-dlp"]="https://api.github.com/repos/yt-dlp/FFmpeg-Builds/releases/latest"
    ["hermes-agent"]="https://api.github.com/repos/NousResearch/hermes-agent/releases/latest"
    ["ingetrazo"]="https://api.github.com/repos/ingelibre/ingetrazo/releases/latest"
    ["katex"]="https://api.github.com/repos/KaTeX/KaTeX/releases/latest"
    ["ksmbd-tools"]="https://api.github.com/repos/cifsd-team/ksmbd-tools/releases/latest"
    ["localsend"]="https://api.github.com/repos/localsend/localsend/releases/latest"
    ["ltex-ls-plus"]="https://api.github.com/repos/ltex-plus/ltex-ls-plus/releases/latest"
    ["maple-mono"]="https://api.github.com/repos/subframe7536/maple-font/releases/latest"
    ["opencode"]="https://api.github.com/repos/anomalyco/opencode/releases/latest"
    ["pandoc-eisvogel-template"]="https://api.github.com/repos/Wandmalfarbe/pandoc-latex-template/releases/latest"
    ["pi-agent"]="https://api.github.com/repos/earendil-works/pi/releases/latest"
    ["revealjs"]="https://api.github.com/repos/hakimel/reveal.js/releases/latest"
    ["vkd3d-proton"]="https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest"
    ["yay"]="https://api.github.com/repos/Jguer/yay/releases/latest"

    ["huggingface-hub"]="pip index versions --json huggingface_hub"
    # ["sglang"]="pip index versions --json sglang"
    # ["vllm"]="pip index versions --json vllm"
    # ["web-ui"]="pip index versions --json cptr"
)

## Delete pip cache
rm -rf "$HOME/.cache/pip"

for pkg_name in "${!non_aur_packages[@]}"; do
    work_path="$repo_dir/$pkg_name"
    if [ -d "$work_path" ]; then
        cd "$work_path"
        if [ "$pc_name" = "$main_pc" ]; then
            url="${non_aur_packages["$pkg_name"]}"
            if [[ "$url" == "https://api.github.com/"* ]]; then
                version="$(curl -s -l "$url" | jq -r ".tag_name")"
                [ "$version" == "latest" ] && version="$(curl -s -l "$url" | jq -r ".name")"

            elif [[ "$url" == "pip "* ]]; then
                version="$(eval "$url" | jq -r -j '.latest')"

            else
                echo "Do not know how to get version from: $url"

            fi

            if [ -z "$version" ]; then
                unset version
                echo "fail to fetch '$pkg_name' version"
                continue
            elif [ "$version" = "null" ]; then
                echo -e "\e[31m$pkg_name: github rate limited.\e[0m"
                exit 1
            fi

            if [ ! -f "$work_path/$version.txt" ]; then
                echo -e "\e[31mUpdating '$pkg_name'.\e[0m"

                ## ----- Backup and clean the directory -----
                current_version=""
                for f in *.txt; do
                    if [ "$(head -n1 "$f")" = "$url" ]; then
                        current_version="$(basename -s .txt -- "$f")"
                        echo "$current_version"
                        break
                    fi
                done

                if [ -n "$current_version" ] && [ ! -f "$work_path/.backups/${pkg_name}_${current_version}.tar.zst" ]; then
                    mkdir -p "$work_path/.backups"
                    tar --anchored --exclude=".backups" --owner=0 --group=0 -C "$work_path" "-cpf" "-" -- * .* |
                        pv -s "$(du -cbs "$work_path" --exclude=.backups | tail -1 | awk '{print $1}')" |
                        zstdmt >"$work_path/.backups/${pkg_name}_${version}.tar.zst"
                fi

                all=("$work_path/.backups/${pkg_name}_"*.tar.zst) # names sort by date
                if ((${#all[@]} > KEEP_BACKUPS)); then
                    rm -f -- "${all[@]:0:${#all[@]}-KEEP_BACKUPS}"
                fi

                find "$work_path" -mindepth 1 -maxdepth 1 ! -name .backups -exec rm -rf -- {} +

                ## ----- Start downloading ----
                if declare -F "$pkg_name-download" >/dev/null; then
                    # Call custom function to download new version
                    set +e
                    "$pkg_name-download" "$url"
                    result="$?"
                    set -e

                    if [ "$result" -eq 0 ]; then
                        echo "$url" >"$work_path/$version.txt"
                    fi
                else

                    echo -e "\e[31mNo download function.\e[0m"
                fi
            else
                echo "'$pkg_name' is already up to date."
            fi
        fi

        ## ----- Call update function ----
        if declare -F "$pkg_name-update" >/dev/null; then
            # Call custom function to update the installation
            "$pkg_name-update"
        fi
    fi
done

## ----- Update installed packages -----
## General
update_package=(
    "cyrus-sasl-xoauth2-git"
)
for pkg_name in "${update_package[@]}"; do
    if [ ! -d "$repo_dir/$pkg_name" ] || ! pacman -Q "$pkg_name" 1>/dev/null 2>&1; then
        continue
    fi

    installed_version="$(pacman -Q "$pkg_name" | cut -d" " -f2)"
    repo_version="$(find "$repo_dir/$pkg_name" -maxdepth 1 -mindepth 1 -type f -name "$pkg_name-*.pkg.tar.zst" | head -n1 | sed -E "s:(.*/)?$pkg_name-(.*)-.*:\2:")"

    if [ "$installed_version" != "$repo_version" ]; then
        echo -e "\e[31mUpdating $pkg_name\e[0m"
        find "$repo_dir/$pkg_name" -maxdepth 1 -mindepth 1 -type f -name "$pkg_name-*.pkg.tar.zst" -exec sudo pacman -U --noconfirm {} \;
    fi

done

## easy-pandoc-templates
work_path="$repo_dir/easy-pandoc-templates"
if [ -d "$work_path/html" ]; then
    for file in "$work_path/html"/*.html; do
        [ ! -e "$file" ] && break
        file_basename="$(basename -- "$file")"
        if [ -f "$HOME/.local/share/pandoc/templates/$file_basename" ] &&
            ! cmp --silent "$HOME/.local/share/pandoc/templates/$file_basename" "$file"; then
            echo -e "\e[31mUpdating $HOME/.local/share/pandoc/templates/$file_basename.\e[0m"
            cp "$file" "$HOME/.local/share/pandoc/templates"
        fi
    done
fi

## libpdfium-nojs
if [ -d "$repo_dir/yacreader" ] && [ -d "$repo_dir/libpdfium-nojs" ]; then
    LIB_PATH="$repo_dir/yacreader/lib"
    mkdir -p "$LIB_PATH"

    libpdfium_repo="$(find "$repo_dir/libpdfium-nojs" -type f -iname "libpdfium-nojs-*.pkg.tar.zst" | head -n1 | sed -E 's:(.*/)?libpdfium-nojs-(.*)-x86_64.pkg.tar.zst:\2:')"

    libpdfium_icu="$(find "$repo_dir/libpdfium-nojs" -type f -iname "icu_*.txt" | head -n1 | sed -E 's:(.*/)?icu_(.*).txt:\2:')"

    if [ -n "$libpdfium_repo" ] && [ -n "$libpdfium_icu" ] &&
        {
            [ ! -f "$LIB_PATH/libpdfium-nojs_$libpdfium_repo.txt" ] ||
                [ ! -f "$LIB_PATH/icu_$libpdfium_icu.txt" ]
        }; then
        rm -rf "${LIB_PATH:?}"/*
        tar --zstd --directory "$LIB_PATH" -xpf "$repo_dir/libpdfium-nojs/libpdfium-nojs-$libpdfium_repo-x86_64.pkg.tar.zst" usr/lib
        find "$LIB_PATH/usr/lib" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) \
            ! -name '.*' \( -name '*.so' -o -name '*.so.*' \) \
            -exec mv -t "$LIB_PATH" -- {} +

        rm -rf "${LIB_PATH:?}/usr"
        touch "$LIB_PATH/libpdfium-nojs_$libpdfium_repo.txt" \
            "$LIB_PATH/icu_$libpdfium_icu.txt"
    fi
    unset LIB_PATH
fi
