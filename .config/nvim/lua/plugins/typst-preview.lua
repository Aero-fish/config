return {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {
        dependencies_bin = {
            ["tinymist"] = "tinymist",
            ["websocat"] = "websocat",
        },
        follow_cursor = false,
        open_cmd = "librewolf %s",
        extra_args = { "--ignore-system-fonts" },
        -- extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
    },
}
