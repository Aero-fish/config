return {
    name = "Pandoc markdown to pdf",
    builder = function()
        -- Full path to current file (see :help expand())
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
        return {
            cmd = {
                "pandoc",
                "--defaults",
                "md_to_pdf.yaml",
                "-i",
                file_path,
                "-o",
                file_name .. ".pdf"
            },
            name = "Pandoc markdown to pdf",
            cwd = dir,
        }
    end,
    desc = "Convert markdown to pdf using pandoc",
    condition = {
        filetype = { "markdown" },
    },
}
