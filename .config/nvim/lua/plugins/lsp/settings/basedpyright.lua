return {
    settings = {
        -- python = {
        --     pythonPath = "~/workspace/coding/.venv/bin/python3",
        -- },
        basedpyright = {
            disableLanguageServices = false,
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly", -- openFilesOnly / workspace
                typeCheckingMode = "recommended",
                -- extraPaths = { "path1", "path2" },

                autoImportCompletions = true,   -- Offers auto-import completions
                inlayHints = {
                    variableTypes = true,       -- hint for x: list[int|str] = [1, "a"]
                    callArgumentNames = true,   -- hint for func(x=1, b=2)
                    functionReturnTypes = true, -- hint for func() -> Literal[1]
                    genericTypes = true,        -- hint for x:ClassVar[str]  = "a"
                },
            }
        }
    },
}
