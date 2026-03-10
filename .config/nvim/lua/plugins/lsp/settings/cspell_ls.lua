return {
    cmd = {
        "cspell-lsp",
        "--stdio",
        "--sortWords",
    },
    -- This is 'initializationOptions' in LSP. This is nvim's own mapping
    -- No longer needed. Now reads the global config at ~/.config/cspell/cspell.json
    -- init_options = {
    --     defaultSettings = {
    --         allowCompoundWords = false,
    --         ignoreWords = {},
    --         language = "en-GB",
    --         useGitignore = false,
    --         userWords = {},
    --         words = {},
    --     }
    -- }
}
