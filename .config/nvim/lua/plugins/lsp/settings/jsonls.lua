local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local has_blink, blink = pcall(require, "blink.cmp")
local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    has_cmp and cmp_nvim_lsp.default_capabilities() or {},
    has_blink and blink.get_lsp_capabilities() or {}
)
capabilities.documentFormattingProvider = false

local opts = {
    settings = {
        json = {
            validate = { enable = true },
        }
    },
    capabilities = capabilities
}

local schemastore_ok = require("lazy.core.config")["spec"]["plugins"]
    ["schemastore.nvim"]

if schemastore_ok ~= nil then
    opts.settings.json.schemas = require("schemastore").json.schemas({
        -- replace = {
        --     ['package.json'] = {
        --         description = 'package.json overriden',
        --         fileMatch = { 'package.json' },
        --         name = 'package.json',
        --         url = 'https://example.com/package.json',
        --     }
        -- }
        -- ignore = {
        --     '.eslintrc',
        --     'package.json',
        -- },
        -- select = {
        --     '.eslintrc',
        --     'package.json',
        -- },
    })
end

return opts
