local opts = {}
local schemastore_ok = require("lazy.core.config")["spec"]["plugins"]
    ["schemastore.nvim"]

if schemastore_ok ~= nil then
    opts.settings.yaml.schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
    }
    opts.settings.yaml.schemas = require("schemastore").yaml.schemas()

    -- Alternative
    -- schemas = { "lazygit" = ".config/lazygit/config.yml" },
    -- schemaStore = { enable = true }
end

return opts
