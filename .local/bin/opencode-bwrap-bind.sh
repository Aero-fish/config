#!/usr/bin/bash
set -e
## Source this file to get the bwrap binding for opencode configs.

config_path="$HOME/Projects/AI/agent_configs/opencode"
container_path="$HOME/.cache/ai_workspaces/opencode"

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

# shellcheck disable=SC2034
bind_args=(
    "--bind-try" "$config_path/agents" "$HOME/.config/opencode/agents"
    "--bind-try" "$config_path/prompts" "$HOME/.config/opencode/prompts"
    "--bind-try" "$config_path/skills" "$HOME/.config/opencode/skills"
    "--bind-try" "$config_path/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    "--bind-try" "$config_path/tui.json" "$HOME/.config/opencode/tui.json"
    "--bind-try" "$config_path/auth.json" "$HOME/.local/share/opencode/auth.json"
)
