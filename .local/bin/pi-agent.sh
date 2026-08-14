#!/usr/bin/bash
set -e

agent_name="pi-agent"
agent_path="$HOME/misc/repo/$agent_name"

host_name="$(cat /proc/sys/kernel/hostname)"
host_name="${host_name// /_}"

config_path="$HOME/.config/ai/agent_configs/${agent_name}_${host_name}"
container_path="$HOME/workspace/ai_workspace/agents/${agent_name}_${host_name}"
skill_path="$HOME/.config/ai/skills"
run_path="$XDG_RUNTIME_DIR/agent/${agent_name}_${host_name}/run"
tmp_path="$XDG_RUNTIME_DIR/agent/${agent_name}_${host_name}/tmp"

current_path="$(pwd)"

mkdir -p "$tmp_path" "$run_path" "$container_path/.cache/zsh"

source /usr/local/share/bwrap_share/strict_rules
source /usr/local/share/bwrap_share/net_addon

ro_bind_path+=(
    "/usr/include"
    "/usr/local/bin"
    "/usr/local/share/bwrap_share"
    "/usr/local/share/seccomp-filter"
)

source /usr/local/share/bwrap_share/generate_args

## Container baseline
extra_args=(
    "--bind-try" "$container_path" "$HOME"
    "--ro-bind" "$(readlink -f "$agent_path")" "$agent_path"
    "--bind-try" "$skill_path" "$HOME/.agents/skills"

    # Let all instance share the same tmpfs
    "--bind-try" "$tmp_path" "/tmp"
    "--bind-try" "$run_path" "$XDG_RUNTIME_DIR"

    # Map config files
    "--bind-try" "$config_path" "$HOME/.pi/agent"
)

## Configs that store in workspace, not in '~/.config/ai'
config_dir=(
    "npm"
    "sessions"
)
for d in "${config_dir[@]}"; do
    mkdir -p "$container_path/.pi/agent/$d"
    extra_args+=("--bind-try" "$container_path/.pi/agent/$d" "$HOME/.pi/agent/$d")
done

config_files=(
    # "auth.json"
)

for f in "${config_files[@]}"; do
    if [ ! -f "$container_path/.pi/agent/$f" ]; then
        touch "$container_path/.pi/agent/$f"
    fi
    extra_args+=("--bind-try" "$container_path/.pi/agent/$f" "$HOME/.pi/agent/$f")
done

if [ "$current_path" != "$HOME" ]; then
    extra_args+=("--bind" "$current_path" "$current_path" "--chdir" "$current_path")
else
    extra_args+=("--chdir" "$HOME")
fi

## Map nvim config, allow editing prompt with nvim
overlay_paths=(
    "$HOME/.config/my-config/wordlist"
    "$HOME/.config/nvim"
    "$HOME/.local/share/nvim/lazy"
    "$HOME/.local/share/nvim/mason"
    "$HOME/.local/share/nvim/site"
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

## '--new-session' breaks lf, and maybe some other tools.
## Use another disposable container to do testing on the generated code.
## Use 'seccomp_filter_tiocsti' only not 'default_seccomp_filter' to avoid crashing tools.
## dbus is needed if wanting to use nvim in the container
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
    --setenv COLORTERM truecolor \
    --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS" \
    --setenv DISPLAY "$DISPLAY" \
    --setenv EDITOR nvim \
    --setenv HOME "$HOME" \
    --setenv NPM_CONFIG_PREFIX "$HOME/.node_modules" \
    --setenv PATH "$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin" \
    --setenv SHELL "$SHELL" \
    --setenv TERM xterm-kitty \
    --setenv TERMINFO "/usr/lib/kitty/terminfo" \
    --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY" \
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
    "${hide[@]}" \
    "${unhide_ro[@]}" \
    "${unhide[@]}" \
    "${symbolic_link[@]}" \
    --ro-bind-try "$XDG_RUNTIME_DIR"/tray-proxy "$dbus_address" \
    --perms 444 --file 7 /etc/passwd \
    --perms 444 --file 8 /etc/group \
    "${remount_ro[@]}" \
    "$agent_path"/pi "$@" \
    9</usr/local/share/seccomp-filter/seccomp_filter_tiocsti.bpf \
    7< <(echo "hugh:x:1000:1000::/home/hugh:/bin/nologin") \
    8< <(echo "hugh:x:1000:")
