--    s{char}<space> to jump to the end of a line.
--    s<space><space> to jump to any EOL position, including empty lines.
--    s{char}<enter> to jump to the first {char}{?} pair right away.
--    s<enter> to repeat the last search.
--    s<enter><enter>... or s{char}<enter><enter>... to traverse through the matches.

-- leap.add_default_mappings()
return {
    {
        "ggandor/leap.nvim",
        keys = {
            --- Bi-directional search -----
            -- {
            --     "s",
            --     function()
            --         local current_window = vim.fn.win_getid()
            --         leap.leap { target_windows = { current_window } }
            --         -- require("leap").leap { target_windows = require('leap.user').get_focusable_windows() }
            --     end,
            --     desc = "Leap search",
            --     mode = { "n", "x" }
            -- },

            ----- One directional search -----
            {
                "s",
                function()
                    require("leap").leap({})
                end,
                desc = "Leap search forward",
                mode = { "n", "x" }
            },
            {
                "S",
                function()
                    require("leap").leap({ backward = true })
                end,
                desc = "Leap search backward",
                mode = { "n", "x" }
            },

        }
    },
    {
        "ggandor/flit.nvim",                                        -- leap to for 'f', 'F', 't', 'T'.
        dependencies = { "ggandor/leap.nvim", "tpope/vim-repeat" }, -- vim-repeat allow '.' operation.
        opts = {
            keys = { f = "f", F = "F", t = "t", T = "T" },
            -- A string like "nv", "nvo", "o", etc.
            labeled_modes = "nvo",
            -- Repeat with the trigger key itself.
            clever_repeat = true,
            multiline = true,
            -- Like `leap`s similar argument (call-specific overrides).
            -- E.g.: opts = { equivalence_classes = {} }
            opts = {}
        },
        keys = {
            { "f", mode = { "n", "v", "o" } },
            { "F", mode = { "n", "v", "o" } },
            { "t", mode = { "n", "v", "o" } },
            { "T", mode = { "n", "v", "o" } },
        }
    },
}
