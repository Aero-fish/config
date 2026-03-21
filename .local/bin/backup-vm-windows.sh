#!/bin/bash
set -e

if [ "$#" -ne 0 ] && [ -n "$1" ]; then
    vm_name="$1"
else
    vm_name="windows"
fi

pc_name="$(cat /proc/sys/kernel/hostname)"

# Check VM status
if ! virsh list --all | rg -q -F "$vm_name"; then
    echo "VM '$vm_name' is not found."
    exit 1
fi

if virsh list --state-running | rg -q -F "$vm_name"; then
    echo "VM '$vm_name' is running."
    exit 1
fi

date="$(date "+%Y-%m-%d_%H-%M-%S")"
snapshots_dir=".snapshots/vm/${vm_name}"
snapshot_path="$HOME/${snapshots_dir}"
backup_path="$HOME/.backup/user_data/${pc_name}_archives/vm/${vm_name}"
mkdir -p "$snapshot_path" "$backup_path"

# Check if VM exist. If it exist, remove old backups
if [ -f "$HOME/.local/share/libvirt/images/${vm_name}.qcow2" ] &&
    [ -f /usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd ] &&
    [ -f "$HOME/.config/libvirt/qemu/nvram/${vm_name}_VARS.fd" ]; then
    fd -t f -I '(image|ovmf|nvram|hooks|smbios)\.tar\.zst' "$snapshot_path" \
        --exec-batch rm -f {}
    rm -f "$snapshot_path"/*.txt
else
    echo "VM '$vm_name' not found."
    exit 1
fi

virsh dumpxml "$vm_name" >"${snapshot_path}/${vm_name}.xml"

echo "Archiving OS image..."
tar -cf - -C "$HOME/.local/share/libvirt/images" "${vm_name}.qcow2" |
    pv -s "$(du -sb "$HOME/.local/share/libvirt/images/${vm_name}.qcow2" |
        tail -1 |
        awk '{print $1}')" |
    zstdmt >"${snapshot_path}/image.tar.zst"

echo "Archiving OVMF..."
tar -cf - -C /usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd |
    pv -s "$(du -sb /usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd |
        tail -1 |
        awk '{print $1}')" |
    zstdmt >"${snapshot_path}/ovmf.tar.zst"

echo "Archiving nvram..."
tar -cf - -C "$HOME/.config/libvirt/qemu/nvram" "${vm_name}_VARS.fd" |
    pv -s "$(du -sb "$HOME/.config/libvirt/qemu/nvram/${vm_name}_VARS.fd" |
        tail -1 |
        awk '{print $1}')" |
    zstdmt >"${snapshot_path}/nvram.tar.zst"

echo "Archiving hooks..."
if [ -d "$HOME/.config/libvirt/hooks/qemu.d/${vm_name}" ]; then
    tar -cf - -C "$HOME/.config/libvirt/hooks/qemu.d" "$vm_name" |
        pv -s "$(du -sb "$HOME/.config/libvirt/hooks/qemu.d/${vm_name}" |
            tail -1 |
            awk '{print $1}')" |
        zstdmt >"${snapshot_path}/hooks.tar.zst"
fi

echo "Archiving smbios..."
if [ -d "$HOME/.config/libvirt/qemu/smbios/${vm_name}" ]; then
    tar -cf - -C "$HOME/.config/libvirt/qemu/smbios" "$vm_name" |
        pv -s "$(du -sb "$HOME/.config/libvirt/qemu/smbios/${vm_name}" |
            tail -1 |
            awk '{print $1}')" |
        zstdmt >"${snapshot_path}/smbios.tar.zst"
fi

echo "Archiving TPM..."
uuid="$(rg -F uuid "${snapshot_path}/${vm_name}.xml" |
    sed -E "s/.*>([a-zA-Z0-9-]+)<.*/\1/")"

if [ -d "$HOME/.config/libvirt/qemu/swtpm/$uuid" ]; then
    tar -cf - -C "$HOME/.config/libvirt/qemu/swtpm" "$uuid" |
        pv -s "$(du -cb "$HOME/.config/libvirt/qemu/swtpm/${uuid}" |
            tail -1 |
            awk '{print $1}')" |
        zstdmt >"${snapshot_path}/swtpm.tar.zst"
fi

cat <<EOF >"${snapshot_path}/restore-vm.sh"
#!/bin/bash
set -e

snapshot_path="\$HOME/"${snapshots_dir@Q}
vm_name=${vm_name@Q}

mkdir -p "\$HOME/.local/share/libvirt/images" "\$HOME/.config/libvirt/qemu/nvram" \\
    "\$HOME/.config/libvirt/hooks/qemu.d"

if virsh list --all | rg -q -F "\$vm_name"; then
    virsh undefine --nvram "\$vm_name"
fi

virsh define "\${snapshot_path}/\${vm_name}.xml"

rm -f "\$HOME/.config/libvirt/qemu/nvram/\${vm_name}_VARS.fd"
rm -rf "\$HOME/.config/libvirt/hooks/qemu.d/\${vm_name}"

if [ -f "\${snapshot_path}/image.tar.zst" ]; then
    rm -f "\$HOME/.local/share/libvirt/images/\${vm_name}.qcow2"
    pv "\${snapshot_path}/image.tar.zst" |
        tar --zstd -C "\$HOME/.local/share/libvirt/images" -xf -

elif [ ! -f "\$HOME/.local/share/libvirt/images/\${vm_name}.qcow2" ]; then
    qemu-img create -f qcow2 "\$HOME/.local/share/libvirt/images/\$vm_name.qcow2" 65G
fi

pv "\${snapshot_path}/nvram.tar.zst" |
    tar --zstd -C "\$HOME/.config/libvirt/qemu/nvram" -xf -

if [ -f "\${snapshot_path}/hooks.tar.zst" ]; then
    pv "\${snapshot_path}/hooks.tar.zst" |
        tar --zstd -C "\$HOME/.config/libvirt/hooks/qemu.d" -xf -
fi

if [ -f "\${snapshot_path}/smbios.tar.zst" ]; then
    mkdir -p "\$HOME/.config/libvirt/qemu/smbios"
    pv "\${snapshot_path}/smbios.tar.zst" |
        tar --zstd -C "\$HOME/.config/libvirt/qemu/smbios" -xf -
fi

if [ -f "\${snapshot_path}/swtpm.tar.zst" ]; then
    mkdir -p "\$HOME/.config/libvirt/qemu/swtpm"
    pv "\${snapshot_path}/swtpm.tar.zst" |
        tar --zstd -C "\$HOME/.config/libvirt/qemu/swtpm" -xf -
fi

echo -e "\e[31mRestore vm '\$vm_name' completed.\e[0m"
EOF

chmod 700 "${snapshot_path}/restore-vm.sh"
touch "${snapshot_path}/${date}.txt"

rsync -ah --delete --no-inc-recursive --info=progress2 --exclude '/image.tar.zst' "${snapshot_path}/" "${backup_path}"

echo -e "\e[31mBackup vm '$vm_name' completed.\e[0m"
