local trouble_open = function(bufnr) require("trouble.sources.telescope").open(bufnr) end
local trouble_add = function(bufnr) require("trouble.sources.telescope").add(bufnr) end

return {
    {
        "folke/trouble.nvim",
        opts = {
            -- auto_preview = false,
            focus = true, -- Focus the window when opened
            keys = {
                ["?"] = "help",
                r = "refresh",
                R = "toggle_refresh",
                q = "close",
                ["<S-Cr>"] = "jump_close",
                ["<Esc>"] = "cancel",
                ["<Cr>"] = "jump",
                ["<2-leftmouse>"] = "jump",
                ["<C-s>"] = "jump_split",
                ["<C-v>"] = "jump_vsplit",
                -- go down to next item (accepts count)
                -- j = "next",
                ["}"] = "next",
                ["]]"] = "next",
                -- go up to prev item (accepts count)
                -- k = "prev",
                ["{"] = "prev",
                ["[["] = "prev",
                dd = "delete",
                d = { action = "delete", mode = "v" },
                i = "inspect",
                o = "preview",
                p = "preview",
                P = "toggle_preview",
                zo = "fold_open",
                l = "fold_open",
                zO = "fold_open_recursive",
                h = "fold_close",
                zc = "fold_close",
                zC = "fold_close_recursive",
                za = "fold_toggle",
                zA = "fold_toggle_recursive",
                zm = "fold_more",
                zM = "fold_close_all",
                zr = "fold_reduce",
                zR = "fold_open_all",
                zx = "fold_update",
                zX = "fold_update_all",
                zn = "fold_disable",
                zN = "fold_enable",
                zi = "fold_toggle_enable",
                gb = { -- example of a custom action that toggles the active view filter
                    action = function(view)
                        view:filter({ buf = 0 }, { toggle = true })
                    end,
                    desc = "Toggle Current Buffer Filter",
                },
                s = { -- example of a custom action that toggles the severity
                    action = function(view)
                        local f = view:get_filter("severity")
                        local severity = ((f and f.filter.severity or 0) + 1) % 5
                        view:filter({ severity = severity }, {
                            id = "severity",
                            template = "{hl:Title}Filter:{hl} {severity}",
                            del = severity == 0,
                        })
                    end,
                    desc = "Toggle Severity Filter",
                },
                S = {
                    action = function(view)
                        view:filter(
                            { ["not"] = { ["item.source"] = "cSpell" } },
                            { toggle = true }
                        )
                    end,
                    desc = "Toggle Cspell diagnostic",
                },
            },
        },
        keys = {
            {
                "[l",
                function()
                    require("trouble").prev({
                        skip_groups = true,
                        jump = true
                    })
                end,
                desc = "Prev item in list",
                mode = { "n", "x" }
            },
            {
                "]l",
                function()
                    require("trouble").next({
                        skip_groups = true,
                        jump = true
                    })
                end,
                desc = "Next item in list",
                mode = { "n", "x" }
            },

            {
                "gd",
                function() require("trouble").toggle("lsp_definitions") end,
                desc = "Go to definition",
                mode = { "n", "x" }
            },
            {
                "gi",
                function() require("trouble").toggle("lsp_implementations") end,
                desc = "Go to implementation",
                mode = { "n", "x" }
            },
            {
                "gt",
                function() require("trouble").toggle("lsp_type_definitions") end,
                desc = "Go to type definition",
                mode = { "n", "x" }
            },

            {
                "<leader>lc",
                function() require("trouble").toggle("lsp_command") end,
                desc = "Commands",
                mode = { "n", "x" }
            },
            {
                "<leader>ld",
                function() require("trouble").toggle("lsp_definitions") end,
                desc = "Definitions",
                mode = { "n", "x" }
            },
            {
                "<leader>li",
                function() require("trouble").toggle("lsp_implementations") end,
                desc = "Implementations",
                mode = { "n", "x" }
            },
            {
                "<leader>lI",
                function() require("trouble").toggle("lsp_incoming_calls") end,
                desc = "Incoming calls",
                mode = { "n", "x" }
            },
            {
                "<leader>lO",
                function() require("trouble").toggle("lsp_outgoing_calls") end,
                desc = "Outgoing calls",
                mode = { "n", "x" }
            },
            {
                "<leader>lR",
                function() require("trouble").toggle("lsp_references") end,
                desc = "References",
                mode = { "n", "x" }
            },
            {
                "<leader>lt",
                function() require("trouble").toggle("lsp_type_definitions") end,
                desc = "Type definition",
                mode = { "n", "x" }
            },

            --  Not work with markdown without LSP.
            -- Use 'outline', more info and nicer tree
            -- {
            --     "<leader>o",
            --     function() require("trouble").toggle("symbols") end,
            --     desc = "Toggle outline",
            --     mode = { "n", "x" }
            -- },

            {
                "<leader>sd",
                function()
                    require("trouble").toggle({
                        mode = "diagnostics",
                        filter = {
                            buf = 0
                        }
                    })
                end,
                desc = "Document diagnostic",
                mode = { "n", "x" }
            },
            {
                "<leader>sD",
                function()
                    require("trouble").toggle({
                        mode = "diagnostics",
                        ---- Preview in a float
                        -- preview = {
                        --     type = "float",
                        --     relative = "editor",
                        --     border = "rounded",
                        --     title = "Preview",
                        --     title_pos = "center",
                        --     position = { 0, -2 },
                        --     size = { width = 0.3, height = 0.3 },
                        --     zindex = 200,
                        -- },

                        ---- Preview in a split
                        -- preview = {
                        --     type = "split",
                        --     relative = "win",
                        --     position = "right",
                        --     size = 0.3,
                        -- },
                    })
                end,

                desc = "Workspace diagnostic",
                mode = { "n", "x" }
            },
            {
                "<leader>sl",
                function() require("trouble").toggle("loclist") end,
                desc = "Location list",
                mode = { "n", "x" }
            },
            {
                "<leader>sq",
                function() require("trouble").toggle("quickfix") end,
                desc = "Quickfix",
                mode = { "n", "x" }
            },
            {
                "<leader>sR",
                function() require("trouble").toggle("lsp_references") end,
                desc = "References",
                mode = { "n", "x" }
            },
            {
                "<leader>sT",
                function() require("trouble.sources.telescope").open() end,
                desc = "Telescope results",
                mode = { "n", "x" }
            },

            {
                "<leader><leader>q",
                function()
                    local panel_names = {
                        "diagnostics",
                        "fzf",
                        "fzf_files",
                        "loclist",
                        "lsp",
                        "lsp_command",
                        "lsp_declarations",
                        "lsp_definitions",
                        "lsp_document_symbols",
                        "lsp_implementations",
                        "lsp_incoming_calls",
                        "lsp_outgoing_calls",
                        "lsp_references",
                        "lsp_type_definitions",
                        "quickfix",
                        "symbols",
                    }
                    for _, name in ipairs(panel_names) do
                        if require("trouble").is_open(name) then
                            require("trouble").close(name)
                        end
                    end
                end,
                desc = "Close all 'trouble' panels",
                mode = { "n", "x" }
            },
        }
    },
    {
        "nvim-telescope/telescope.nvim",
        optional = true,
        opts = function(_, opts)
            local opts_override = {
                defaults = {
                    mappings = {
                        i = {
                            ["<C-w>"] = trouble_open,
                            ["<C-S-w>"] = trouble_add
                        }
                    }
                }
            }
            return vim.tbl_deep_extend("force", opts, opts_override)
        end
    },
    {
        "folke/todo-comments.nvim",
        optional = true,
        dependencies = { "folke/trouble.nvim" },
        keys = {
            {
                "<leader>st",
                "<CMD> Trouble todo <CR>",
                desc = "Todo tags",
                mode = { "n", "x" }
            }
        }
    },
}
