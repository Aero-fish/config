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
overlay_arg=()
setting_path=(
    "$HOME/.config/lf"
    "$HOME/.config/my-config/wordlist"
    "$HOME/.config/nvim"
    "$HOME/.config/starship.toml"
    "$HOME/.config/tz"
    "$HOME/.local/share/nvim/lazy"
    "$HOME/.local/share/nvim/mason"
    "$HOME/.local/share/nvim/site"
    "$HOME/.shrc"
    "$HOME/.zshrc"
)

for s in "${setting_path[@]}"; do
    if [ -f "$s" ]; then
        overlay_arg+=("--ro-bind-try" "$s" "$s")
    else
        overlay_arg+=("--overlay-src" "$s" "--tmp-overlay" "$s")
    fi
done

bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --unshare-cgroup \
    \
    --hostname "$1" \
    --cap-drop ALL \
    --new-session \
    --die-with-parent \
    \
    --setenv "_CONTAINER_" "1" \
    \
    --dev-bind / / \
    --proc /proc \
    --tmpfs "$HOME" \
    --bind "$project_path" "$HOME" \
    "${overlay_arg[@]}" \
    /usr/bin/zsh
