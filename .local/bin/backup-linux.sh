#!/bin/bash
set -e
[ "${UID}" -eq 0 ] || exec sudo "$0" "$@"

if [ -z "${SUDO_USER}" ]; then
    user_home="${HOME}"
else
    user_home="$(eval echo ~${SUDO_USER})"
fi

date="$(date "+%Y-%m-%d_%H-%M-%S")"
archive_name="linux.${date}.tar.zst"
snapshot_path="${user_home}/.snapshots/linux"
sudo -u "${SUDO_USER}" mkdir -p "${snapshot_path}"

## Use "/dev/*" to keep the dir at /, but not its content
exclude_paths=(
    "/dev/*"
    "/etc/pacman.d/gnupg/S.gpg-agent*"
    "/home/**/*"
    "/lost+found"
    "/media/*"
    "/mnt/*"
    "/proc/*"
    "/root/.cache/*"
    "/run/*"
    "/srv/ftp/*"
    "/srv/http/*"
    "/srv/smb/smbshare/*/*"
    "/srv/smb/printer/*"
    "/swapfile"
    "/sys/*"
    "/tmp/*"
    "/var/cache/*"
    "/var/lib/dhcpcd/*"
    "/var/lib/libvirt/images/*"
)

exclude_args=()
for p in "${exclude_paths[@]}"; do
    exclude_args+=("--exclude" "$p")
done

echo "Estimating size..."
backup_size=$(du -csb "${exclude_args[@]}" / | tail -1 | awk '{print $1}')
echo "Uncompressed size: $((backup_size / 1024 / 1024))MB"

tar "${exclude_args[@]}" --acls --xattrs --xattrs-include=* -cpf - / |
    pv -s "${backup_size}" |
    zstdmt >"${snapshot_path}/${archive_name}"

fd --exact-depth 1 --unrestricted --exclude "${archive_name}" . "${snapshot_path}" \
    --exec-batch rm -rf {}

backup_size=$(du -csb "${snapshot_path}/${archive_name}" | tail -1 | awk '{print $1}')
echo "Compressed size: $((backup_size / 1024 / 1024))MB"

echo -e "\e[31mBackup finished.\e[0m"
