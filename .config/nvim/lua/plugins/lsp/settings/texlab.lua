local home = os.getenv("HOME")
-- local rev_search_cmd = 'nvim --server ' ..
-- vim.v.servername ..
-- ' --remote-silent %%f; sleep 0.1; nvim --server ' ..
-- vim.v.servername .. ' --remote-send "<Esc>:%%l<Cr>"'

-- Neovim does not support '+cmd' yet
-- local rev_search_cmd = '"nvim --server ' .. vim.v.servername .. ' --remote-silent +%l %f"'

return {
    settings = {
        texlab = {
            forwardSearch = {
                executable = home ..
                    "/misc/programs/latex_synctex_hacks/evince-synctex.sh",
                args = { "sync", "%p", "%f", "%l", vim.v.servername, vim.fn.getcwd() },
            },
            build = {
                args = {
                    "-pdf",
                    "-interaction=nonstopmode",
                    "-synctex=1",
                    "-aux-directory=aux",
                    "-emulate-aux-dir",
                    "%f"
                },
                auxDirectory = "aux",
                logDirectory = "aux",
                -- forwardSearchAfter = true
            },
            chktex = {
                onOpenAndSave = true
            },
            diagnosticsDelay = 300,
            formatterLineLength = 88,
            latexFormatter = "latexindent",
            latexindent = {
                ["local"] = home .. "/.config/latexindent/indentconfig.yaml",
                modifyLineBreaks = true
            },
            diagnostics = {
                ignoredPatterns = {
                    "Unused label",
                },
            },
        }
    }
}
