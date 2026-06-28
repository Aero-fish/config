-----------------------------
-- Environment variables
-----------------------------
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.env("SDL_VIDEO_DRIVER", "wayland,x11")

-- hl.env("XMODIFIERS=@im", "fcitx") -- Crash steam
-- hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx") -- Use fcitx im module instead of text-input-v2 (not up streamed) for QT4/5

hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

hl.env("PYTHONSTARTUP", os.getenv("HOME") .. "/.config/pythonrc")

hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "48")

-----------------------------
-- Monitors
-----------------------------
hl.monitor({
    output            = "desc:ASUSTek COMPUTER INC PG32UCDM S3LMQS068423",
    mode              = "highres",
    bitdepth          = 10,
    supports_wide_color = 1,
    min_luminance     = 0,
    max_luminance     = 1000,
    max_avg_luminance = 250,
})

hl.monitor({
    output = "desc:Chimei Innolux Corporation 0x13B0",
    mode   = "highres",
    vrr    = 0,
    scale  = 1
})

hl.monitor({
    output   = "",
    mode     = "highres",
    position = "auto",
    scale    = "auto",
})


-----------------------------
-- Look and feel
-----------------------------
hl.config({
    general = {
        border_size = 4,
        gaps_in = 8,
        gaps_out = 16,
        col = {
            active_border = "#f7c9c9",
            inactive_border = "#80808000",
        },
        layout = "dwindle",
        resize_on_border = false,
    },
    decoration = {
        shadow = { range = 16 },

        blur   = { enabled = false },
    },
    animations = {
        enabled = false,
    },

})


-----------------------------
-- Settings
-----------------------------
hl.config({
    input = {
        accel_profile = "flat",
        -- mouse_refocus = false,
        touchpad      = {
            natural_scroll = true,
        },
    },
    group = {
        col = {
            border_active = "#bdd3e1",
            border_locked_active = "#9b1c31",
            border_inactive = "#80808000",
            border_locked_inactive = "#80808000"
        },
        groupbar = {
            font_size = 24,
            indicator_height = 6,
            col = {
                active = "#bdd3e1",
                locked_active = "#9b1c31",
                inactive = "#80808000",
                locked_inactive = "#80808000"

            }
        }
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        font_family = "Maple Mono NF CN",
        vrr = 2, -- 0 - off, 1 - on, 2 - fullscreen only, 3 - fullscreen with video or game content type
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        middle_click_paste = false


    },
    cursor = {
        inactive_timeout = 0,
        no_warps = true, -- Do not move the cursor when changing focus using keyboard
        hide_on_key_press = false,
        hide_on_touch = false,
        no_break_fs_vrr = 1 -- 0 - off, 1 - on, 2 - auto (on with content type 'game')
    },
    ecosystem = {
        no_update_news=true,
        no_donation_nag = true,
        enforce_permissions = true,
    },

    -- Layout
    dwindle = {
        force_split = 2
    },
})

-----------------------------
-- Per device settings
-----------------------------

hl.device({
    name = "syna2ba6:00-06cb:cd3e-touchpad",
    accel_profile = "adaptive",
})

-----------------------------
-- Source other config
-----------------------------

require("hyprland-autostart")
require("hyprland-keymap")
require("hyprland-permission")
require("hyprland-window-rules")
