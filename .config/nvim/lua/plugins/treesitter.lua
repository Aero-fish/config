----- Auto start treesitter -----
local has_treesitter, treesitter = pcall(require, "nvim-treesitter")
if has_treesitter then
    -- local installed_parser = treesitter.get_installed()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
            local ok = pcall(vim.treesitter.start)
            if ok then
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end
        end,
    })
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = function()
            require("nvim-treesitter").install({ "unstable" })
            require("nvim-treesitter").update()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        cmd = { "TSContext" },
        opts = {
            enable = true,           -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 0,           -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 20,  -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 5, -- Maximum number of lines to show for a single context
            trim_scope = "outer",    -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = "cursor",         -- Line used to calculate context. Choices: 'cursor', 'topline'
            -- Separator between context and content. Should be a single character string, like '-'.
            -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
            separator = nil,
            zindex = 20,     -- The Z-index of the context window
            on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        },
        keys = {
            {
                "<leader>tC",
                function()
                    require("treesitter-context").toggle()
                end,
                desc = "Context",
                mode = "n"
            },
            {
                "[C",
                function()
                    require("treesitter-context").go_to_context(vim.v.count1)
                end,
                desc = "Context up",
                mode = { "n", "v" },
            },
        },
    },
}
