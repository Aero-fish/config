return {
    "danymat/neogen",
    cmd = { "Neogen" },
    opts = {
        enabled = true,             --if you want to disable Neogen
        input_after_comment = true, -- (default: true) automatic jump (with insert mode) on inserted annotation
        -- jump_map = "<C-e>"       -- (DROPPED SUPPORT, see [here](#cycle-between-annotations) !) The keymap in order to jump in the annotation fields (in insert mode)
        snippet_engine = "luasnip",
        -- languages = {
        --     lua = {
        --         template = {
        --             annotation_convention = "emmylua" -- for a full list of annotation_conventions, see supported-languages below,
        --             -- for more template configurations, see the language's configuration file in configurations/{lang}.lua
        --         }
        --     },
        --     ['cpp.doxygen'] = require('neogen.configurations.cpp')
        -- }
    },
    keys = {
        {
            "<leader>ea",
            function()
                require("neogen").generate({
                    -- the annotation type to generate.
                    -- Currently supported: func, class, type, file
                    -- type = "func",
                })
            end,
            desc = "Annotate code",
            mode = { "n", "x" }
        }
    }
}
