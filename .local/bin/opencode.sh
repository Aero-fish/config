#!/usr/bin/bash
set -e

agent_name="opencode"
agent_path="$HOME/misc/repo/$agent_name"

config_path="$HOME/Projects/AI/agent_configs/$agent_name"
container_path="$HOME/Projects/AI/agent_workspaces/$agent_name"

current_path="$(pwd)"

mkdir -p "$config_path/"{agents,prompts,skills} "$container_path"
mkdir -p "$XDG_RUNTIME_DIR/$agent_name/"{tmp,run}

config_files=(
    "auth.json"
    "opencode.jsonc"
    "kv.json"
)
for f in "${config_files[@]}"; do
    if [ ! -f "$config_path/$f" ]; then
        echo "{}" >"$config_path/$f"
    fi
done

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon

ro_bind_path+=(
    "$agent_path"
    "/usr/include"
    "/usr/local/bin"
    "/usr/local/share/bwrap_share"
    "/usr/local/share/seccomp-filter"
)

generate_hide_default
generate_hide_rc
source /usr/local/share/bwrap_share/generate_args

extra_args=(
    "--bind-try" "$container_path" "$HOME"
    #
    "--bind-try" "$config_path/agents" "$HOME/.config/opencode/agents"
    "--bind-try" "$config_path/prompts" "$HOME/.config/opencode/prompts"
    "--bind-try" "$config_path/skills" "$HOME/.config/opencode/skills"
    #
    "--bind-try" "$config_path/auth.json" "$HOME/.local/share/opencode/auth.json"
    "--bind-try" "$config_path/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    "--bind-try" "$config_path/kv.json" "$HOME/.local/state/opencode/kv.json"
    #
    # Let all instance share the same tmpfs
    "--bind-try" "$XDG_RUNTIME_DIR/$agent_name/tmp" "/tmp"
    "--bind-try" "$XDG_RUNTIME_DIR/$agent_name/run" "$XDG_RUNTIME_DIR"
)

if [ "$current_path" != "$config_path" ] && [ "$current_path" != "$HOME" ]; then
    extra_args+=("--bind" "$current_path" "$current_path")
    extra_args+=("--chdir" "$current_path")
fi

## '--new-session' breaks lf, and maybe some other tools.
## Use another disposable container to do testing on the generated code.
## Use 'seccomp_filter_tiocsti' only not 'default_seccomp_filter' to avoid crashing tools.
bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --unshare-cgroup \
    \
    --hostname "$agent_name" \
    --proc /proc \
    --cap-drop ALL \
    --die-with-parent \
    --seccomp 9 \
    \
    --clearenv \
    --setenv _CONTAINER_ 1 \
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" \
    --setenv PATH "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin" \
    \
    --dev /dev \
    "${dev_bind[@]}" \
    "${tmpfs[@]}" \
    "${extra_args[@]}" \
    "${ro_bind[@]}" \
    "${bind[@]}" \
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    --perms 444 --file 7 /etc/passwd \
    --perms 444 --file 8 /etc/group \
    "${remount_ro[@]}" \
    "$agent_path"/opencode "$@" \
    9</usr/local/share/seccomp-filter/seccomp_filter_tiocsti.bpf \
    7< <(echo "hugh:x:1000:1000::/home/hugh:/bin/nologin") \
    8< <(echo "hugh:x:1000:")
