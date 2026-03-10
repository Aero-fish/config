return {
    {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        event = { "BufRead" },
        config = function()
            -- vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
            -- vim.o.foldlevelstart = 99

            vim.o.foldcolumn = "1" -- '0' is not bad
            -- vim.o.foldenable = true

            vim.keymap.set("n", "zR", require("ufo").openAllFolds,
                { desc = "Open all folds" }
            )
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds,
                { desc = "Close all folds" }
            )
            vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds,
                { desc = "Fold less" }
            )
            vim.keymap.set("n", "zl", require("ufo").openFoldsExceptKinds,
                { desc = "Fold less" }
            )
            -- Use [count] zm to fold to a [count] level
            vim.keymap.set("n", "zm", require("ufo").closeFoldsWith,
                { desc = "Fold more" }
            )
            vim.keymap.set("n", "zk",
                function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then
                        vim.lsp.buf.hover()
                    end
                end,
                { desc = "Peek Fold" }
            )

            require("ufo").setup()
        end,
    },
}
