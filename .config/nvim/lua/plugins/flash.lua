return {
    {
        "folke/flash.nvim",
        opts = {
            modes = {
                char = {
                    jump_labels = true
                }
            }
        },
        keys = {
            {
                "s",
                mode = { "n", "x" },
                function() require("flash").jump() end,
                desc = "Flash"
            },
            {
                "S",
                mode = { "n", "x" },
                function()
                    require("flash").jump({
                        search = { mode = "search", max_length = 0 },
                        label = { after = { 0, 0 } },
                        pattern = "^"
                    })
                end,
                desc = "Flash"
            },
            {
                -- Flash Treesitter
                "ic",
                mode = { "x", "o" },
                function() require("flash").treesitter() end,
                desc = "in Context"
            },
            {
                -- Flash Treesitter
                "ac",
                mode = { "x", "o" },
                function() require("flash").treesitter() end,
                desc = "in Context"
            },
            {
                -- Flash Treesitter
                "<CR>",
                mode = { "n", "x" },
                function()
                    require("flash").treesitter()
                end,
                desc = "Select in Context"
            },
            {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc = "Remote Flash"
            },
            {
                "R",
                mode = { "o", "x" },
                function() require("flash").treesitter_search() end,
                desc = "Treesitter Search"
            },
            {
                "<c-s>",
                mode = { "c" },
                function() require("flash").toggle() end,
                desc = "Toggle Flash Search"
            },
            { "f", mode = { "n", "x", "o" }, },
            { "F", mode = { "n", "x", "o" }, },
            { "t", mode = { "n", "x", "o" }, },
            { "T", mode = { "n", "x", "o" }, },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        optional = true,
        opts = function(_, opts)
            local function flash(prompt_bufnr)
                require("flash").jump({
                    pattern = "^",
                    label = { after = { 0, 0 } },
                    search = {
                        mode = "search",
                        exclude = {
                            function(win)
                                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~=
                                    "TelescopeResults"
                            end,
                        },
                    },
                    action = function(match)
                        local picker = require("telescope.actions.state")
                            .get_current_picker(prompt_bufnr)
                        picker:set_selection(match.pos[1] - 1)
                    end,
                })
            end
            opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
                mappings = {
                    n = { s = flash },
                    i = { ["<c-s>"] = flash },
                },
            })
        end,
    }
}
