return {
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod" },
            {
                "kristijanhusak/vim-dadbod-completion",
                ft = { "sql", "mysql", "plsql" },
                lazy = true
            },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            -- Your DBUI configuration
            vim.g.db_ui_use_nerd_fonts = 1
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        optional = true,
        opts = function(_, opts)
            if opts ~= nil then
                table.insert(opts.sources, { name = "vim-dadbod-completion" })
            else
                opts["sources"] = { { name = "vim-dadbod-completion" } }
            end
            return opts
        end,
    }
}
