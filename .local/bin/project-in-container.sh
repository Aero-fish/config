#!/usr/bin/bash
set -e

project_storage="$HOME/Projects/container_home_dir"

help() {
    echo "Usage: $(basename -- "$0") <project_name>"
    echo "Container HOME will be mounted from '$project_storage/<project_name>'"
    exit 0
}

# Parse command-line options. "ab:" means simple flag -a and flag with argument -b
# Value of the flag is stored in "$OPTARG"
while getopts "h" opt; do
    case $opt in
    h) help ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

## Need exactly one argument
if [ -n "$_CONTAINER_" ]; then
    echo "Already inside a container."
    exit 1
elif [ "$#" -ne 1 ]; then
    help
fi

project_name="$1"

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon

ro_bind_path+=(
    "/usr/include"
    "/usr/local/bin"
    "/usr/local/share/bwrap_share"
    "/usr/local/share/seccomp-filter"

)

# shellcheck disable=SC2119
generate_hide_default

source /usr/local/share/bwrap_share/generate_args

extra_args=()
if [ "$project_name" == "tmp_container" ]; then
    ## Let instance of a project share the same HOME and tmpfs

    mkdir -p "$XDG_RUNTIME_DIR/projects/$project_name"
    container_path="$(mktemp -d "$XDG_RUNTIME_DIR/projects/$project_name/workspace_XXXXX")"
    run_path="$XDG_RUNTIME_DIR/projects/$project_name/run"
    tmp_path="$XDG_RUNTIME_DIR/projects/$project_name/tmp"

    trap 'rm -rf "$container_path"; if [ "$(find "$XDG_RUNTIME_DIR/projects/$project_name" -maxdepth 1 -mindepth 1 -type d -name "workspace_*" -printf "%f\n" | wc -l)" -eq 0 ]; then echo hi; rm -rf "$XDG_RUNTIME_DIR/projects/$project_name"; fi' EXIT

    mkdir -p "$container_path/.cache/zsh" "$run_path" "$tmp_path"

    extra_args+=(
        # Let all instance share the same HOME and tmpfs
        "--bind-try" "$container_path" "$HOME"
        "--bind-try" "$tmp_path" "/tmp"
        "--bind-try" "$run_path" "$XDG_RUNTIME_DIR"
    )

else
    ## Let instance of a project share the same HOME and tmpfs
    container_path="$project_storage/$project_name"
    run_path="$XDG_RUNTIME_DIR/projects/$project_name/run"
    tmp_path="$XDG_RUNTIME_DIR/projects/$project_name/tmp"

    mkdir -p "$container_path/.cache/zsh" "$run_path" "$tmp_path"

    extra_args+=(
        # Let all instance share the same HOME and tmpfs
        "--bind-try" "$container_path" "$HOME"
        "--bind-try" "$tmp_path" "/tmp"
        "--bind-try" "$run_path" "$XDG_RUNTIME_DIR"
    )
fi

## "$HOME/.local/bin" contains script to containerises ai agents.
overlay_paths=(
    "$HOME/.config/lf"
    "$HOME/.config/my-config/wordlist"
    "$HOME/.config/nvim"
    "$HOME/.config/pythonrc"
    "$HOME/.config/starship.container.toml"
    "$HOME/.config/tz"
    "$HOME/.config/vim"
    "$HOME/.local/share/nvim/lazy"
    "$HOME/.local/share/nvim/mason"
    "$HOME/.local/share/nvim/site"
    "$HOME/.shrc"
    "$HOME/.zshrc"

    # AI agents
    "$HOME/Projects/AI/agent_configs"
    "$HOME/misc/repo/opencode"
    "$HOME/.local/bin/opencode.sh"
    "$HOME/misc/repo/hermes-agent"
    "$HOME/.local/bin/hermes.sh"
)

## Overlay file only works with dir. Use '--ro-bind-try' if its a file.
for p in "${overlay_paths[@]}"; do
    [ ! -e "$p" ] && continue
    if [ -f "$p" ]; then
        extra_args+=("--ro-bind-try" "$p" "$p")
    else
        extra_args+=("--overlay-src" "$(readlink -f "$p")" "--tmp-overlay" "$p")
    fi
done

## AI agent
extra_args+=(
    ## Agent bin
    "--ro-bind" "$(readlink -f "$HOME/misc/repo/opencode")" "$HOME/misc/repo/opencode"
    "--ro-bind" "$(readlink -f "$HOME/misc/repo/hermes-agent")" "$HOME/misc/repo/hermes-agent"

    ## Agent containerised
    "--ro-bind" "$(readlink -f "$HOME/.local/bin/opencode.sh")" "$HOME/.local/bin/opencode.sh"
    "--ro-bind" "$(readlink -f "$HOME/.local/bin/hermes-agent.sh")" "$HOME/.local/bin/hermes-agent.sh"

    ## Agent config
    "--bind-try" "$(readlink -f "$HOME/Projects/AI/agent_configs")" "$HOME/Projects/AI/agent_configs"
    "--bind-try" "$(readlink -f "$HOME/Projects/AI/skills")" "$HOME/Projects/AI/skills"
)

## '--new-session' breaks lf, and maybe some other tools.
## Use another disposable container to do testing on the generated code.
## Use 'seccomp_filter_tiocsti' only not 'default_seccomp_filter' to avoid crashing tools.
## Don't hide rc, use overlay
bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --unshare-cgroup \
    \
    --hostname "$project_name" \
    --proc /proc \
    --cap-drop ALL \
    --die-with-parent \
    --seccomp 9 \
    \
    --clearenv \
    --setenv COLORTERM truecolor \
    --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS" \
    --setenv EDITOR nvim \
    --setenv HOME "$HOME" \
    --setenv LANG "en_NZ.UTF-8" \
    --setenv LESS "--clear-screen --ignore-case --no-lessopen --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs 4 --no-init --incsearch --mouse --wordwrap" \
    --setenv LESS_TERMCAP_mb $'\E[1;31m' \
    --setenv LESS_TERMCAP_md $'\E[1;31m' \
    --setenv LESS_TERMCAP_me $'\E[0m' \
    --setenv LESS_TERMCAP_se $'\E[0m' \
    --setenv LESS_TERMCAP_ue $'\E[0m' \
    --setenv LESS_TERMCAP_us $'\E[1;32m' \
    --setenv PAGER less \
    --setenv PATH "$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin" \
    --setenv PYTHONSTARTUP "$HOME/.config/pythonrc" \
    --setenv SHELL /bin/zsh \
    --setenv STARSHIP_SHELL zsh \
    --setenv TERM xterm-kitty \
    --setenv TZ "Pacific/Auckland" \
    --setenv VISUAL nvim \
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" \
    --setenv _CONTAINER_ 1 \
    --setenv _ZO_DATA_DIR "$HOME/.cache/zsh" \
    \
    --dev /dev \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    "${extra_args[@]}" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${unhide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    --ro-bind-try "$XDG_RUNTIME_DIR"/tray-proxy "$dbus_address" \
    --perms 444 --file 7 /etc/passwd \
    --perms 444 --file 8 /etc/group \
    "${remount_ro[@]}" \
    /usr/bin/zsh \
    9</usr/local/share/seccomp-filter/seccomp_filter_tiocsti.bpf \
    7< <(echo "hugh:x:1000:1000::/home/hugh:/bin/nologin") \
    8< <(echo "hugh:x:1000:")
