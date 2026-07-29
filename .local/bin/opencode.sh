#!/usr/bin/bash
set -e
source "$HOME/.local/bin/opencode-bwrap-bind.sh"

current_path="$(pwd)"
bin_path="$HOME/misc/repo/opencode/opencode"

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
    "$bin_path" "$@" 9</usr/local/share/seccomp-filter/seccomp_filter_tiocsti.bpf
