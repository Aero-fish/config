-- Escape: Close outline
-- Enter: Go to symbol location in code
-- o: Go to symbol location in code without losing focus
-- Ctrl+Space: Hover current symbol
-- K: Toggles the current symbol preview
-- r: Rename symbol
-- a: Code actions
-- h: fold symbol
-- l: Unfold symbol
-- W: Fold all symbols
-- E: Unfold all symbols
-- R: Reset all folding
-- ?: Show help message

return {
    {
        "hedyhli/outline.nvim",
        cmd = { "Outline", "OutlineOpen" },
        opts = {
            symbols = {
                icons = {
                    Array = { icon = "", hl = "Constant" },
                    Boolean = { icon = "", hl = "Boolean" },
                    Class = { icon = "", hl = "Type" },
                    Component = { icon = "󰅴", hl = "Function" },
                    Constant = { icon = "", hl = "Constant" },
                    Constructor = { icon = "", hl = "Special" },
                    Enum = { icon = "", hl = "Type" },
                    EnumMember = { icon = "", hl = "Identifier" },
                    Event = { icon = "", hl = "Type" },
                    Field = { icon = "", hl = "Identifier" },
                    File = { icon = "", hl = "Identifier" },
                    Fragment = { icon = "󰅴", hl = "Constant" },
                    Function = { icon = "󰊕", hl = "Function" },
                    Interface = { icon = "", hl = "Type" },
                    Key = { icon = "", hl = "Type" },
                    Macro = { icon = "󰁌", hl = "Function" },
                    Method = { icon = "󰆧", hl = "Function" },
                    -- Module = { icon = "󰏗", hl = "Include" },
                    Module = { icon = "", hl = "Include" },
                    Namespace = { icon = "", hl = "Include" },
                    Null = { icon = "󰢤", hl = "Type" },
                    Number = { icon = "󰎠", hl = "Number" },
                    Object = { icon = "󰅩", hl = "Type" },
                    Operator = { icon = "", hl = "Identifier" },
                    Package = { icon = "󰅩", hl = "Include" },
                    Parameter = { icon = "", hl = "Identifier" },
                    Property = { icon = "", hl = "Identifier" },
                    StaticMethod = { icon = "󰊕", hl = "Function" },
                    String = { icon = "", hl = "String" },
                    Struct = { icon = "", hl = "Structure" },
                    TypeAlias = { icon = "", hl = "Type" },
                    TypeParameter = { icon = "", hl = "Identifier" },
                    Variable = { icon = "", hl = "Constant" },
                },
            },
        },
        keys = {
            {
                "<leader>o",
                "<Cmd> Outline <CR>",
                desc = "Toggle outline",
                mode = { "n", "x" }
            }
        },
    }
}
