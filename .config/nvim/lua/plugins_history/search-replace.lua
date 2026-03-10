-- Cursor is denoted as '|'
--------------------

-- Cword
-- # Selection:
-- lv|im.builtin.which_key.mappings["r"]["w"]
-- ^^^^^
-- # Value:
-- lvim

--------------------
-- CWORD
-- # Selection:
-- lv|im.builtin.which_key.mappings["r"]["w"]
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- # Value:
-- lvim.builtin.which_key.mappings["r"]["w"]

--------------------
-- CExpr
-- CExpr is replaced with the word under the cursor, including more to form a C expression.
-- # Selection:
-- lvim.bui|ltin.which_key.mappings["r"]["w"]
-- ^^^^^^^^^^^^^
-- # Value:
-- lvim.builtin
--------------------
-- # Selection:
-- lvim.builtin.wh|ich_key.mappings["r"]["w"]
-- ^^^^^^^^^^^^^^^^^^^^^^^
-- # Value:
-- lvim.builtin.which_key
--------------------
-- # Selection:
-- lvim.builtin.which_key.map|pings["r"]["w"]
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- # Value:
-- lvim.builtin.which_key.mappings

--------------------
-- CFile
-- CFile is replaced with the path name under the cursor (like what gf uses)
-- # Selection:
-- lvim.bui|ltin.which_key.mappings["r"]["w"]
-- ^^^^^^^^^^^^^
-- # Value:
-- lvim.builtin
--------------------
-- # Selection:
-- lvim.builtin.wh|ich_key.mappings["r"]["w"]
-- ^^^^^^^^^^^^^^^^^^^^^^^
-- # Value:
-- lvim.builtin.which_key

-- # Selection:
-- lvim.builtin.which_key.map|pings["r"]["w"]
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- # Value:
-- lvim.builtin.which_key.mappings

return {
    "roobert/search-replace.nvim",
    cmd = {
        "SearchReplaceSingleBufferOpen",
        "SearchReplaceMultiBufferOpen",
        "SearchReplaceSingleBufferCWord",
        "SearchReplaceSingleBufferCWORD",
        "SearchReplaceSingleBufferCExpr",
        "SearchReplaceSingleBufferCFile",
        "SearchReplaceMultiBufferCWord",
        "SearchReplaceMultiBufferCWORD",
        "SearchReplaceMultiBufferCExpr",
        "SearchReplaceMultiBufferCFile",
        "SearchReplaceSingleBufferSelections",
        "SearchReplaceMultiBufferSelections",
        "SearchReplaceSingleBufferWithinBlock",
        "SearchReplaceVisualSelection",
        "SearchReplaceVisualSelectionCWord",
        "SearchReplaceVisualSelectionCWORD",
        "SearchReplaceVisualSelectionCExpr",
        "SearchReplaceVisualSelectionCFile"
    },
    opts = {
        default_replace_single_buffer_options = "gcI",
        default_replace_multi_buffer_options = "egcI",
    },
    keys = {
        -- {
        --     "<leader>Rs",
        --     "<Cmd> SearchReplaceMultiBuffer <Cr>",
        --     desc = "Selection list",
        --     mode = { "n", "x" }
        -- },
        -- {
        --     "<leader>Ro",
        --     "<Cmd> SearchReplaceMultiBufferOpen <Cr>",
        --     desc = "Open",
        --     mode = { "n", "x" }
        -- },
        -- {
        --     "<leader>Rw",
        --     "<Cmd> SearchReplaceMultiBufferCWord <Cr>",
        --     desc = "word",
        --     mode = { "n", "x" }
        -- },
        -- {
        --     "<leader>RW",
        --     "<Cmd> SearchReplaceMultiBufferCWORD <Cr>",
        --     desc = "WORD",
        --     mode = { "n", "x" }
        -- },
        -- {
        --     "<leader>Re",
        --     "<Cmd> SearchReplaceMultiBufferCExpr <Cr>",
        --     desc = "expr",
        --     mode = { "n", "x" }
        -- },
        -- {
        --     "<leader>Rf",
        --     "<Cmd> SearchReplaceMultiBufferCFile <Cr>",
        --     desc = "file",
        --     mode = { "n", "x" }
        -- },

        -- {
        --     "<leader>rs",
        --     "<Cmd> SearchReplaceSingleBufferSelections <Cr>",
        --     desc = "Selection list",
        --     mode = "n"
        -- },
        {
            "<leader>ro",
            "<Cmd> SearchReplaceSingleBufferOpen <Cr>",
            desc = "Open",
            mode = "n"
        },
        {
            "<leader>rw",
            "<Cmd> SearchReplaceSingleBufferCWord <Cr>",
            desc = "word",
            mode = "n"
        },
        -- {
        --     "<leader>rW",
        --     "<Cmd> SearchReplaceMultiBufferCWORD <Cr>",
        --     desc = "WORD",
        --     mode = "n"
        -- },
        -- {
        --     "<leader>re",
        --     "<Cmd> SearchReplaceSingleBufferCExpr <Cr>",
        --     desc = "expr",
        --     mode = "n"
        -- },
        -- {
        --     "<leader>rf",
        --     "<Cmd> SearchReplaceSingleBufferCFile <Cr>",
        --     desc = "file",
        --     mode = "n"
        -- },
        {
            "<leader>rs",
            "<Cmd> SearchReplaceSingleBufferVisualSelection <Cr>",
            desc = "With selection",
            mode = "x"
        },
        {
            "<leader>ri",
            "<Cmd> SearchReplaceWithinVisualSelection <Cr>",
            desc = "In selection",
            mode = "x"
        },
        -- {
        --     "<leader>rw",
        --     "<Cmd> SearchReplaceWithinVisualSelectionCWord <Cr>",
        --     desc = "word",
        --     mode = "x"
        -- },
    }
}
