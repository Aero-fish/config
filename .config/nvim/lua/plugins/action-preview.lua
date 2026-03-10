return {
    {
        "aznhe21/actions-preview.nvim",
        opts = {
            -- options for vim.diff(): https://neovim.io/doc/user/lua.html#vim.diff()
            -- diff = {
            --     ctxlen = 3,
            -- },

            -- priority list of external command to highlight diff
            -- disabled by default, must be set by yourself
            -- highlight_command = {
            -- require("actions-preview.highlight").delta(),
            -- require("actions-preview.highlight").diff_so_fancy(),
            -- require("actions-preview.highlight").diff_highlight(),
            -- },

            -- priority list of preferred backend
            backend = { "telescope", "nui" },
        },
        keys = {
            {
                "<leader>a",
                function() require("actions-preview").code_actions() end,
                mode = "n",
                desc = "Code action"
            }
        }
    },
}
