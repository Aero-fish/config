local dict_ft = {
    ["text"] = true,
    ["markdown"] = true,
    ["tex"] = true,
    ["plaintex"] = true,
    ["mail"] = true,
}

return {
    "rafamadriz/friendly-snippets", -- Snippet collection
    "jmbuhr/cmp-pandoc-references",
    "Kaiser-Yang/blink-cmp-dictionary",
    {
        "saghen/blink.cmp",
        -- Not comparable with bwrap --unshare-pid, when two nvims are opened

        event = "InsertEnter",

        -- Use a release tag to download pre-built binaries
        -- version = "*"

        -- Or build from source code
        build = "cargo build --release",

        -- Ordered by https://cmp.saghen.dev/configuration/reference.html
        opts = {
            enabled = function()
                return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
            end,

            completion = {
                keyword = { range = "prefix" }, -- prefix/full
                list = {
                    selection = { preselect = true, auto_insert = true },
                },
                accept = {
                    -- Write completions to the `.` register
                    dot_repeat = false,
                    auto_brackets = { enabled = false }
                },
                menu = {
                    border = "none",

                    -- Don't automatically show the completion menu
                    auto_show = true,
                    -- auto_show = function()
                    --     return not vim.tbl_contains(
                    --             {
                    --                 "",
                    --                 "markdown",
                    --                 "norg",
                    --                 "plaintex",
                    --                 "tex",
                    --                 "text",
                    --             },
                    --             vim.bo.filetype)
                    --         and vim.bo.buftype ~= "prompt"
                    --         and vim.b.completion ~= false
                    -- end,

                    draw = {
                        -- Highlight label with treesitter
                        treesitter = { "lsp" },

                        columns = {
                            -- { "kind_icon", "kind", gap = 1 },
                            { "kind_icon" },
                            { "label", "label_description", gap = 1 },
                            { "source_name" },
                        },
                        components = {
                            kind = {
                                text = function(ctx) return ctx.kind .. " " end,
                            },
                            source_name = {
                                text = function(ctx)
                                    return "[" .. ctx.source_name .. "]"
                                end,
                            },
                        },
                    },
                },
                documentation = {
                    treesitter_highlighting = true,
                    window = { border = "rounded" },
                },
                -- Useful for previewing AI generated code
                ghost_text = { enabled = false },

            },

            -- Show signature of a function automatically
            signature = {
                enabled = true,
                window = { border = "rounded" },
            },

            fuzzy = {
                -- implementation = "lua", --prefer_rust_with_warning/prefer_rust/rust/lua
                prebuilt_binaries = { download = false },
            },


            sources = {
                -- Static list of providers to enable, or a function to dynamically
                -- enable/disable providers based on the context
                default = { "lsp", "path", "snippets", "buffer", "dictionary" },

                -- You may also define providers per filetype
                -- per_filetype = {
                --     -- optionally inherit from the `default` sources
                --     -- lua = { inherit_defaults = true, 'lsp', 'path' },
                --     -- tex = { "lsp", "path", "buffer", "dictionary" },
                --     sql = { "snippets", "dadbod", "buffer" },
                --     markdown = {
                --         "lsp",
                --         "path",
                --         "snippets",
                --         "buffer",
                --         "dictionary",
                --         "references",
                --     },
                -- },


                -- Options for each provider
                providers = {
                    -- Hide snippets after trigger character, and in comments/string
                    snippets = {
                        should_show_items = function(ctx)
                            if ctx.trigger.initial_kind == "trigger_character" or ctx.get_mode() == "cmdline" then
                                return false
                            end

                            local cur_pos = vim.api.nvim_win_get_cursor(0)
                            local captures = vim.treesitter.get_captures_at_pos(
                                0,
                                cur_pos[1] - 1,
                                cur_pos[2] - 1
                            )
                            for _, cap in ipairs(captures) do
                                if cap.capture == "string" or cap.capture == "comment" or cap.capture == "nospell" then
                                    return false
                                end
                            end

                            return true
                        end
                    },

                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    references = {
                        name = "pandoc_references",
                        module = "cmp-pandoc-references.blink",
                    },

                    dictionary = {
                        module = "blink-cmp-dictionary",
                        name = "Dict",
                        -- Make sure this is at least 2.
                        -- 3 is recommended
                        min_keyword_length = 3,
                        opts = {
                            -- Specify the dictionary files' path
                            -- example: { vim.fn.expand('~/.config/nvim/dictionary/words.dict') }
                            dictionary_files = {
                                os.getenv("HOME") ..
                                "/.config/my-config/wordlist/words_large.txt"
                            },
                            -- All .txt files in these directories will be treated as dictionary files
                            -- example: { vim.fn.expand('~/.config/nvim/dictionary') }
                            -- dictionary_directories = nil,
                            kind_icons = { Dict = "" },
                        },
                        should_show_items = function(ctx)
                            local ft = vim.bo.filetype
                            if ctx.trigger.initial_kind == "trigger_character" then
                                return false
                            end

                            if dict_ft[ft] then
                                return true
                            end

                            local cur_pos = vim.api.nvim_win_get_cursor(0)
                            local captures = vim.treesitter.get_captures_at_pos(
                                0,
                                cur_pos[1] - 1,
                                cur_pos[2] - 1
                            )
                            for _, cap in ipairs(captures) do
                                -- print(cap.capture)
                                if cap.capture == "string" or cap.capture == "comment" then
                                    return true
                                elseif cap.capture == "nospell" then
                                    return false
                                end
                            end

                            return false
                        end,
                        score_offset = -6,
                    },
                },
            },

            appearance = {
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "normal",
                kind_icons = {

                    Text = "󰉿",
                    Method = "󰊕",
                    Function = "󰊕",
                    Constructor = "",

                    Field = "",
                    Variable = "",
                    Property = "",

                    Class = "",
                    Interface = "",
                    Struct = "",
                    Module = "",

                    Unit = "",
                    Value = "󰎠",
                    Enum = "",
                    EnumMember = "",

                    Keyword = "",
                    Constant = "",

                    Snippet = "󰩫",
                    Color = "",
                    File = "",
                    Reference = "󰦾",
                    Folder = "",
                    Event = "",
                    Operator = "",
                    TypeParameter = "",

                    Copilot = "",
                },
            },

            keymap = {
                -- Default mapping
                -- ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                -- ['<C-e>'] = { 'hide' },
                -- ['<C-y>'] = { 'select_and_accept' },
                --
                -- ['<Up>'] = { 'select_prev', 'fallback' },
                -- ['<Down>'] = { 'select_next', 'fallback' },
                -- ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
                -- ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
                --
                -- ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                -- ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
                --
                -- ['<Tab>'] = { 'snippet_forward', 'fallback' },
                -- ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
                --
                -- ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
                -- set to 'none' to disable the 'default' preset
                preset = "none",

                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },

                ["<Tab>"] = {
                    function(cmp)
                        if cmp.snippet_active() then
                            return cmp.accept()
                        else
                            return cmp.select_and_accept()
                        end
                    end,
                    "snippet_forward",
                    "fallback"
                },

                ["<S-Tab>"] = { "snippet_backward", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
                ["<C-j>"] = { "select_next", "fallback_to_mappings" },

                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },

            cmdline = {
                keymap = { preset = "inherit" },
                completion = { menu = { auto_show = true } },
            },
        },

    },
}
