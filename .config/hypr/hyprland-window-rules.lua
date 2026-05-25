-- "Smart gaps" / "No gaps when only"
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name        = "no-gaps-wtv1",
    match       = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name        = "no-gaps-f1",
    match       = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})


hl.window_rule({
    name = "No border for float",
    match = { float = 1 },
    border_size = 0
})


hl.window_rule({
    name = "Window property inspection",
    match = { class = "prop" },
    float = true,
    center = true,
    size = "(monitor_w*0.4) (monitor_h*0.5)"
})

hl.window_rule({
    name = "Black out sensitive programs",
    match = { class = "(KeePassXCC|firefox)" },
    no_screen_share = true,
})

hl.window_rule({
    name = "Auto size librewolf popup",
    match = {
        class = "librewolf",
        title = "Picture-in-Picture"
    },
    float = true,
    max_size = { "monitor_w*0.25", "monitor_h*0.25" },
    move = { "monitor_w - window_w", "monitor_h - window_h - 40" },
    pin = true,
    keep_aspect_ratio = true
})

hl.window_rule({
    name = "Nautilus Previewer",
    match = { class = "org.gnome.NautilusPreviewer" },
    float = true,
    no_initial_focus = true,
    center = true,
})

hl.window_rule({
    name = "KeepassXC pop up",
    match = { class = "KeePassXC", float = true },
    center = true,
})

hl.window_rule({
    name = "Floating window type 1",
    match = { class = "^(SVPManager|org.gnome.Calculator|org.fcitx.fcitx5-config-qt)$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "Floating window type 2",
    match = { class = "org.gnome.SystemMonitor" },
    float = true,
    center = true,
    pin = true,
    size = { "monitor_w*0.5", "monitor_h*0.6" },
})

hl.window_rule({
    name = "Floating window type 3",
    match = {
        class =
        "^(system-config-printer|launcher|org.pulseaudio.pavucontrol|blueman-manager)$"
    },
    float = true,
    center = true,
    pin = true,
    size = { "monitor_w*0.4", "monitor_h*0.5" },
})

hl.window_rule({
    name = "Suppress maximize event",
    match = { class = ".*" },
    suppress_event = "maximize"
})
