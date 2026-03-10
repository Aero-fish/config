return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost" }, -- Has GUI elements. Load with delay at start up.
        cmd = { "Gitsigns" },
        opts = {
            signs = {
                add          = { text = "│" },
                change       = { text = "│" },
                delete       = { text = "_" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~" },
                untracked    = { text = "┆" },
            },
            preview_config = {
                -- Options passed to nvim_open_win
                -- https://neovim.io/doc/user/api.html#nvim_open_win()
                border = FLOAT_WINDOW_BORDER_STYLE,
                -- focusable = false,
            },
        },
        keys = {
            {
                "[h",
                function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() require("gitsigns").prev_hunk() end)
                    return "<Ignore>"
                end,
                desc = "Prev git hunk",
                mode = { "n", "x" }
            },
            {
                "]h",
                function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() require("gitsigns").next_hunk() end)
                    return "<Ignore>"
                end,
                desc = "Next git hunk",
                mode = { "n", "x" }
            },

            -- <leader>g = Git+
            {
                "<leader>gb",
                function() require("gitsigns").blame_line { full = true } end,
                desc = "Blame in pop-up",
                mode = { "n", "x" }
            },
            {
                "<leader>gd",
                function() require("gitsigns").diffthis() end,
                desc = "Diff with index",
                mode = { "n", "x" }
            },
            {
                "<leader>gD",
                function() require("gitsigns").diffthis("~") end,
                desc = "Diff with HEAD",
                mode = { "n", "x" }
            },
            {
                "<leader>gh",
                ":<C-u> Gitsigns select_hunk <Cr>",
                desc = "Select hunk",
                mode = { "n", "x" }
            },
            {
                "<leader>gp",
                function() require("gitsigns").preview_hunk() end,
                desc = "Preview hunk",
                mode = { "n", "x" }
            },
            {
                "<leader>gr",
                function() require("gitsigns").reset_hunk() end,
                desc = "Resent hunk",
                mode = "n"
            },
            {
                "<leader>gr",
                function() require("gitsigns").reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                desc = "Resent hunk",
                mode = "x"
            },
            {
                "<leader>gR",
                function() require("gitsigns").reset_buffer() end,
                desc = "Reset buffer",
                mode = { "n", "x" }
            },
            {
                "<leader>gs",
                function() require("gitsigns").stage_hunk() end,
                desc = "Stage hunk",
                mode = "n"
            },
            {
                "<leader>gs",
                function() require("gitsigns").stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                desc = "Stage hunk",
                mode = "x"
            },
            {
                "<leader>gS",
                function() require("gitsigns").stage_buffer() end,
                desc = "Stage buffer",
                mode = { "n", "x" }
            },
            {
                "<leader>gu",
                function() require("gitsigns").undo_stage_hunk() end,
                desc = "Undo stage hunk",
                mode = { "n", "x" }
            },

            -- Show
            {
                "<leader>sb",
                function() require("gitsigns").blame_line { full = true } end,
                desc = "Git blame",
                mode = { "n", "x" }
            },

            -- Toggle
            {
                "<leader>tb",
                function() require("gitsigns").toggle_current_line_blame() end,
                desc = "Git blame",
                mode = { "n", "x" }
            },
            {
                "<leader>td",
                function() require("gitsigns").toggle_deleted() end,
                desc = "Git deleted lines",
                mode = { "n", "x" }
            },

            -- Text object (Not work)
            -- {
            --     "ih",
            --     ":<C-U>Gitsigns select_hunk<CR>",
            --     mode = { "o", "x" },
            --     remap=true
            -- },
        }
    }
}
