-----------------------------
-- Variables
-----------------------------
-- Mod list: SHIFT CAPS CTRL/CONTROL ALT MOD2 MOD3 SUPER/WIN/LOGO/MOD4 MOD5

-- System: MOD + CTRL
-- Layout: MOD + ALT
-- Move: MOD + SHIFT
local scripts_dir = os.getenv("HOME") .. "/.config/hypr/scripts"

-----------------------------
-- System
-----------------------------

-- Kill active window
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())

-- Toggle waybar
hl.bind("SUPER + CTRL + Space", hl.dsp.exec_raw("pkill -x -SIGUSR1 waybar"))

-- Active window info
hl.bind("SUPER + CTRL + Slash",
    hl.dsp.exec_raw(scripts_dir .. "/hyprland-prop.sh kitty"))

-- Lock system
hl.bind("SUPER + CTRL + Backspace", hl.dsp.exec_raw(scripts_dir .. "/lock.sh force"))

--  Reload
hl.bind("SUPER + CTRL + R", hl.dsp.exec_raw("hyprctl reload"))


-----------------------------
-- Windows and workspace
-----------------------------

-- Move focus
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))

hl.bind("SUPER + Left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "down" }))

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT+ Tab", hl.dsp.window.cycle_next({ next = false }))

-- Resize window
hl.bind("SUPER + CTRL + SHIFT + H",
    hl.dsp.window.resize({
        x = -50,
        y = 0,
        relative = true
    }))
hl.bind("SUPER + CTRL + SHIFT + L",
    hl.dsp.window.resize({
        x = 50,
        y = 0,
        relative = true
    }))
hl.bind("SUPER + CTRL + SHIFT + K",
    hl.dsp.window.resize({
        x = 0,
        y = -50,
        relative = true
    }))
hl.bind("SUPER + CTRL + SHIFT + J",
    hl.dsp.window.resize({
        x = 0,
        y = 50,
        relative = true
    }))

hl.bind("SUPER + CTRL + SHIFT + Left",
    hl.dsp.window.resize({
        x = -50,
        y = 0,
        relative = true
    }))
hl.bind("SUPER + CTRL + SHIFT + Right",
    hl.dsp.window.resize({
        x = 50,
        y = 0,
        relative = true
    }))
hl.bind("SUPER + CTRL + SHIFT + Up",
    hl.dsp.window.resize({
        x = 0,
        y = -50,
        relative = true
    }))
hl.bind("SUPER + CTRL + SHIFT + Down",
    hl.dsp.window.resize({
        x = 0,
        y = 50,
        relative = true
    }))

-- Move windows
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

hl.bind("SUPER + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))

-- Resize split to 50%:50%
hl.bind("SUPER + Equal", hl.dsp.layout("splitratio 1.0 exact"))

-- Toggle fullscreen
hl.bind("SUPER + F",
    hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + SHIFT + F",
    hl.dsp.window.fullscreen({
        mode = "maximized",
        action = "toggle"
    }))

-- Toggle floating
hl.bind("SUPER + ALT + F", hl.dsp.window.float({ action = "toggle" }))

--  Toggle pin (Show in all workspaces, floating only)
hl.bind("SUPER + ALT + P", function()
    hl.dispatch(hl.dsp.window.pin())
    hl.dispatch(hl.dsp.exec_raw(
        "if [ \"$(hyprctl activewindow -j | jq -r '.floating')\" = \"true\" ]; then if [ \"$(hyprctl activewindow -j | jq -r '.pinned')\" = \"true\" ]; then notify-send 'Pinned'; else notify-send 'Unpinned'; fi; else notify-send 'Can only pin floating window'; fi"
    ))
end)

-- Go to workspace
-- Move active window to a workspace
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))

    hl.bind("SUPER + SHIFT + " .. key,
        hl.dsp.window.move({
            workspace = i,
            follow = true
        }))

    hl.bind("SUPER + SHIFT + ALT + " .. key,
        hl.dsp.window.move({
            workspace = i,
            follow = false
        }))
end

-- Move to an empty workspace
hl.bind("SUPER + SHIFT + D", hl.dsp.window.move({ workspace = "empty", follow = true }))
hl.bind("SUPER + SHIFT + ALT + D",
    hl.dsp.window.move({
        workspace = "empty",
        follow = false
    }))

-- Go to an empty workspace
hl.bind("SUPER + D", hl.dsp.focus({ workspace = "empty" }))

-- Scroll through existing workspaces
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))

hl.bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "e+1" }))

hl.bind("SUPER + CTRL + Left", hl.dsp.focus({ workspace = "e-1" }))  -- Windows mapping
hl.bind("SUPER + CTRL + Right", hl.dsp.focus({ workspace = "e+1" })) -- Windows mapping

-----------------------------
-- Touchpad and mouse
-----------------------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })


-----------------------------
-- Multi-monitor
-----------------------------
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ monitor = "left" }))
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ monitor = "right" }))
hl.bind("SUPER + CTRL + K", hl.dsp.focus({ monitor = "up" }))
hl.bind("SUPER + CTRL + J", hl.dsp.focus({ monitor = "down" }))

hl.bind("SUPER + CTRL + Left", hl.dsp.focus({ monitor = "left" }))
hl.bind("SUPER + CTRL + Right", hl.dsp.focus({ monitor = "right" }))
hl.bind("SUPER + CTRL + Up", hl.dsp.focus({ monitor = "up" }))
hl.bind("SUPER + CTRL + Down", hl.dsp.focus({ monitor = "down" }))

-----------------------------
-- Groups
-----------------------------
hl.bind("SUPER + ALT + G", hl.dsp.group.toggle())
hl.bind("SUPER + ALT + L", hl.dsp.group.lock({ action = "toggle" }))

hl.bind("SUPER + ALT + H", hl.dsp.window.move({ into_group = "left" }))
hl.bind("SUPER + ALT + L", hl.dsp.window.move({ into_group = "right" }))
hl.bind("SUPER + ALT + K", hl.dsp.window.move({ into_group = "up" }))
hl.bind("SUPER + ALT + J", hl.dsp.window.move({ into_group = "down" }))

hl.bind("SUPER + ALT + O", hl.dsp.window.move({ out_of_group = true }))

hl.bind("SUPER + CTRL + TAB", hl.dsp.group.next())
hl.bind("SUPER + CTRL + SHIFT + TAB", hl.dsp.group.prev())

-----------------------------
-- Media
-----------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
    {
        repeating = true,
        locked = true
    })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
    {
        repeating = true,
        locked = true
    })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
    {
        locked = true
    })
hl.bind("XF86AudioMicMute",
    hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), {
        locked = true
    })

-- Brightness do not go below 10%
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"),
    {
        repeating = true,
        locked = true
    })
hl.bind("XF86MonBrightnessDown",
    hl.dsp.exec_cmd(
        "if [ \"$(brightnessctl get)\" -gt \"$(($(brightnessctl max) / 10))\" ]; then swayosd-client --brightness lower; else swayosd-client --brightness +0; fi"),
    {
        repeating = true,
        locked = true
    })

-- Requires playerctl
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

-- Cap lock
hl.bind("Caps_Lock", hl.dsp.exec_cmd("swayosd-client --caps-lock"),
    {
        locked = true,
        release = true
    })

-----------------------------
-- Screenshot
-----------------------------
-- Active monitor
hl.bind("print", hl.dsp.exec_cmd(scripts_dir .. "/screenshot.sh screen"))

-- Active window
hl.bind("SHIFT + print", hl.dsp.exec_cmd(scripts_dir .. "/screenshot.sh window"))

-- Area
hl.bind("ALT + print", hl.dsp.exec_cmd(scripts_dir .. "/screenshot.sh area"))
--
-- Area and edit
hl.bind("CTRL + print", hl.dsp.exec_cmd(scripts_dir .. "/screenshot.sh swappy"))

-----------------------------
-- Screen recording
-----------------------------
-- Toggle active monitor replay
hl.bind("F6", hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh toggle_replay"))
hl.bind("SHIFT + F6",
    hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh toggle_replay_hdr"))

-- Save replay
hl.bind("F9", hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh save_replay"))

-- Record screen
hl.bind("F10", hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh screen"))
hl.bind("SHIFT + F10",
    hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh screen_hdr"))

-- Record window
hl.bind("SUPER + F10", hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh window"))
hl.bind("SUPER + SHIFT + F10",
    hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh window_hdr"))

-- Record area
hl.bind("SUPER + ALT + F10",
    hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh area"))
hl.bind("SHIFT + SHIFT + ALT + F10",
    hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh area_hdr"))

-- Record portal
hl.bind("SUPER + CTRL + F10",
    hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh portal"))


-- Stop manual recording and save
hl.bind("F11", hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh save_and_stop"))
hl.bind("SHIFT + F11",
    hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh save_and_stop"))

-- Stop all
hl.bind("CTRL + F11", hl.dsp.exec_cmd(scripts_dir .. "/screen_recording.sh stop_all"))

-----------------------------
-- Launch programs
-----------------------------
----- Terminal -----
hl.bind("SUPER + Return", hl.dsp.exec_raw("kitty"))

-- Menu
hl.bind("SUPER + Escape", hl.dsp.exec_raw("fuzzel"))

hl.bind("SUPER + SHIFT + Escape",
    hl.dsp.exec_raw(
        "[ \"$(hyprctl dispatch 'hl.dsp.focus({ window = \"class:launcher\" })')\" = \"ok\" ] || zsh --interactive -c \"exec kitty --class 'launcher' -- \"$HOME\"/.config/hypr/fzf_menu/_fzf-menu.sh\""
    )
)

----- Colour picker -----
hl.bind("SUPER + CTRL + P",
    hl.dsp.exec_raw('uwsm app -- sh -c "hyprpicker | tail -n1 | wl-copy"'))

----- File manager -----
hl.bind("SUPER + E",
    hl.dsp.exec_raw("zsh --interactive -c \"exec kitty -- /usr/bin/lf\""))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_raw("nautilus --new-window"))

----- System monitor -----
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_raw("gnome-system-monitor"))

----- Web browser -----
hl.bind("SUPER + W",
    hl.dsp.exec_raw(
        "[ \"$(hyprctl dispatch 'hl.dsp.focus({ window = \"class:librewolf\" })')\" = \"ok\" ] || librewolf"
    )
)

hl.bind("SUPER + SHIFT + W", hl.dsp.exec_raw("librewolf --new-window"))
hl.bind("SUPER + ALT + W", hl.dsp.exec_raw("librewolf --private-window"))

hl.bind("SUPER + CTRL + W",
    hl.dsp.exec_raw(
        "[ \"$(hyprctl dispatch 'hl.dsp.focus({ window = \"class:firefox\" })')\" = \"ok\" ] || firefox-safe"
    )
)

----- Open note book -----
hl.bind("SUPER + N",
    hl.dsp.exec_raw(
        "/usr/local/share/nvim-via-desktop -c \"cd ~/Documents/Notebook\" \"$HOME\"/Documents/Notebook/Note.md"))

----- Calculator -----
hl.bind("SUPER + C", hl.dsp.exec_raw("gnome-calculator"))

----- Calendar -----
hl.bind("SUPER + SHIFT + C",
    hl.dsp.exec_raw("/usr/local/share/khal-via-desktop"))

----- Email -----
hl.bind("SUPER + M",
    hl.dsp.exec_raw(
        "[ \"$(hyprctl dispatch 'hl.dsp.focus({ window = \"class:aerc\" })')\" = \"ok\" ] || zsh --interactive -c \"exec kitty --class 'aerc' -- aerc\""
    )
)
hl.bind("SUPER + SHIFT + M",
    hl.dsp.exec_raw("systemctl --user --no-block start mbsync.service"))

----- Virtual machine -----
-- SPICE_NOGRAB=1 disable keyboard grab. E.g., 'win' key combinations and 'alt+tab'
hl.bind("SUPER + I",
    hl.dsp.exec_raw(
        "[ \"$(hyprctl dispatch 'hl.dsp.focus({ window = \"class:virt-manager\" })')\" = \"ok\" ] || SPICE_NOGRAB=1 virt-manager --connect qemu:///session --show-domain-console windows"
    )
)

----- Keepassxc -----
hl.bind("SUPER + P",
    hl.dsp.exec_raw(
        "[ \"$(hyprctl dispatch 'hl.dsp.focus({ window = \"class:keepassxc\" })')\" = \"ok\" ] || keepassxc"
    )
)
