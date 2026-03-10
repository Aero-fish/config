return {
    {
        "uga-rosa/ccc.nvim",
        event = "BufRead",
        opts = {
            -- disable_default_mappings = true,
            highlighter = {
                auto_enable = true,
                lsp = true,
            },
        },
        keys = {
            {
                "<leader>th",
                "<Cmd> CccHighlighterToggle <Cr>",
                desc = "Colour highlight",
                mode = { "n" }
            },
            {
                "<leader>xCp",
                "<Cmd> CccPick <Cr>",
                desc = "Colour picker [i,o,a,r]",
                mode = { "n" }
            },
            {
                "<leader>xCc",
                "<Cmd> CccConvert <Cr>",
                desc = "Colour convert",
                mode = { "n" }
            },
        }
    }
}
