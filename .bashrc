#
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Command prompt text
PS1='[\u@\h \W]\$ '

## ---------- Keybindings ----------
bind '"jk":vi-movement-mode'
bind '"kj":vi-movement-mode'

## ---------- History control ----------
#export HISTSIZE=1000
#export HISTCONTROL=ignorespace  # ignore commands with leading space
#export HISTCONTROL=ignoredups   # ignore consecutive repeated commands
#export HISTCONTROL=ignoreboth   # ignore the above two cases
#export HISTCONTROL=erasedups    # delete duplicate lines in the history
export HISTCONTROL=erasedups:ignorespace

# Append to the history instead of overwriting (good for multiple connections)
shopt -s histappend

export HISTIGNORE="?:??:...:....:.....:.*:[ \\t]*:cd *:cd..:dec2hex *:hex2dec *:ex *:bg *|fg *:ffmpeg-*:mkv-stream-extract *:history *:job *:mount *:permission-fix *:sha *:shasum *:archive-to-single-tar-zstd *:umount *:ytdl*:yt-info *:mirror *:ls-*:hf-download.sh *:sudo *:"

## ---------- Other settings ----------
# Go to path without cs
shopt -s autocd

# Extended glob (e.g., ^ and $)
shopt -s extglob

# Auto correct minor errors in `cd`
shopt -s cdspell

export HISTFILE=${HOME}/.cache/bash/bash_history

## ---------- Source aliases, functions and environment ----------
[ -f "$HOME/.shrc" ] && . "$HOME/.shrc"

# ---------- rclone ----------
# Needs '$rclone_args' and '$rclone_paths' from shrc, must be after sourcing it.
if [ -n "${rclone_args+x}" ] && [ -n "${rclone_paths+x}" ]; then
    for alias_name in "${!rclone_paths[@]}"; do
        local_path="${rclone_paths[$alias_name]}"
        remote_path="onedrive_encrypt:$(basename "$local_path")"
        local_path="$(readlink -f "$local_path")"

        # shellcheck disable=SC2139
        alias sync_"$alias_name"_to_onedrive="rclone sync $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$local_path' '$remote_path'"
        # shellcheck disable=SC2139
        alias sync_"$alias_name"_from_onedrive="rclone sync $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$remote_path' '$local_path'"

        # shellcheck disable=SC2139
        alias copy_"$alias_name"_to_onedrive="rclone copy $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$local_path' '$remote_path'"
        # shellcheck disable=SC2139
        alias copy_"$alias_name"_from_onedrive="rclone copy $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$remote_path' '$local_path'"

    done

    unset rclone_args rclone_paths alias_name local_path remote_path
fi
