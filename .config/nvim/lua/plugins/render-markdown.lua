return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    opts = {
        -- render_modes = { 'n', 'c', 't' },
        render_modes = true,

        sign = { enabled = false },
        -- heading = {
        --     sign = false,
        -- },
        -- code = {
        --     sign = false,
        -- },
        -- checkbox = {
        --     checked = { scope_highlight = "@markup.strikethrough" }
        -- },
    },

    keys = {
        {
            "<leader>tm",
            function() require("render-markdown").toggle() end,
            mode = "n",
            desc = "Markdown render"
        }
    }
}
