return {
    name = "Pandoc markdown to beamer",
    builder = function()
        -- Full path to current file (see :help expand())
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
        return {
            cmd = {
                "pandoc",
                "--defaults",
                "md_to_beamer.yaml",
                "-i",
                file_path,
                "-o",
                file_name .. "_beamer.pdf"
            },
            name = "Pandoc markdown to beamer",
            cwd = dir,
        }
    end,
    desc = "Convert markdown to beamer pdf using pandoc",
    condition = {
        filetype = { "markdown" },
    },
}
