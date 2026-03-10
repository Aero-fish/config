return {
    {
        "Aero-fish/lf.nvim",
        opts = {
            default_action = "drop", -- default action when `Lf` opens a file
            mappings = true,         -- whether terminal buffer mapping is enabled
            default_actions = {      -- default action keybindings
                ["<C-t>"] = "tabedit",
                ["<C-s>"] = "split",
                ["<C-b>"] = "vsplit",
                ["<C-o>"] = "tab drop",
            },
            direction = "float", -- window type: float horizontal vertical
            escape_quit = true,
            border = "rounded",
            layout_mapping = "<M-u>", -- resize window with this key
            dir = "",                 --'gwd' is git-working-directory, ""/nil is CWD
            -- height = vim.fn.float2nr(vim.fn.round(0.8 * vim.o.lines)),  -- height of the *floating* window
            -- width = vim.fn.float2nr(vim.fn.round(0.8 * vim.o.columns)), -- width of the *floating* window

            default_file_manager = true, -- make lf default file manager
        },
        keys = {
            {
                "<leader>j",
                function()
                    require("lf").start(vim.fn.getcwd())
                end,
                desc = "Open cwd in lf",
                mode = { "n", "x" }
            },
            {
                "<leader><leader>j",
                function()
                    require("lf").start()
                end,
                desc = "Open cur file in lf",
                mode = { "n", "x" }
            }
        }
    },
    -- Dependency
    -- "akinsho/toggleterm.nvim",
}
