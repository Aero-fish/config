return {
    {
        "hrsh7th/nvim-cmp", -- The completion plugin
        -- enabled = false,
        event = "InsertEnter",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",                 -- cmdline completions
            "hrsh7th/cmp-calc",                    -- evaluating mathematical expressions
            "hrsh7th/cmp-nvim-lsp-signature-help", -- Functions signature hint
            {
                -- Find word in dictionary
                "uga-rosa/cmp-dictionary",
                opts = function()
                    local dict = {
                        ["*"] = {
                            os.getenv("HOME") ..
                            "/.config/my-config/wordlist/words_large.txt"
                        },
                        -- ["latex"] = { "/path/to/foo.dict" },
                    }

                    -- vim.api.nvim_create_autocmd("FileType", {
                    --     group = vim.api.nvim_create_augroup("cmp", { clear = true }),
                    --     pattern = "*",
                    --     callback = function(ev)
                    --         local paths = dict[ev.match] or dict["*"]
                    --         cmp_dictionary.setup({
                    --             paths = paths,
                    --         })
                    --     end
                    -- })
                    return {
                        paths = dict["*"],
                        first_case_insensitive = true,
                        exact_length = 2,
                        -- max_number_items = 10, -- Bug, inocmplete result.

                        -- If enabled, activate document using external command.
                        -- document = {
                        --     enable = true,
                        --     command = { "wn", "${label}", "-over" }, -- WordNet lexical database
                        -- },
                    }
                end,
                config = function(_, opts)
                    require("cmp_dictionary").setup(opts)
                end
            },
        },
        opts_extend = { "sources" },
        opts = function(_, opts)
            local kind_icons = {
                Class = "",
                Color = "",
                Constant = "",
                Constructor = "",
                Enum = "",
                EnumMember = "",
                Event = "",
                Field = "",
                File = "",
                Folder = "",
                Function = "󰊕",
                Interface = "",
                Keyword = "",
                Method = "󰊕",
                -- Module = "󰏗",
                Module = "",
                Operator = "",
                Property = "",
                Reference = "󰦾",
                Snippet = "󰩫",
                Struct = "",
                Text = "󰉿",
                TypeParameter = "",
                Unit = "",
                Value = "󰎠",
                Variable = "",
            }
            local cmp = require("cmp")
            local default_opts = {
                completion = { completeopt = "menuone,noinsert" },
                mapping = {
                    ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i" }),
                    ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i" }),

                    ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i" }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i" }),
                    ["<C-Space>"] = cmp.mapping(
                        function()
                            if cmp.visible() then
                                cmp.close()
                            else
                                cmp.complete()
                            end
                        end,
                        { "i", "c" }
                    ),
                    ["<C-y>"] = cmp.config.disable,
                    ["<C-e>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c", "s" }),
                    ["<Tab>"] = cmp.mapping(
                        function(fallback)
                            if cmp.visible() then
                                cmp.confirm({ select = true })
                            elseif require("luasnip").expandable() then
                                require("luasnip").expand()
                            elseif require("luasnip").expand_or_jumpable() then
                                require("luasnip").expand_or_jump()
                            else
                                fallback()
                            end
                        end,
                        { "i" }
                    ),
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        -- Convert kind (str) into icons (1st col of the pop up)
                        vim_item.kind = string.format("%s",
                            kind_icons[vim_item.kind] or "? ")
                        -- vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "? ",
                        --     vim_item.kind) -- This concatenates the icons with the name of the item kind

                        -- Trim the length of text (2nd col of the pop up)
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 50)

                        -- 3rd col of the pop up
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            cmdline = "[Cmd]",
                            calc = "[Calc]",
                            dictionary = "[Dict]",
                            nvim_lsp_signature_help = "[LSP_s]",
                            -- latex_symbols = "[Symbol]"
                        })[entry.source.name]

                        return vim_item
                    end,
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "luasnip" },
                    { name = "path", },
                    { name = "calc" },
                    { name = "buffer", max_item_count = 3, },
                    { name = "dictionary", keyword_length = 2, max_item_count = 8 }
                }),
                window = {
                    -- completion = { border = FLOAT_WINDOW_BORDER_STYLE },
                    documentation = {
                        border = FLOAT_WINDOW_BORDER_STYLE,
                        winhighlight = "", -- Somehow sets the border colour to the default blue.
                    }
                }
            }
            return vim.tbl_deep_extend("force", default_opts, opts)
        end,
        config = function(_, opts)
            local cmp = require("cmp")
            cmp.setup(opts)

            ----- Disable pup-up for text files ------
            cmp.setup.filetype({ "text", "markdown", "", "plaintex", "tex", "norg" }, {
                completion = {
                    autocomplete = false, -- Disable auto trigger
                }
            })

            ----- Setup cmdline -----
            cmp.setup.cmdline(
                { "/", "?" },
                {
                    sources = cmp.config.sources({
                        { name = "buffer" },
                    }),
                    mapping = {
                        ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
                        ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),

                        ["<C-Space>"] = cmp.mapping(function()
                            if cmp.visible() then
                                cmp.close()
                            elseif not cmp.visible() then
                                cmp.complete()
                            end
                        end, { "c" }),
                        ["<C-y>"] = cmp.config.disable,
                        ["<C-e>"] = cmp.mapping(cmp.mapping.abort(), { "c" }),
                        ["<Tab>"] = cmp.mapping(
                            function()
                                if cmp.visible() then
                                    cmp.confirm({ select = true })
                                else
                                    cmp.complete()
                                end
                            end,
                            { "c" }
                        ),
                    },
                }
            )
        end,
    },
}
