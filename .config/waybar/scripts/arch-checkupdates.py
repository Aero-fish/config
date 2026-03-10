#!/usr/bin/python3
import os
import subprocess

key_packages: set[str] = {
    "amd-ucode",
    "bash",
    "bubblewrap",
    "code",
    "egl-wayland",
    "fcitx5",
    "fd",
    "firefox",
    "fuzzel",
    "fzf",
    "gnome-shell",
    "gnucash",
    "hyprland",
    "hyprlock",
    "intel-ucode",
    "kitty",
    "lazygit",
    "linux",
    "linux-firmware",
    "mesa",
    "mpv",
    "neovim",
    "nvidia",
    "nvidia-open",
    "nvidia-open-dkms",
    "nvidia-utils",
    "nwg-bar",
    "opencl-nvidia",
    "podman",
    "qemu",
    "sway",
    "swayosd",
    "systemd",
    "thunderbird",
    "tmux",
    "uwsm",
    "waybar",
    "wez",
    "wezterm",
    "wine",
    "wine-stage",
    "wlroots",
    "zsh",
}


def main() -> None:
    if os.path.isfile("/usr/bin/checkupdates"):
        new_packages: dict[str, str] = {}
        try:
            results: str = subprocess.check_output("/usr/bin/checkupdates").decode()

            for line in results.splitlines():
                package_name, _, _, new_version, *_ = line.split(" ")
                new_packages[package_name] = new_version

        except Exception:
            pass

    else:
        return

    tooltip: str = "\\n".join([" Check again  Update", "-------------------------"])

    key_packages_update: list[str] = [
        p for p in new_packages.keys() if p in key_packages
    ]

    if not new_packages or not key_packages_update:
        tooltip += "\\nNo key package update"
        print(f'{{"text": "{len(new_packages)}", "tooltip": "{tooltip}"}}')
        exit(0)

    tooltips_list: list[str] = []
    longest_pkg_name = len(max(key_packages_update, key=len))
    for package in key_packages_update:
        space_padding = " " * (longest_pkg_name - len(package) + 2)
        tooltips_list.append(package + space_padding + new_packages[package])
        if len(tooltips_list) > 45:
            break

    tooltip = "\\n".join([tooltip] + tooltips_list)

    print(f'{{"text": "{len(new_packages)}", "tooltip": "{tooltip}"}}')


if __name__ == "__main__":
    main()
