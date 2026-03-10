return {
    settings = {
        -- formatterIndentSize = 2, -- Recommanded default is 2
        formatterMode = "typstyle",
        formatterPrintWidth = 89,
        -- formatterProseWrap = false,

        -- exportPdf = "onType",   -- onSave | onType | never
        -- exportTarget = "paged", -- paged | html
        -- semanticTokens = "disable", -- LSP syntax highlight. Use treesitter.
        lint = {
            enabled = true,
            when = "onSave",
        },
        -- outputPath = "",
        -- typstExtraArgs = { "arg1", "arg2" },
    }
}
