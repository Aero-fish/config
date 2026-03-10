return {
    name = "Markdown to revealjs",
    builder = function(params)
        -- Full path to current file (see :help expand())
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")

        return {
            cmd = { "pandoc" },
            args = {
                "--defaults",
                "md_to_revealjs.yaml",
                "-i", file_path,
                "-o", file_name .. ".html"
            },

            -- the name of the task (defaults to the cmd of the task)
            name = "Pandoc markdown to revealjs",

            -- set the working directory for the task
            cwd = dir,

            -- additional environment variables
            -- env = {
            --     VAR = "FOO",
            -- },

            -- the list of components or component aliases to add to the task
            -- components = { { "on_output_quickfix", open = true }, "default" },

            -- arbitrary table of data for your own personal use
            -- metadata = {
            --     foo = "bar",
            -- },
        }
    end,
    desc = "Convert markdown to reveal.js html using pandoc",

    -- Tags can be used in overseer.run_template()
    -- tags = { overseer.TAG.BUILD },

    -- params = {
    --     -- See :help overseer-params
    -- },

    -- Lower comes first.
    priority = 10,

    condition = {
        -- A string or list of strings
        -- Only matches when current buffer is one of the listed filetypes
        filetype = { "markdown" },

        -- A string or list of strings
        -- Only matches when cwd is inside one of the listed dirs
        -- dir = "/home/user/my_project",

        -- Arbitrary logic for determining if task is available
        -- callback = function(search)
        --     print(vim.inspect(search))
        --     return true
        -- end,
    },
}
