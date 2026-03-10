-- -- Do not set theme for TTY
if os.getenv("TERM") == "linux" then
    return {}
end

return {
    {
        "rmehri01/onenord.nvim",
        lazy = false,
        priority = 1000,
        opts = function()
            local colours = require("onenord.colors").load()
            return {
                theme = "light",     -- "dark" or "light".
                borders = false,     -- Split window borders
                -- fade_nc = true, -- Fade/dim non-current windows, making them more distinguishable
                -- Style that is applied to various groups: see `highlight-args` for options
                -- *bold* *underline* *undercurl* *inverse* *italic* *standout*
                styles = {
                    comments = "italic",
                    strings = "NONE",
                    keywords = "NONE",
                    functions = "italic",
                    variables = "NONE",
                    diagnostics = "undercurl",
                },
                custom_highlights = {
                    WinSeparator = { fg = "#268bd2" },

                    MiniIndentscopePrefix = { bg = "#00ff00" },
                    MiniIndentscopeSymbol = { fg = "#0000ff" },

                    -- Popup window
                    NormalFloat = { bg = colours.none },     -- content
                    FloatBorder = { bg = colours.none },     -- border

                    YankHighlight = { fg = "#586e75", bg = colours.yellow },
                    -- CursorLine = { bg = "#eee8d5" },

                    SpellBad = {
                        fg = colours.none,
                        bg = colours.none,
                        style = "undercurl",
                        sp = colours.none
                    },
                    SpellCap = {
                        fg = colours.none,
                        bg = colours.none,
                        style = "undercurl",
                        sp = colours.none
                    },
                    SpellLocal = {
                        fg = colours.none,
                        bg = colours.none,
                        style = "undercurl",
                        sp = colours.none
                    },
                    SpellRare = {
                        fg = colours.none,
                        bg = colours.none,
                        style = "undercurl",
                        sp = colours.none
                    },
                    -- IncSearch = { fg = colors.dark_pink },
                    illuminatedWord = { bg = colours.none, style = "underline" },
                    illuminatedCurWord = { bg = colours.none, style = "underline" },
                    PmenuSel = { bg = "#e8dab6" },     -- Pop-up menu selection highlight

                    -- StatusLine = { bg = "#fdf6e3" }, -- Using lualine, hide for nvim-tree
                    -- NvimTreeNormal = { bg = "#fefaee" },
                    NvimTreeNormal = { bg = "#fdf6e3" },
                    -- NvimTreeVertSplit = { fg = "#000000", bg = colors.none },
                    -- NvimTreeOpenedFolderName = { fg = colors.blue },

                    LspReferenceText = { style = "underline", sp = "#073642" },     -- variable used in string, E.g., "$HOME" for bash
                    LspReferenceRead = { style = "underline", sp = "#073642" },
                    LspReferenceWrite = { style = "underline", sp = "#cb4b16" },

                    MDCodeBlock = { bg = "#fcf0cf" },

                    CybuFocus = { bg = "#eee8d5" },

                    -- blink
                    BlinkCmpDocBorder = { fg = "#8da5d2" },
                    BlinkCmpSignatureHelpBorder = { fg = "#8da5d2" },
                    BlinkCmpMenuBorder = { fg = "#8da5d2" },
                    BlinkCmpSignatureHelpActiveParameter = { bg = "#c7d1eb" },

                    -- Csvview, don't use colour to separate col, use border '|'.
                    -- CsvViewCol0 = { fg = "#E6194B" },
                    -- CsvViewCol1 = { fg = "#3CB44B" },
                    -- CsvViewCol2 = { fg = "#FFE119" },
                    -- CsvViewCol3 = { fg = "#0082C8" },
                    -- CsvViewCol4 = { fg = "#FABEBE" },
                    -- CsvViewCol5 = { fg = "#46F0F0" },
                    -- CsvViewCol6 = { fg = "#F032E6" },
                    -- CsvViewCol7 = { fg = "#008080" },
                    -- CsvViewCol8 = { fg = "#F58231" },
                },

                custom_colors = {
                    fg = "#586e75",
                    fg_light = "#657b83",
                    bg = "#fdf6e3",
                    active = "#eee8d5",
                    highlight = "#dfdac7",
                    highlight_dark = "d0ccb9",
                    float = "#eee8d5",
                    -- gray = "#839496",
                    -- light_gray = "#93a1a1",
                    -- selection = "#e8dab6",
                    WinSeparator = ""
                },
            }
        end,
    },
}
