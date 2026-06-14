return {
    name = "Compile d2 to svg",
    builder = function()
        -- Full path to current file (see :help expand())
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
        local output_path = dir .. file_name .. ".svg"
        return {
            cmd = {
                "d2",
                file_path,
                output_path
            },
            name = "D2 to SVG",
            cwd = dir,
        }
    end,
    desc = "Convert d2 to svg figure",
    condition = {
        filetype = { "d2" },
    },
}
