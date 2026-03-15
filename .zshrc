#
# ${HOME}/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Prompt debugging
# PS1='%~ '
# RPS1='%n@%m'
# return

# ---------- Autocomplete ----------
zstyle ':completion:*' completer _complete _ignored _correct _approximate    # Enabled completers
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'    # Case insensitive
zstyle ':completion:*:correct:*' max-errors 2 not-numeric    # Allow 2 errors in correct completer
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) numeric )'    # Allow one error for every three characters typed in approximate completer
zstyle ':completion:*' menu select # Navigate candidates using highlighter
zstyle ':completion:*' original true    # Add original entered text as candidate
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s    # Progress bar at the bottom when the completion list does not fit on the screen
zstyle ':completion:*' accept-exact false    # Given `file1` `file`, autocomplete `file` to `file1` when tab instead of insert space

## Trim down candidate list
zstyle ':completion:*:(cd|mv|cp):*' ignore-parents parent pwd    # Ignore current dir when using `../` (e.g.: at a/b/c/, cd ../<TAB>, `c` will not be in the cadicate list)
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes   # Ignores filenames already in the line (e.g., cp a b <tab>, ignore file `a` and `b`)
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'    # Don't complete backup files (ending with ~) as executables

## Autocomplete for man pages
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

## Some functions, like _apt and _dpkg, are very slow. Use a cache in order to proxy the list of results
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ${HOME}/.cache/zsh/

## Messages/warnings format
zstyle ':completion:*' verbose yes    # Display verbose message if both short and verbose are available
zstyle ':completion:*' group-name ''    # Group candidates by their type
zstyle ':completion:*:descriptions' format $'%{\e[01;31m%}--- %d% ---%{\e[m%}'    # Heading of each group of candidates
zstyle ':completion:*:messages' format $'%{\e[01;04;31m%}--- %d ---%{\e[m%}'    # Shell messages. E.g., "Not a git repo"

autoload -Uz compinit && compinit -d ${HOME}/.cache/zsh/zcompdump-$ZSH_VERSION    # Load the autocomplete plugin

# ---------- Auto rehash new binaries in /bin/ ----------
## Relay on a packman hook to refresh the modified date of `/var/cache/zsh/pacman`
zshcache_time="$(date +%s%N)"
autoload -Uz add-zsh-hook
rehash_precmd() {
    if [[ -a /var/cache/zsh/pacman ]]; then
        local paccache_time="$(date -r /var/cache/zsh/pacman +%s%N)"
        if (( zshcache_time < paccache_time )); then
            rehash
            zshcache_time="$paccache_time"
        fi
    fi
}
add-zsh-hook -Uz precmd rehash_precmd

## Rehash on tab, has performance cost if part of $PATH is over the network
#zstyle ':completion:*' rehash true

# ---------- Other options ----------
# setopt GLOB_DOTS    # Always include hidden file
# setopt MENU_COMPLETE    # Insert the first match upon ambiguous completion
# stty erase "^?"    # ctrl-s no longer freeze the terminal. Usuful to stop print while keep the program running
setopt sh_word_split    # Split words by IFS like other shell
mkdir -p "${XDG_RUNTIME_DIR:-/run/user/root}/zsh"
TMPPREFIX="${XDG_RUNTIME_DIR:-/run/user/root}/zsh/zsh"    # Prefix for temp files $XDG_RUNTIME_DIR/zsh/zshxxxxx.zsh
setopt rmstarsilent # Do not query the user before executing rm /xx/*

# ---------- Universal help function ----------
## E.g., help INTERNAL_CMD, help EXTERNAL_CMD, help git GIT_CMD ...
if alias run-help >/dev/null 2>&1; then
    unalias run-help
fi

autoload -Uz run-help run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn
help() {
    case $1 in
        git)
            run-help-git "${@:2}"
            ;;
        ip)
            run-help-ip "${@:2}"
            ;;
        openssl)
            run-help-openssl "${@:2}"
            ;;
        p4)
            run-help-p4 "${@:2}"
            ;;
        sudo)
            run-help-sudo "${@:2}"
            ;;
        svk)
            run-help-svk "${@:2}"
            ;;
        svn)
            run-help-svn "${@:2}"
            ;;
        *)
            run-help "$@"
            ;;
    esac
}

#---------- History ----------
HISTFILE=${HOME}/.cache/zsh/zshhistory
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_ALL_DUPS    # Remove existing duplicate and append to the end
setopt HIST_IGNORE_SPACE    # Do not add commands that start with a space
setopt HIST_NO_FUNCTIONS    # Do not store functions
setopt INC_APPEND_HISTORY    # Immediate append command to histoy

export HISTORY_IGNORE='(?|??|...|....|.....|.*|cd#( *)#|dec2hex *|hex2dec *|ex *|bg *|fg *|ffmpeg-*|mkv-stream-extract *|history *|jobs *|mount *|permission-fix *|sha *|shasum *|archive-to-single-tar-zstd *|umount *|ytdl*|yt-info *|mirror *|ls-*|hf-download.sh *|sudo *)'

# Do not store failed commands
 zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# zsh-syntax-highlighting, source before keybindings to prevent an error
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# ---------- Keybindings ----------
bindkey -v    # VIM mode. Use `-e` for Emacs mode
export KEYTIMEOUT=20    # Time out 20ms for the jk shortcut
bindkey -M viins 'jk' vi-cmd-mode    # Use jk to enter command mode

# Set cursor to block/beam depending on vim mode for foot terminal emulator
# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"

    ## Add transient prompt to Starship
    # emulate -L zsh

    # [[ $CONTEXT == start ]] || return 0

    # while true; do
    # zle .recursive-edit
    # local -i ret=$?
    # [[ $ret == 0 && $KEYS == $'\4' ]] || break
    # [[ -o ignore_eof ]] || exit 0
    # done

    # local saved_prompt=$PROMPT
    # local saved_rprompt=$RPROMPT
    # PROMPT='%# '
    # RPROMPT=''
    # zle .reset-prompt
    # PROMPT=$saved_prompt
    # RPROMPT=$saved_rprompt

    # if (( ret )); then
    # zle .send-break
    # else
    # zle .accept-line
    # fi
    # return ret
}

zle -N zle-line-init
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.


## Use the vi navigation keys in menu completion
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

## [ Ctrl j/k ]  to search history with entered text, and put the cursor at the end
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^k" history-beginning-search-backward-end
bindkey "^j" history-beginning-search-forward-end

## [ Ctrl <Space> ] for accepting autocomplete
zle -N autosuggest-accept
bindkey '^ ' autosuggest-accept

# Keypad
# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[Ol" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + -  * /
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

# Delete key in command mode
bindkey -a '^[[3~' delete-char

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Shift, Alt, Ctrl and Meta modifiers
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

# Ctrl + Left, Ctrl + Right to move by word
[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

## VIM surround plugin, allow change surround
# add surround not work
autoload -Uz surround
zle -N delete-surround surround
# zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
# bindkey -a ys add-surround
# bindkey -M visual S add-surround

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
zle -N edit-command-line
# Emacs style, Ctl+x e, or Ctl+x Ctl+e
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line
# Vi style, Esc v, essetially visual mode
bindkey -M vicmd v edit-command-line

# Reuse some Emac keybinding
bindkey "^a"   beginning-of-line
bindkey "^b"   backward-char
bindkey "^e"   end-of-line
bindkey "^f"   forward-char
bindkey "^d"   delete-char
#bindkey "^k"   kill-whole-line    # Conflict with history search
bindkey "^p"   up-history
bindkey "^n"   down-history

# Clear screen and scroll back buffer
function clear-scrollback-buffer {
  # Behavior of clear:
  # 1. clear scrollback if E3 cap is supported (terminal, platform specific)
  # 2. then clear visible screen
  # For some terminal 'e[3J' need to be sent explicitly to clear scrollback
  clear && printf '\e[3J'
  # .reset-prompt: bypass the zsh-syntax-highlighting wrapper
  # https://github.com/sorin-ionescu/prezto/issues/1026
  # https://github.com/zsh-users/zsh-autosuggestions/issues/107#issuecomment-183824034
  # -R: redisplay the prompt to avoid old prompts being eaten up
  # https://github.com/Powerlevel9k/powerlevel9k/pull/1176#discussion_r299303453
  zle && zle .reset-prompt && zle -R
}

zle -N clear-scrollback-buffer
bindkey '^l' clear-scrollback-buffer

# ---------- Other settings ----------
setopt autocd    # omit the need of `cd`
unsetopt beep nomatch    # Do not beep if auto-complete has no match
setopt extendedglob    # Extended glob (e.g., ^ and $)

## Add colors in completions
autoload -Uz colors && colors
eval $(dircolors)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ---------- Source aliases, functions and environment ----------
[ -f ${HOME}/.shrc ] && source ${HOME}/.shrc

## Alias for piping. Only zsh has -g option.
if [ -f /usr/bin/bat ]; then
    pager="bat"
else
    pager="less"
fi

alias -g CA="2>&1 | cat -A"
alias -g G='| grep -i'
alias -g GC='| grep --color=always -i'
alias -g H='| head'
alias -g L="| ${pager}"
alias -g LL="2>&1 | ${pager}"
alias -g M="| most"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g S='| sort'
alias -g SL='| sort | ${pager}'
alias -g T='| tail'
alias -g V='| vim -'

unset pager

# ---------- rclone ----------
# Needs '$rclone_args' and '$rclone_paths' from shrc, must be after sourcing it.
if [ -n "${rclone_args+x}" ] && [ -n "${rclone_paths+x}" ]; then
    for alias_name local_path in "${(@kv)rclone_paths}"; do
        remote_path="onedrive_encrypt:$(basename "$local_path")"
        local_path="$(readlink -f "$local_path")"

        alias sync_"$alias_name"_to_onedrive="rclone sync $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$local_path' '$remote_path'"
        alias sync_"$alias_name"_from_onedrive="rclone sync $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$remote_path' '$local_path'"

        alias copy_"$alias_name"_to_onedrive="rclone copy $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$local_path' '$remote_path'"
        alias copy_"$alias_name"_from_onedrive="rclone copy $rclone_args --exclude-from=<(_rclone_ignore_list '$local_path') '$remote_path' '$local_path'"

    done

    unset rclone_args rclone_paths alias_name local_path remote_path
fi

# ---------- Use lf to select files ----------
_zlf() {
    emulate -L zsh
    local d=$(mktemp -d) || return 1
    {
        mkfifo -m 600 $d/fifo || return 1
        tmux split -bf zsh -c "exec {ZLE_FIFO}>$d/fifo; export ZLE_FIFO; exec lf" || return 1
        local fd
        exec {fd}<$d/fifo
        zle -Fw $fd _zlf_handler
    } always {
        rm -rf $d
    }
}
zle -N _zlf
# bindkey '\ek' _zlf  # Alt+k
bindkey '^e' _zlf  # Ctrl+e

_zlf_handler() {
    emulate -L zsh
    local line
    if ! read -r line <&$1; then
        zle -F $1
        exec {1}<&-
        return 1
    fi
    eval $line
    zle -R
}
zle -N _zlf_handler

# ---------- Load plugins, must be last ----------
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
   source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh && ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#b2c1c1"
fi
