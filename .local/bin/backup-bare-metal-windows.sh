#!/bin/bash
set -e
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if [ -z "$SUDO_USER" ]; then
    user_home="$HOME"
else
    user_home="$(eval echo ~"$SUDO_USER")"
fi

pc_name="$(cat /proc/sys/kernel/hostname)"
if [ "$pc_name" = "beast" ]; then
    date="$(date "+%Y-%m-%d_%H-%M-%S")"
    snapshot_dir=".snapshots/bare-metal-windows"
    snapshot_path="${user_home}/${snapshot_dir}"
    sudo -u "$SUDO_USER" mkdir -p "$snapshot_path"

    # Guess the nvme drive
    nvme_name="$(lsblk -o 'NAME,FSTYPE,UUID' --json --noempty | jq -r '.blockdevices[] | select(.children and .children[].fstype==null) | .children[] | select( .fstype=="ntfs" and (.name | startswith("nvme")))| .name' | head -n 1)"
    nvme_name="${nvme_name:0:7}"
    echo "Windows is on ${nvme_name}"

    # Check for partitions
    for i in {2..5}; do
        if [ ! -b "/dev/${nvme_name}p${i}" ]; then
            echo "/dev/${nvme_name}p${i} does not exist, wrong guess for the windows drive"
            exit 1
        fi
    done
    echo "p2-p5 exists for ${nvme_name}"

    # Remove old backup and mark the backup date
    rm -f "$snapshot_path/"*.img.zst "$snapshot_path/"*.txt

    # Backup windows
    for i in {2..5}; do
        pv <"/dev/${nvme_name}p${i}" | zstdmt >"$snapshot_path/p${i}.img.zst"
    done
    touch "$snapshot_path/$date.txt"

    # Generate restore script
    cat <<EOF >"${snapshot_path}/restore-bare-metal-windows.sh"
#!/bin/bash
set -e
[ "\$UID" -eq 0 ] || exec sudo "\$0" "\$@"

if [ -z "\$SUDO_USER" ]; then
    user_home="\$HOME"
else
    user_home="\$(eval echo ~"\$SUDO_USER")"
fi

snapshot_path="\$user_home/"${snapshot_dir@Q}

for img_name in p{2..5}.img.zst; do
    if [ ! -f "\$snapshot_path/\$img_name" ]; then
        echo -e "Images \e[31m\$(echo p{2..5}.img.zst)\e[0m must exist."
        exit 1
    fi
done

# Guess the nvme drive
nvme_name="\$(lsblk -o 'NAME,FSTYPE,UUID' --json --noempty | jq -r '.blockdevices[] | select(.children and .children[].fstype==null) | .children[] | select( .fstype=="ntfs" and (.name | startswith("nvme")))| .name' | head -n 1)"
nvme_name="\${nvme_name:0:7}"
echo "Windows is on \${nvme_name}"

# Check for partitions
for i in {2..5}; do
    if [ ! -b "/dev/\${nvme_name}p\${i}" ]; then
        echo "/dev/\${nvme_name}p\${i} does not exist, wrong guess for the windows drive"
        exit 1
    fi
done
echo "p2-p5 exists for \${nvme_name}"

echo "Extracting images..."

for i in 2 3 5 4; do
    zstdcat "\${snapshot_path}/p\${i}.img.zst" | pv >"/dev/\${nvme_name}p\${i}"
done
EOF

    chown "$SUDO_USER":"$SUDO_USER" "$snapshot_path"/*.img.zst \
        "$snapshot_path/$date.txt" \
        "$snapshot_path/restore-bare-metal-windows.sh"
    chmod 700 "$snapshot_path/restore-bare-metal-windows.sh"

else
    echo "Back up windows is not defined for '$pc_name'"
    exit 1
fi

echo -e "\e[31mBackup finished.\e[0m"
