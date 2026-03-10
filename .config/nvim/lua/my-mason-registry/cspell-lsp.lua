return {
    name = "cspell-lsp",
    description = "Spelling checker for source code",
    categories = { "LSP", "Linter" },
    homepage = "https://github.com/vlabo/cspell-lsp",
    languages = {},
    licenses = { "GPLv3" },
    source = {
        id = "pkg:npm/@vlabo/cspell-lsp@v1.1.4",
    },
    bin = {
        ["cspell-lsp"] = "npm:cspell-lsp"
    },
    neovim = {
        lspconfig = "cspell_ls"
    }
}
