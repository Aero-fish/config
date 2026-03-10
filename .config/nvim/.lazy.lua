---------- Override builtin options ----------
-- local options = {
--     -- makeprg = "" -- Program to use for the ":make" command
--     -- makeef = "" -- Name of the errorfile for the :make command
-- }
--
-- for k, v in pairs(options) do
--     vim.opt[k] = v
-- end

----- Override plugin options -----
return {
    {
        "telescope.nvim",
        optional = true,
        opts = {
            defaults = {
                vimgrep_arguments = {
                    "rg", "--color=never", "--no-messages", "--no-ignore-messages",
                    "--no-heading", "--with-filename", "--line-number", "--column",
                    "--smart-case", "--max-filesize", "2M", "--trim", "--glob=!*.kdb",
                    "--glob=!*.kdbx", "--glob=!*.key", "--glob=!*cache/",
                    "--glob=!.cargo/", "--glob=!.cert", "--glob=!.fpm/",
                    "--glob=!.git/", "--glob=!.gnupg/", "--glob=!.gphoto/",
                    "--glob=!.hyprland/", "--glob=!.ipython/", "--glob=!.jupyter/",
                    "--glob=!.keepass/", "--glob=!.keepassxc/", "--glob=!.lastpass/",
                    "--glob=!.npm/", "--glob=!.nv", "--glob=!.password-store/",
                    "--glob=!.perl5/", "--glob=!.pki/", "--glob=!.snapshots/",
                    "--glob=!.ssh/", "--glob=!.svn/", "--glob=!.texlive/",
                    "--glob=!.vscode-oss/", "--glob=!.wine/", "--glob=!__pycache__/",
                    "--glob=!bitwarden/", "--glob=!containers/", "--glob=!go/",
                    "--glob=!keepass/", "--glob=!keepass/", "--glob=!keepassx/",
                    "--glob=!keepassxc/", "--glob=!keepassxcrc/", "--glob=!keyrings/",
                    "--glob=!librewolf*/", "--glob=!lost+found", "--glob=!mozilla*/",
                    "--glob=!node_modules/", "--glob=!rclone/", "--glob=!thunderbird/"
                }
            },
            pickers = {
                find_files = {
                    find_command = {
                        "fd", "--type", "f", "--follow", "--exclude", "*.kdb",
                        "--exclude", "*.kdbx", "--exclude", "*.key",
                        "--exclude", "*cache/", "--exclude", ".cargo/",
                        "--exclude", ".cert", "--exclude", ".fpm/",
                        "--exclude", ".git/", "--exclude", ".gnupg/",
                        "--exclude", ".gphoto/", "--exclude", ".hyprland/",
                        "--exclude", ".ipython/", "--exclude", ".jupyter/",
                        "--exclude", ".keepass/", "--exclude", ".keepassxc/",
                        "--exclude", ".lastpass/", "--exclude", ".npm/",
                        "--exclude", ".nv", "--exclude", ".password-store/",
                        "--exclude", ".perl5/", "--exclude", ".pki/",
                        "--exclude", ".snapshots/", "--exclude", ".ssh/",
                        "--exclude", ".svn/", "--exclude", ".texlive/",
                        "--exclude", ".vscode-oss/", "--exclude", ".wine/",
                        "--exclude", "bitwarden/", "--exclude", "keepass/",
                        "--exclude", "keepassxcrc/", "--exclude", "__pycache__/",
                        "--exclude", "containers/", "--exclude", "go/",
                        "--exclude", "keepass/", "--exclude", "keepassx/",
                        "--exclude", "keepassxc/", "--exclude", "keyrings/",
                        "--exclude", "lost+found", "--exclude", "mozilla*/",
                        "--exclude", "librewolf*/", "--exclude", "node_modules/",
                        "--exclude", "rclone/", "--exclude", "thunderbird/"
                    },
                }
            }
        }
    },
    {
        "nvim-lspconfig",
        optional = true,
        opts = {
            -- ["ltex"] = {
            --     settings = {
            --         ltex = {
            --             latex = {
            --                 commands = {
            --                     ["\\label{}"] = "ignore",
            --                     ["\\documentclass[]{}"] = "ignore",
            --                     ["\\cite{}"] = "dummy",
            --                     ["\\apple"] = "voweldummy",
            --                     ["\\cars"] = "pluraldummy",
            --                 },
            --                 environments = {
            --                     ["lstlisting"] = "ignore",
            --                     ["verbatim"] = "ignore",
            --                     ["alltt"] = "ignore",
            --                     ["align"] = "ignore",
            --                 },
            --             },
            --         },
            --     },
            -- },
            -- ["texlab"] = {
            --     settings = {
            --         texlab = {
            --             build = {
            --                 args = {
            --                     "-pdf",
            --                     "-interaction=nonstopmode",
            --                     "-synctex=1",
            --                     "-aux-directory=aux",
            --                     "-emulate-aux-dir",
            --                     "-shell-escape",
            --                     "%f"
            --                 },
            --             },
            --         }
            --     }
            -- },
            -- ["basedpyright"] = {
            --     settings = {
            --         python = {
            --             pythonPath = "~/workspace/coding/.venv/bin/python3",
            --         },
            --         basedpyright = {
            --             analysis = {
            --                 -- diagnosticMode = "workspace",
            --                 diagnosticMode = "openFilesOnly",
            --                 typeCheckingMode = "strict",
            --                 -- extraPaths = { "path1", "path2" },
            --             },
            --         },
            --     },
            -- },
        }
    },
}
