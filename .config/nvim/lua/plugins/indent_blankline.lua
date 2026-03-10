-- Highlight indentations
-- local highlight = {
--     "CursorColumn",
--     "Whitespace",
-- }

return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "BufRead",
        opts = {

            -- Alternate indentation colour by level
            -- Comment out to use vertical line indicators

            -- indent = {
            --     highlight = highlight,
            --     char = ""
            -- },
            -- whitespace = {
            --     highlight = highlight,
            --     remove_blankline_trail = false,
            -- },

            ----------
            scope = { enabled = false },
        }

    }
}
