-- Collection of mini tools
return {
    {
        "echasnovski/mini.nvim",
        config = function()
            -- Based on builtin :mksession and :source. Use this plugin to auto save session when quit.
            require("mini.sessions").setup({
                -- Whether to read latest session if Neovim opened without file arguments
                autoread = false,

                -- Whether to write current session before quitting Neovim
                autowrite = true,

                -- Directory where global sessions are stored (use `''` to disable)
                directory = "",

                -- File for local session (use `''` to disable)
                file = ".session.vim",

                -- Whether to force possibly harmful actions (meaning depends on function)
                force = { read = false, write = true, delete = true },

                -- Hook functions for actions. Default `nil` means 'do nothing'.
                -- hooks = {
                --     -- Before successful action
                --     pre = { read = nil, write = nil, delete = nil },
                --     -- After successful action
                --     post = { read = nil, write = nil, delete = nil },
                -- },

                -- Whether to print session path after action
                -- verbose = { read = false, write = true, delete = true },
            })

            ----- Split and join arguments ---
            require("mini.splitjoin").setup()

            ----- Surround -----
            require("mini.surround").setup({
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    -- Add surrounding in Normal and Visual modes.
                    -- Do not use <Cr>, won't able to confirm in quickfix.
                    -- "S" is used by leap
                    -- "as" won't won't work as a is 'append' in normal mode
                    -- Using 'ds' and 'cs' adds delay to normal delete and change in visual mode
                    add = "<S-Cr>",      -- Add surrounding in Normal and Visual modes.
                    delete = "ds",       -- Delete surrounding
                    find = "",           -- Find surrounding (to the right)
                    find_left = "",      -- Find surrounding (to the left)
                    highlight = "",      -- Highlight surrounding
                    replace = "cs",      -- Replace surrounding
                    update_n_lines = "", -- Update `n_lines`

                    suffix_last = "",    -- Suffix to search with "prev" method
                    suffix_next = "",    -- Suffix to search with "next" method
                },
            })

            ----- Around/Inside text object -----
            -- Quotes ' " `, 'iq', 'aq'
            -- Bracket ()[]{} 'ib', 'ab'
            -- function 'af', 'if'
            -- Arguments 'aa' 'ia'
            -- tag 'at', 'it'
            -- New objects '*' '<Space>' '_' '?'(different char for left and right)
            -- Next/Last variant 'an', 'in', 'al', 'il'
            -- Go to edge 'g[', 'g]'
            require("mini.ai").setup()

            ----- Align -----
            -- Align text, select, then ga/gA.
            -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-align.md
            require("mini.align").setup({
                mappings = {
                    start = "<leader>el",
                    start_with_preview = "<leader>eL",
                },
            })
        end,

        keys = {
            -- Keymap set by mini.surround
            {
                "<S-Cr>",
                desc = "Add surround",
                mode = { "n", "x" }
            },
            {
                "ds",
                desc = "Delete surround",
                mode = { "n", "x" }
            },
            {
                "cs",
                desc = "Change surround",
                mode = { "n", "x" }
            },

            -- Keymap for sessions
            {
                "<leader>eSd",
                function()
                    require("mini.sessions").delete(".session.vim", {})
                end,
                desc = "Delete session",
                mode = { "n", "x" }
            },
            {
                "<leader>eSr",
                function()
                    require("mini.sessions").read(".session.vim", {})
                end,
                desc = "Read session",
                mode = { "n", "x" }
            },
            {
                "<leader>eSw",
                function()
                    require("mini.sessions").write(".session.vim", {})
                end,
                desc = "Write session",
                mode = { "n", "x" }
            },

            -- Keymap for splitjoin
            {
                "<leader>ej",
                function() require("mini.splitjoin").toggle() end,
                desc = "Split/Join param",
                mode = { "n", "x" }
            },

            -- Keymap for around/inside
            {
                "a",
                mode = { "o", "x" }
            },
            {
                "i",
                mode = { "o", "x" }
            },

            -- Keymap for align
            {
                "<leader>el",
                desc = "Align",
                mode = { "n", "x" }
            },
            {
                "<leader>eL",
                desc = "Align with preview",
                mode = { "n", "x" }
            },
        }
    }
}
