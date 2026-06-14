return {
    name = "Pandoc markdown to revealjs",
    builder = function()
        -- Full path to current file (see :help expand())
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
        return {
            cmd = {
                "pandoc",
                "--defaults",
                "md_to_revealjs.yaml",
                "-i",
                file_path,
                "-o",
                file_name .. ".html"
            },
            name = "Pandoc markdown to revealjs",
            cwd = dir,
        }
    end,
    desc = "Convert markdown to reveal.js html using pandoc",
    condition = {
        filetype = { "markdown" },
    },
}
