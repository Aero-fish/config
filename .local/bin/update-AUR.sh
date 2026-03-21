#!/bin/bash
set -e

## ----- Update aur based packages -----
repo_dir="$HOME/misc/repo"

pc_name="$(cat /proc/sys/kernel/hostname)"
main_pc="beast"

## Only update if it is the main PC. Other PC only check to installed newer package.
if [ "$pc_name" = "$main_pc" ]; then
    # Update from git repo
    for d in "${repo_dir}"/*/; do
        [ ! -d "$d" ] && break # Break if no directories

        cd "$d"
        if [ -d ".git" ]; then
            git reset --hard >/dev/null
            git_pull_result=$(git pull) || continue
            dir_name="$(echo "$d" | sed -E 's=.*/([^/]*)/=\1=')"

            if [ "$git_pull_result" != "Already up to date." ]; then
                echo -ne "\e[31mPulled '${dir_name}' from repo\e[0m"
                if [ -f "PKGBUILD" ]; then
                    echo -e "\e[31m, pending make.\e[0m"
                    echo "$dir_name" >>"$repo_dir/pending_make.txt"
                else
                    echo -e "\e[31m.\e[0m"
                fi
            else
                echo "'${dir_name}' is already up to date."

            fi
        fi
    done

    ## Check icu update for libpdfium-nojs
    if [ -d "$repo_dir"/libpdfium-nojs ] && pacman -Q icu 1>/dev/null 2>&1; then
        icu_installed_version="$(pacman -Q icu | cut -d" " -f2)"
        if [ ! -f "$repo_dir/libpdfium-nojs/icu_${icu_installed_version}".txt ]; then
            echo -e "\e[31mRebuilding 'libpdfium-nojs' for new 'icu'\e[0m"
            rm -f "$repo_dir"/libpdfium-nojs/icu_*.txt
            echo "libpdfium-nojs" >>"$repo_dir/pending_make.txt"
        fi
    fi

    ## Use container to build
    if [ -s "$repo_dir/pending_make.txt" ]; then
        #Create the image of the container if it does not exist.
        if ! podman images | rg -q -F "localhost/archlinux-aur-build"; then
            "$HOME"/misc/programs/containers/aur_build/create_image.sh
        fi

        # Run the container
        podman run -it --name aur --rm -v "$HOME"/misc/repo:/home/user/aur \
            --userns keep-id -u user localhost/archlinux-aur-build \
            /home/user/aur/update-AUR-here.sh || echo "Container exit with $?"
    fi

    ## clean up packages
    clean_up_packages=(
        "steghide"
        "sworkstyle"
        "wdisplays"
        "yacreader"
    )
    for d in "${clean_up_packages[@]}"; do
        if [ -d "$repo_dir/$d/pkg" ]; then
            echo -e "\e[31mClean up $d.\e[0m"

            program_name="$d"
            if [[ "$d" == *-git ]]; then
                program_name="${d:0:-4}"
            fi

            if [[ "$d" == *-bin ]]; then
                program_name="${d:0:-4}"
            fi

            if [ -d "${repo_dir:?}/$d/$program_name" ]; then
                echo rm "${repo_dir:?}/$d/$program_name"
                rm -rf "${repo_dir:?}/$d/$program_name"
            fi

            rm -rf "${repo_dir:?}/$d/src"

            if [ -d "$repo_dir/$d/pkg/$d/opt/$program_name" ]; then
                app="$repo_dir/$d/pkg/$d/opt/$program_name"

            elif [ -d "$repo_dir/$d/pkg/$d/usr/bin" ]; then
                ## Sometime the program name has capital letter. E.g., YACReader
                app="$(fd -tf --ignore-case --glob "$program_name" "$repo_dir/$d/pkg/$d/usr/bin/" | head -n1)"

            fi

            if [ -n "$app" ]; then
                chmod 700 "$app"
                mv "$app" "$repo_dir/$d/"
                rm -rf "$repo_dir/$d/pkg"
            fi

        fi
    done

    ## proton
    if [ -d "$repo_dir/proton-ge-custom-bin/pkg" ]; then
        echo -e "\e[31mClean up proton-ge-custom-bin.\e[0m"
        rm -rf "$repo_dir/proton-ge-custom-bin/usr"
        mv "$repo_dir/proton-ge-custom-bin/pkg/proton-ge-custom-bin/usr" "$repo_dir/proton-ge-custom-bin/usr"
        sed -i 's:^\s*_proton=.*:_proton="$HOME/misc/repo/proton-ge-custom-bin/usr/share/steam/compatibilitytools.d/proton-ge-custom/proton":' "$repo_dir/proton-ge-custom-bin/usr/bin/proton-ge"
        rm -rf "$repo_dir/proton-ge-custom-bin/pkg"
    fi
fi

## ----- Update and install github based packages -----
_check_download_url() {
    if [ -z "$download_url" ]; then
        echo "Fail to fetch '$p' download link"
        exit 1
    fi
}

dxvk-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"dxvk-${version#v}.tar.gz\") | .browser_download_url"
    )"
    _check_download_url
    curl -L "$download_url" --output "${work_path}/${version}.tar.gz"
    tar -xf "${work_path}/${version}.tar.gz" -C "$work_path" --strip-components=1
    rm "$work_path/${version}.tar.gz"
    touch "$work_path/dxvk_${version}.txt"
}

dxvk-update() {
    dxvk_version_file="$(fd -tf --glob "dxvk_*.txt" "$work_path" | head -n1)"
    [ -z "$dxvk_version_file" ] && return
    dxvk_version_file="$(basename -- "$dxvk_version_file")"

    for d in "$HOME"/.wine/*/; do
        [ ! -d "$d" ] && break
        [ ! -d "$d/drive_c" ] && continue

        if [ ! -f "$d/$dxvk_version_file" ]; then
            echo -e "\e[31mUpdating wine bottle at '$d'.\e[0m"
            rm -f "$d"/dxvk_*.txt
            touch "$d/$dxvk_version_file"

            cp "$work_path/x64"/*.dll "$d/drive_c/windows/system32"
            cp "$work_path/x32"/*.dll "$d/drive_c/windows/syswow64"
        fi
    done
}

dxvk-nvapi-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"dxvk-nvapi-${version}.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.tar.gz"
    tar -xf "${work_path}/${version}.tar.gz" -C "$work_path"
    rm "$work_path/${version}.tar.gz"
    touch "$work_path/dxvk_nvapi_${version}.txt"
}

dxvk-nvapi-update() {
    dxvk_nvapi_version_file="$(fd -tf --glob "dxvk_nvapi_*.txt" "$work_path" | head -n1)"
    [ -z "$dxvk_nvapi_version_file" ] && return
    dxvk_nvapi_version_file="$(basename -- "$dxvk_nvapi_version_file")"

    for d in "$HOME"/.wine/*/; do
        [ ! -d "$d" ] && break
        [ ! -d "$d/drive_c" ] && continue

        if [ ! -f "$d/$dxvk_nvapi_version_file" ]; then
            echo -e "\e[31mUpdating wine bottle at '$d'.\e[0m"
            rm -f "$d"/dxvk_nvapi_*.txt
            touch "$d/$dxvk_nvapi_version_file"

            cp "$work_path/x64/nvapi64.dll" "$d/drive_c/windows/system32"
            cp "$work_path/x32/nvapi.dll" "$d/drive_c/windows/syswow64"
        fi
    done

}

vkd3d-proton-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"vkd3d-proton-${version#v}.tar.zst\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.tar.zst"

    tar -xf "${work_path}/${version}.tar.zst" -C "$work_path" --strip-components=1
    rm "$work_path/${version}.tar.zst"
    touch "$work_path/vkd3d_proton_${version}.txt"
}

vkd3d-proton-update() {
    vkd3d_proton_version_file="$(fd -tf --glob "vkd3d_proton_*.txt" "$work_path" | head -n1)"
    [ -z "$vkd3d_proton_version_file" ] && return
    vkd3d_proton_version_file="$(basename -- "$vkd3d_proton_version_file")"

    for d in "$HOME"/.wine/*/; do
        [ ! -d "$d" ] && break
        [ ! -d "$d/drive_c" ] && continue

        if [ ! -f "$d/$vkd3d_proton_version_file" ]; then
            echo -e "\e[31mUpdating wine bottle at '$d'.\e[0m"
            rm -f "$d"/vkd3d_proton_*.txt
            touch "$d/$vkd3d_proton_version_file"

            cp "$work_path/x64"/*.dll "$d/drive_c/windows/system32"
            cp "$work_path/x86"/*.dll "$d/drive_c/windows/syswow64"
        fi
    done
}

sway-autotiling-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".tarball_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "$work_path/$version.tar.gz"

    tar -xf "$work_path/$version.tar.gz" -C "$work_path"
    fd -tf --glob "main.py" "$work_path" --exec mv {} "$work_path/autotiling.py"

    fd --exact-depth 1 --exclude "autotiling.py" "$work_path" --exec-batch rm -r {}

    sed -i '1 s:^.*$:#!/usr/bin/python3:' "$work_path"/autotiling.py
    chmod 700 "$work_path"/autotiling.py
}

ksmbd-tools-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"ksmbd-tools-${version#v}.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    mkdir -p "${work_path}/src"
    curl -L "$download_url" --output "${work_path}/src/${version}.tar.gz"
    tar --strip-components=1 -xf "${work_path}/src/${version}.tar.gz" -C "$work_path"/src

    cd "${work_path}/src"
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
    echo "$1"
    download_url="$(
        curl -s -L "$1" |
            jq -r '.assets[] | select(.name | test(".*\\.AppImage$")) | .browser_download_url'
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.AppImage"

    chmod 700 "${work_path}/${version}.AppImage"
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
        "$work_path/${version}.AppImage" --appimage-extract \
        9</usr/local/share/seccomp-filter/default_seccomp_filter.bpf >/dev/null

    mv "${work_path}/squashfs-root"/* "${work_path}"
    rm -rf "${work_path}/${version}.AppImage" \
        "${work_path}/squashfs-root" \
        "${work_path}"/org.localsend.localsend_app.desktop

    fd --unrestricted -tf . "${work_path}" --exec-batch chmod 600 {}
    fd --unrestricted -td . "${work_path}" --exec-batch chmod 700 {}
    chmod 700 "${work_path}"/{AppRun,localsend_app}

}

pandoc-eisvogel-template-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"Eisvogel.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.tar.gz"
    tar -xf "${work_path}/${version}.tar.gz" -C "$work_path"
    rm "${work_path}/${version}.tar.gz"
    fd --unrestricted -tf . "${work_path}" --exec-batch /usr/bin/chmod 600 {}
    fd --unrestricted -td . "${work_path}" --exec-batch /usr/bin/chmod 700 {}
}

pandoc-eisvogel-template-update() {
    local template_path
    template_path="$(fd -tf --ignore-case --max-depth 2 "eisvogel.latex" "$HOME/misc/repo/pandoc-eisvogel-template")"
    if [ -z "$template_path" ]; then
        echo -e "\e[31mCannot find eisvogel template.\e[0m"
        return
    fi
    if [ -f "$HOME/.local/share/pandoc/templates/eisvogel.tex" ] &&
        ! cmp --silent "$HOME"/.local/share/pandoc/templates/eisvogel.tex "$template_path"; then
        echo -e "\e[31mUpdating $HOME/.local/share/pandoc/templates/eisvogel.tex.\e[0m"
        cp "$template_path" "$HOME"/.local/share/pandoc/templates/eisvogel.tex
    fi
}

revealjs-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".tarball_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.tar.gz"
    tar -xf "${work_path}/${version}.tar.gz" -C "$work_path" --strip-components=1
    rm "${work_path}/${version}.tar.gz"
    rm -r "${work_path}/.github"
}

katex-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"katex.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.tar.gz"
    tar -xf "${work_path}/${version}.tar.gz" -C "$work_path" --strip-components=1
    rm "${work_path}/${version}.tar.gz"
}

ffmpeg-yt-dlp-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"ffmpeg-master-latest-linux64-gpl.tar.xz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.tar.xz"
    tar -I pixz -xf "${work_path}/${version}.tar.xz" -C "$work_path"
    rm "${work_path}/${version}.tar.xz"
    chmod 700 "${work_path}/ffmpeg-master-latest-linux64-gpl/bin/"*
    mv "${work_path}/ffmpeg-master-latest-linux64-gpl/bin/"* "${work_path}"
    rm -rf "${work_path}/ffmpeg-master-latest-linux64-gpl"
}

ltex-ls-plus-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"ltex-ls-plus-${version}-linux-x64.tar.gz\") | .browser_download_url"
    )"
    _check_download_url

    curl -L "$download_url" --output "${work_path}/${version}.tar.gz"
    tar -xf "${work_path}/${version}.tar.gz" -C "$work_path"
    rm "${work_path}/${version}.tar.gz"
    mv "${work_path}"/*/* "${work_path}"
    rmdir --ignore-fail-on-non-empty "${work_path}"/*/
}

maple-mono-download() {
    download_url="$(
        curl -s -L "$1" |
            jq -r ".assets[] | select(.name==\"MapleMono-NF-CN-unhinted.zip\") | .browser_download_url"
    )"
    _check_download_url
    curl -L "$download_url" --output "${work_path}/${version}.zip"
    unzip "${work_path}/${version}.zip" -d "${work_path}"
    rm "${work_path}/${version}.zip"
    touch "$work_path/${version}.txt"
}

maple-mono-update() {
    local dest_path="$HOME/.local/share/fonts/maple-mono"
    if [ -d "$dest_path" ]; then
        version_file="$(fd -tf --glob "v*.txt" "$work_path" | head -n1)"
        [ -z "$version_file" ] && return
        version_file="$(basename -- "$version_file")"
        if [ ! -f "$dest_path/$version_file" ]; then
            echo -e "\e[31mCopying maple mono to .local/share/fonts\e[0m"
            rm -rf "${dest_path:?}"/*
            cp "$work_path"/* "$dest_path"
        fi
    fi
}

yt-dlp-download() {
    # Compare the github and pip version. Stripping the leading 0.
    IFS='.' read -r year month day <<<"$version"
    year="$((10#$year))"
    month="$((10#$month))"
    day="$((10#$day))"
    version_trim="$year.$month.$day"

    pip_version="$(pip index versions --json yt-dlp | jq -r -j '.versions[0]')"
    IFS='.' read -r year month day <<<"$pip_version"
    year="$((10#$year))"
    month="$((10#$month))"
    day="$((10#$day))"
    pip_version_trim="$year.$month.$day"

    if [ "$version_trim" != "$pip_version_trim" ]; then
        echo -e "\e[31mCannot update yt-dlp\e[0m"
        echo -e "\e[31mGithub version: $version (trimed: $version_trim), pip version: $pip_version (trimed: $pip_version_trim)\e[0m"
        return 1
    fi
    python -m venv --clear "$work_path"
    (
        source "$work_path"/bin/activate
        pip install "yt-dlp[default,curl-cffi]"
    )
}

declare -A github_packages=(
    ["dxvk"]="https://api.github.com/repos/doitsujin/dxvk/releases/latest"
    ["dxvk-nvapi"]="https://api.github.com/repos/jp7677/dxvk-nvapi/releases/latest"
    ["ffmpeg-yt-dlp"]="https://api.github.com/repos/yt-dlp/FFmpeg-Builds/releases/latest"
    ["katex"]="https://api.github.com/repos/KaTeX/KaTeX/releases/latest"
    ["ksmbd-tools"]="https://api.github.com/repos/cifsd-team/ksmbd-tools/releases/latest"
    ["localsend"]="https://api.github.com/repos/localsend/localsend/releases/latest"
    ["ltex-ls-plus"]="https://api.github.com/repos/ltex-plus/ltex-ls-plus/releases/latest"
    ["maple-mono"]="https://api.github.com/repos/subframe7536/maple-font/releases/latest"
    ["pandoc-eisvogel-template"]="https://api.github.com/repos/Wandmalfarbe/pandoc-latex-template/releases/latest"
    ["revealjs"]="https://api.github.com/repos/hakimel/reveal.js/releases/latest"
    ["sway-autotiling"]="https://api.github.com/repos/nwg-piotr/autotiling/releases/latest"
    ["vkd3d-proton"]="https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest"
    ["yt-dlp"]="https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
)

for p in "${!github_packages[@]}"; do
    work_path="$repo_dir/$p"
    if [ -d "$work_path" ]; then
        cd "$work_path"
        if [ "$pc_name" = "$main_pc" ]; then
            url="${github_packages["$p"]}"

            version="$(curl -s -l "$url" | jq -r ".tag_name")"
            [ "$version" == "latest" ] && version="$(curl -s -l "$url" | jq -r ".name")"

            [ -z "$version" ] && {
                echo "fail to fetch '$p' version"
                exit 1
            }

            if [ ! -f "$work_path/$version.txt" ]; then
                echo -e "\e[31mUpdating '$p'.\e[0m"
                rm -rf "${work_path:?}"/*

                if declare -F "${p}-download" >/dev/null; then
                    # Call custom function to download new version
                    set +e
                    "${p}-download" "$url"
                    result="$?"
                    set -e

                    if [ "$result" -eq 0 ]; then
                        echo "$url" >"$work_path/${version}.txt"
                    fi
                else

                    echo -e "\e[31mNo download function.\e[0m"
                fi
            else
                echo "'$p' is already up to date."
            fi
        fi

        if declare -F "${p}-update" >/dev/null; then
            # Call custom function to update the installation
            "${p}-update"
        fi
    fi
done

## ----- Update installed packages -----
## General
update_package=(
    "cyrus-sasl-xoauth2-git"
    "librewolf-bin"
)
for p in "${update_package[@]}"; do
    if [ ! -d "$repo_dir/$p" ] || ! pacman -Q "$p" 1>/dev/null 2>&1; then
        continue
    fi

    installed_version="$(pacman -Q "$p" | cut -d" " -f2)"
    repo_version="$(fd -tf --glob "$p-*.pkg.tar.zst" "$repo_dir/$p" | head -n1 | sed -E "s:(.*/)?$p-(.*)-.*:\2:")"

    if [ "$installed_version" != "$repo_version" ]; then
        echo -e "\e[31mUpdating $p\e[0m"
        fd -tf --glob "$p-*.pkg.tar.zst" "$repo_dir/$p" --exec-batch sudo pacman -U --noconfirm {}
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

## libpdfium-nojs and libunarr
if [ -d "$repo_dir/yacreader" ] && [ -d "$repo_dir/libpdfium-nojs" ] && [ -d "$repo_dir/libunarr" ]; then
    LIB_PATH="$repo_dir/yacreader/lib"
    mkdir -p "$LIB_PATH"

    libpdfium_repo="$(fd -tf --glob "libpdfium-nojs-*.pkg.tar.zst" "$repo_dir/libpdfium-nojs" | head -n1 | sed -E 's:(.*/)?libpdfium-nojs-(.*)-x86_64.pkg.tar.zst:\2:')"

    libpdfium_icu="$(fd -tf --glob "icu_*.txt" "$repo_dir/libpdfium-nojs" | head -n1 | sed -E 's:(.*/)?icu_(.*).txt:\2:')"

    libunarr_repo="$(fd -tf --glob "libunarr-*.pkg.tar.zst" "$repo_dir/libunarr" | head -n1 | sed -E 's:(.*/)?libunarr-(.*)-x86_64.pkg.tar.zst:\2:')"

    if [ -n "$libpdfium_repo" ] && [ -n "$libpdfium_icu" ] && [ -n "$libunarr_repo" ] &&
        {
            [ ! -f "$LIB_PATH/libpdfium-nojs_${libpdfium_repo}.txt" ] ||
                [ ! -f "$LIB_PATH/icu_${libpdfium_icu}.txt" ] ||
                [ ! -f "$LIB_PATH/libunarr_${libunarr_repo}.txt" ]
        }; then
        rm -rf "${LIB_PATH:?}"/*
        tar --zstd --directory "$LIB_PATH" -xpf "$repo_dir/libpdfium-nojs/libpdfium-nojs-$libpdfium_repo-x86_64.pkg.tar.zst" usr/lib
        tar --zstd --directory "$LIB_PATH" -xpf "$repo_dir/libunarr/libunarr-$libunarr_repo-x86_64.pkg.tar.zst" usr/lib
        fd -tf -tl --exact-depth 1 ".*\.so(\..*)?" "$LIB_PATH/usr/lib" --exec-batch mv {} "$LIB_PATH"

        rm -rf "${LIB_PATH:?}/usr"
        touch "$LIB_PATH/libpdfium-nojs_${libpdfium_repo}.txt" \
            "$LIB_PATH/icu_${libpdfium_icu}.txt" \
            "$LIB_PATH/libunarr_${libunarr_repo}.txt"
    fi
    unset LIB_PATH
fi
