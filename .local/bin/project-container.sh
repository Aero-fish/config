#!/usr/bin/bash
set -e

project_path="$HOME/Projects/container_home_dir"

help() {
    echo "Usage: $(basename -- "$0") <project_name>"
    echo "Container HOME will be mounted from '$project_path/<project_name>'"
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
if [ "$#" -ne 1 ]; then
    help
fi

project_path="$project_path/${1}"

if [ -e "$project_path" ] && [ ! -d "$project_path" ]; then
    echo "Project path '$project_path' exist, but it is not a directory."
    exit 1
fi

mkdir -p "$project_path"
overlay_args=()
overlay_paths=(
    "$HOME/.config/lf"
    "$HOME/.config/my-config/wordlist"
    "$HOME/.config/nvim"
    "$HOME/.config/opencode/opencode.json"
    "$HOME/.config/opencode/tui.json"
    "$HOME/.config/starship.toml"
    "$HOME/.config/tz"
    "$HOME/.config/vim"
    "$HOME/.local/share/nvim/lazy"
    "$HOME/.local/share/nvim/mason"
    "$HOME/.local/share/nvim/site"
    "$HOME/.shrc"
    "$HOME/.zshrc"
)

for p in "${overlay_paths[@]}"; do
    if [ -f "$p" ]; then
        overlay_args+=("--ro-bind-try" "$p" "$p")
    else
        overlay_args+=("--overlay-src" "$p" "--tmp-overlay" "$p")
    fi
done

## '--new-session' breaks lf.
bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --unshare-cgroup \
    \
    --hostname "$1" \
    --cap-drop ALL \
    --die-with-parent \
    --seccomp 9 \
    9</usr/local/share/seccomp-filter/seccomp_filter_tiocsti.bpf
    \
    --setenv _CONTAINER_ 1 \
    \
    --dev-bind / / \
    --proc /proc \
    --tmpfs /tmp \
    --tmpfs "$XDG_RUNTIME_DIR" \
    --bind "$project_path" "$HOME" \
    "${overlay_args[@]}" \
    /usr/bin/zsh
