#!/bin/bash
set -e

backup_path="$HOME/.snapshots"

# Stop podman
echo "Will now stop all pods and containers. Press enter to continue, Ctrl+C to abort."
read
podman pod stop -a
podman container stop -a

vol_dir="$HOME/.local/share/containers/storage/volumes"
if [ -d "$vol_dir" ]; then
    echo "Backup container volumes."
    rm -f "$backup_path/container_volume.tar.zst"
    size="$(podman unshare du -csb "$vol_dir" | tail -1 | awk '{print $1}')"
    podman unshare tar -C "$HOME/.local/share/containers/storage" -cpf - volumes |
        pv -s "$size" |
        zstdmt >"$backup_path/container_volume.tar.zst"
fi
