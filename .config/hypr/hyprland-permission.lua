hl.config({
    ecosystem = {
        enforce_permissions = true,
    }
})
-- General
hl.permission({ binary = "/usr/lib/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/hyprpicker", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/gpu-screen-recorder", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/hyprlock", type = "screencopy", mode = "allow" })

hl.permission({ binary = "hl-virtual-keyboard-fcitx5", type = "keyboard", mode = "allow" })

hl.permission({ binary = "power-button.*", type = "keyboard", mode = "deny" })
hl.permission({ binary = "asus-wmi-hotkeys", type = "keyboard", mode = "deny" })
hl.permission({ binary = "eee-pc-wmi-hotkeys", type = "keyboard", mode = "deny" })

-- Beast
hl.permission({ binary = "zsa-technology-labs-voyager", type = "keyboard", mode = "allow" })
hl.permission({ binary = "zsa-technology-labs-voyager-.*", type = "keyboard", mode = "allow" })

hl.permission({ binary = "flydigi-flydigi-apex5-wireless-keyboard", type = "keyboard", mode = "deny" })
hl.permission({ binary = "flydigi-flydigi-apex5-wireless-keyboard-.*", type = "keyboard", mode = "deny" })

-- Lenovo
hl.permission({ binary = "ideapad-extra-buttons", type = "keyboard", mode = "deny" })
hl.permission({ binary = "hd-audio-generic-headphone", type = "keyboard", mode = "allow" })
hl.permission({ binary = "razer-razer-basilisk-v3-2", type = "keyboard", mode = "allow" })

hl.permission({ binary = "razer-razer-basilisk-v3-.*", type = "keyboard", mode = "deny" })

-- Catch all
hl.permission({ binary = ".*", type = "keyboard", mode = "ask" })
hl.permission({ binary = ".*", type = "cursorpos", mode = "ask" })
