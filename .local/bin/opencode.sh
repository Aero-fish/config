#!/usr/bin/bash
set -e

config_path="$HOME/Projects/AI/agent_configs/opencode"
container_path="$HOME/.cache/ai_workspaces/opencode"
bin_path="$HOME/misc/repo/opencode/opencode"
current_path="$(pwd)"

mkdir -p "$config_path/"{agents,prompts,skills} "$container_path"

config_files=(
    "opencode.jsonc"
    "tui.json"
    "auth.json"
)
for f in "${config_files[@]}"; do
    if [ ! -f "$config_path/$f" ]; then
        echo "{}" >"$config_path/$f"
    fi
done

bind_args=(
    "--bind-try" "$config_path/agents" "$HOME/.config/opencode/agents"
    "--bind-try" "$config_path/prompts" "$HOME/.config/opencode/prompts"
    "--bind-try" "$config_path/skills" "$HOME/.config/opencode/skills"
    "--bind-try" "$config_path/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    "--bind-try" "$config_path/tui.json" "$HOME/.config/opencode/tui.json"
    "--bind-try" "$config_path/auth.json" "$HOME/.local/share/opencode/auth.json"
)


chdir_args=()
if [ "$current_path" != "$config_path" ] && [ "$current_path" != "$HOME" ]; then
    bind_args+=("--bind" "$current_path" "$current_path")
    chdir_args+=("--chdir" "$current_path")
fi

## '--new-session' breaks lf, and maybe some other tools.
bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --unshare-cgroup \
    \
    --hostname "opencode" \
    --cap-drop ALL \
    --die-with-parent \
    --seccomp 9 \
    9</usr/local/share/seccomp-filter/seccomp_filter_tiocsti.bpf \
    \
    --clearenv \
    --setenv _CONTAINER_ 1 \
    \
    --dev-bind / / \
    --proc /proc \
    --tmpfs /tmp \
    --tmpfs "$XDG_RUNTIME_DIR" \
    --bind-try "$container_path" "$HOME" \
    "${bind_args[@]}" \
    --ro-bind "$bin_path" "$bin_path" \
    "${chdir_args[@]}" \
    "$bin_path" "$@"
