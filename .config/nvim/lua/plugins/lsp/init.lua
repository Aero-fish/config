local servers = {
    "basedpyright",
    "bashls",
    "cspell_ls",
    "jsonls",
    "ltex_plus",
    "lua_ls",
    "taplo",
    "texlab",
    "tinymist",
    "yamlls",
}

local tools = {
    -- "cspell",
}

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufWritePost", "BufNewFile", "BufEnter" },
        config = function(_, opts)
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local has_blink, blink = pcall(require, "blink.cmp")
            local has_nvim_ufo, _ = pcall(require, "ufo")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_cmp and cmp_nvim_lsp.default_capabilities() or {},
                has_blink and blink.get_lsp_capabilities() or {}
            )

            if has_nvim_ufo then
                capabilities.textDocument.foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true
                }
            end


            for _, server in pairs(servers) do
                local default_on_attach_func = vim.lsp.config[server].on_attach
                local opts_override = {
                    capabilities = capabilities,
                    on_attach = function(client, bufnr)
                        -- Execute on_attach function provided by lspconfig
                        if default_on_attach_func then
                            default_on_attach_func(client, bufnr)
                        end
                    end
                }

                -- Append custom settings
                local has_custom_opts, server_custom_opts =
                    pcall(require, "plugins.lsp.settings." .. server)

                if has_custom_opts then
                    opts_override = vim.tbl_deep_extend(
                        "force",
                        opts_override,
                        server_custom_opts
                    )
                end

                -- Append workspace settings
                if opts[server] ~= nil then
                    opts_override = vim.tbl_deep_extend(
                        "force",
                        opts_override,
                        opts[server]
                    )
                end

                if opts_override.enable ~= false then
                    vim.lsp.config(server, opts_override)
                    vim.lsp.enable(server)
                end
            end
        end
    },
    {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile", "BufEnter" },
        opts = function()
            local formatting = require("null-ls").builtins.formatting

            local none_ls_opts = {
                -- debounce = 250,  -- Delay between modify and notification, it is not the minimum interval.
                debug = false,
                fallback_severity = vim.diagnostic.severity.INFO,
                sources = {
                    formatting.black,
                    formatting.d2_fmt,

                    -- Works with more file type than bashls
                    formatting.shfmt.with({ extra_args = { "-i=4" } }),

                    -- Bad: indent-width does not work, fixed to 2. Only support single level quote.
                    -- formatting.deno_fmt.with({
                    --     filetypes = { "html", "json", "yaml", "markdown" },
                    --     extra_args = { "--line-width", "88", "--indent-width", "8" },
                    -- }),

                    formatting.prettier.with({
                        extra_args = {
                            "--print-width",
                            "88",
                            "--tab-width",
                            "4",
                            "--prose-wrap",
                            "always", -- Needed to force wrapping long lines
                            "--end-of-line",
                            "auto",
                            "--ignore-path",
                            "[.prettierignore]", -- Default "[.gitignore, .prettierignore]"
                        },
                    }),

                    -- formatting.example.with({
                    --     filetypes = { "html", "json", "yaml", "markdown" },
                    --     extra_filetypes = { "toml" },
                    --     disabled_filetypes = { "lua" },
                    --     args = {},
                    --     env = {
                    --         PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
                    --             "~/.config/nvim/utils/linter-config/.prettierrc.json")
                    --     },
                    --     env =
                    --         function(params)
                    --             return { PYTHONPATH = params.root }
                    --         end,
                    --     extra_args = { "--print-width", "88", "--tab-width", "4" },
                    --     extra_args =
                    --         function(params)
                    --             return params.options
                    --                 and params.options.tabSize
                    --                 and { "--tab-width", params.options.tabSize }
                    --         end,

                    --     -- ignore prettier warnings from eslint-plugin-prettier
                    --     filter = function(diagnostic)
                    --         return diagnostic.code ~= "prettier/prettier"
                    --     end,

                    --     diagnostic_config = {
                    --         -- see :help vim.diagnostic.config(), override default config
                    --         underline = true,
                    --         virtual_text = false,
                    --         signs = true,
                    --         update_in_insert = false,
                    --         severity_sort = true,
                    --     },

                    --     timeout = 10000,
                    --     prefer_local = "node_modules/.bin",
                    --     command = "/path/to/prettier", -- No fallback
                    --     filter_actions =
                    --         function(title)
                    --             -- filter out blame actions
                    --             return title:lower():match("blame") == nil
                    --         end,
                    --     condition =
                    --         function(utils)
                    --             return utils.root_has_file({ "stylua.toml", ".stylua.toml" })
                    --         end,
                    -- }),
                },
                update_in_insert = false,
            }
            return none_ls_opts
        end
    },
    {
        --  Framework for managing editor external tools
        "mason-org/mason.nvim",
        init = function()
            local registry = require("mason-registry")
            -- Get mapping from LSP name to mason package name
            -- From https://github.com/mason-org/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings.lua
            local lspconfig_to_package = {}
            for _, pkg_spec in ipairs(registry.get_all_package_specs()) do
                local lspconfig = vim.tbl_get(pkg_spec, "neovim", "lspconfig")
                if lspconfig then
                    lspconfig_to_package[lspconfig] = pkg_spec.name
                end
            end

            local package_list = {}
            local pkg_ok, pkg, pkg_name

            -- Get mason packages for LSP
            for _, lspconfig_name in ipairs(servers) do
                pkg_name = lspconfig_to_package[lspconfig_name]
                pkg_ok, pkg = pcall(registry.get_package, pkg_name)
                if pkg_ok then
                    table.insert(package_list, { name = lspconfig_name, pkg = pkg })
                else
                    vim.notify(
                        "LSP server '" ..
                        lspconfig_name .. "' is not found in mason",
                        vim.log.levels.ERROR
                    )
                end
                -- Manually install cspell-lsp. Registry does not return
                -- user defined packages
                -- registry.get_all_package_names()
                -- if lspconfig_name == "cspell_ls" then
                --     if not registry.is_installed("cspell-lsp") then
                --         vim.cmd("MasonInstall cspell-lsp")
                --     end
                -- else
                -- Normal install
                -- end
            end

            -- Get mason packages for tools
            for _, name in ipairs(tools) do
                pkg_ok, pkg = pcall(registry.get_package, name)
                if pkg_ok then
                    table.insert(package_list, { name = name, pkg = pkg })
                else
                    vim.notify(
                        "Tool '" .. name .. "' is not found in mason",
                        vim.log.levels.ERROR
                    )
                end
            end

            -- Install package
            for _, data in ipairs(package_list) do
                pkg_name = data.name
                pkg = data.pkg
                if not pkg:is_installed() and not pkg:is_installing() then
                    pkg:install(
                        { version = nil },
                        vim.schedule_wrap(function(success, err) end)
                    )
                end
            end
        end,
        cmd = {
            "Mason",
            "MasonUpdate",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog"
        },
        keys = {
            {
                "<leader>um",
                "<Cmd> Mason <Cr>",
                mode = { "n", "x" },
                desc = "Open Mason panel"
            },
            -- Called update all automatically
            -- {
            --     "<leader>uM",
            --     "<Cmd> MasonUpdate <Cr>",
            --     mode = { "n", "x" },
            --     desc = "Mason registry"
            -- },
        },
        build = ":MasonUpdate",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                },
                border = "rounded",
            },
            -- Custom mason registry
            -- registries = {
            --     "lua:my-mason-registry",
            --     "github:mason-org/mason-registry",
            -- },
        },
    },
    {
        --  Update all tools installed via Mason
        "RubixDev/mason-update-all",
        cmd = { "MasonUpdateAll" },
        opts = {},
        keys = {
            {
                "<leader>ut",
                "<Cmd> MasonUpdateAll <Cr>",
                mode = { "n", "x" },
                desc = "Tools installed via mason"
            },
        },
    },
    {
        -- Store used by 'jsonls' and 'yamlls'
        "b0o/schemastore.nvim"
    },
}
