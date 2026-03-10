-- Window bar
return {
    {
        "Bekaboo/dropbar.nvim",
        event = "BufRead",
        opts = function()
            local utils = require("dropbar.utils")
            return {
                icons = {
                    symbols = {
                        Array = " ",
                        Boolean = " ",
                        BreakStatement = "󰙧 ",
                        Call = "󰃷 ",
                        CaseStatement = "󱃙 ",
                        Class = " ",
                        Color = " ",
                        Constant = " ",
                        Constructor = " ",
                        ContinueStatement = "→ ",
                        Copilot = " ",
                        Declaration = "󰙠 ",
                        Delete = "󰩺 ",
                        DoStatement = "󰑖 ",
                        Enum = " ",
                        EnumMember = " ",
                        Event = " ",
                        Field = " ",
                        File = " ",
                        Folder = " ",
                        ForStatement = "󰑖 ",
                        Function = "󰊕 ",
                        H1Marker = "󰉫 ", -- Used by markdown treesitter parser
                        H2Marker = "󰉬 ",
                        H3Marker = "󰉭 ",
                        H4Marker = "󰉮 ",
                        H5Marker = "󰉯 ",
                        H6Marker = "󰉰 ",
                        Identifier = "  ",
                        IfStatement = "󰇉 ",
                        Interface = " ",
                        Keyword = " ",
                        List = "󰅪 ",
                        Log = "󰦪 ",
                        Lsp = " ",
                        Macro = "󰁌 ",
                        MarkdownH1 = "󰉫 ", -- Used by builtin markdown source
                        MarkdownH2 = "󰉬 ",
                        MarkdownH3 = "󰉭 ",
                        MarkdownH4 = "󰉮 ",
                        MarkdownH5 = "󰉯 ",
                        MarkdownH6 = "󰉰 ",
                        Method = "󰆧 ",
                        Module = "󰏗 ",
                        Namespace = "󰅩 ",
                        Null = "󰢤 ",
                        Number = "󰎠 ",
                        Object = "󰅩 ",
                        Operator = " ",
                        Package = "󰏗 ",
                        Pair = "󰅪 ",
                        Property = " ",
                        Reference = "󰦾 ",
                        Regex = " ",
                        Repeat = "󰑖 ",
                        Scope = "󰅩 ",
                        Snippet = "󰩫 ",
                        Specifier = "󰦪 ",
                        Statement = "󰅩 ",
                        String = " ",
                        Struct = " ",
                        SwitchStatement = "󰺟 ",
                        Terminal = " ",
                        Text = "󰉿 ",
                        Type = " ",
                        TypeParameter = " ",
                        Unit = " ",
                        Value = "󰎠 ",
                        Variable = " ",
                        WhileStatement = "󰑖 ",
                    },
                },
                menu = {
                    win_configs = { border = "single" },
                    keymaps = {
                        ["<CR>"] = function() -- Click on item name
                            local menu = utils.menu.get_current()
                            if not menu then
                                return
                            end
                            local cursor = vim.api.nvim_win_get_cursor(menu.win)
                            -- Assume cursor is at the item name
                            cursor[2] = 6
                            local component = menu.entries[cursor[1]]:first_clickable(
                                cursor[2])
                            if component then
                                menu:click_on(component, nil, 1, "l")
                            end
                        end,
                        ["l"] = function() -- Click on expand icon
                            local menu = utils.menu.get_current()
                            if not menu then
                                return
                            end
                            local cursor = vim.api.nvim_win_get_cursor(menu.win)
                            -- Assume cursor is at beginning (i.e., expand icon or an spaces)
                            cursor[2] = 0
                            local component = menu.entries[cursor[1]]:first_clickable(
                                cursor[2])
                            if component then
                                menu:click_on(component, nil, 1, "l")
                            end
                        end,
                        ["h"] = "<C-w>q"
                        -- ['i'] -- Fuzzy find
                    },
                },
            }
        end,
        config = function(_, opts)
            require("dropbar").setup(opts)
            vim.ui.select = require("dropbar.utils.menu").select
        end,
        keys = {
            {
                "<leader>J",
                function() require("dropbar.api").pick() end,
                mode = "n",
                desc = "Pick symbols in winbar"
            },
            -- {
            --     "[b",
            --     dropbar_api.goto_context_start,
            --     mode = "n",
            --     desc = "Start of context"
            -- },
            -- {
            --     "]b",
            --     dropbar_api.select_next_context,
            --     mode = "n",
            --     desc = "Select next context"
            -- },
        }
    }
}
