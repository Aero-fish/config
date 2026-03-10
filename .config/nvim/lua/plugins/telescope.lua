-- Previewer to ignore binary
local new_maker = function(filepath, bufnr, opts)
    filepath = vim.fn.expand(filepath)
    require("plenary.job"):new({
        command = "file",
        args = { "--mime-type", "-b", filepath },
        on_exit = function(j)
            local mime_type = vim.split(j:result()[1], "/")[1]
            if mime_type == "text" then
                require("telescope.previewers").buffer_previewer_maker(filepath, bufnr,
                    opts)
            else
                -- maybe we want to write something to the buffer here
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false,
                        { "BINARY" })
                end)
            end
        end
    }):sync()
end

return {
    {
        -- Use fzf to fuzzy search. It has no 'event', 'cmd', or 'keys' to lazy
        -- load it. So load with telescope.
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        -- Set opts using table, not functions to allow merge from other plugins.
        opts = function(_, opts)
            -- Name functions to show nicer name in keymaps
            local history_next = function(bufnr)
                require("telescope.actions").cycle_history_next(bufnr)
            end
            local history_prev = function(bufnr)
                require("telescope.actions").cycle_history_prev(bufnr)
            end

            local selection_next = function(bufnr)
                require("telescope.actions").move_selection_next(bufnr)
            end
            local selection_prev = function(bufnr)
                require("telescope.actions").move_selection_previous(bufnr)
            end

            local default_action = function(bufnr)
                require("telescope.actions").select_default(bufnr)
            end

            local show_in_h_split = function(bufnr)
                require("telescope.actions").select_horizontal(bufnr)
            end
            local show_in_v_split = function(bufnr)
                require("telescope.actions").select_vertical(bufnr)
            end
            local show_in_new_tab = function(bufnr)
                require("telescope.actions").select_tab(bufnr)
            end

            local results_up = function(bufnr)
                require("telescope.actions").results_scrolling_up(bufnr)
            end
            local results_down = function(bufnr)
                require("telescope.actions").results_scrolling_down(bufnr)
            end

            local delete_buf = function(bufnr)
                require("telescope.actions").delete_buffer(bufnr)
            end

            local toggle_sel_and_up = function(bufnr)
                require("telescope.actions").toggle_selection(bufnr)
                require("telescope.actions").move_selection_worse(bufnr)
            end
            local toggle_sel_and_down = function(bufnr)
                require("telescope.actions").toggle_selection(bufnr)
                require("telescope.actions").move_selection_better(bufnr)
            end

            local send_sel_to_qf = function(bufnr)
                require("telescope.actions").send_selected_to_qflist(bufnr)
                require("telescope.actions").open_qflist(bufnr)
            end
            local send_all_to_qf = function(bufnr)
                require("telescope.actions").send_to_qflist(bufnr)
                require("telescope.actions").open_qflist(bufnr)
            end

            local complete_tag = function(bufnr)
                require("telescope.actions").complete_tag(bufnr)
            end
            local show_keymaps = function(bufnr)
                require("telescope.actions").which_key(bufnr)
            end
            local toggle_preview = function(bufnr)
                require("telescope..actions.layout").toggle_preview(bufnr)
            end
            local close = function(bufnr)
                require("telescope.actions").close(bufnr)
            end

            local default_opts = {
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = "󱝂 ",
                    path_display = { "smart" },
                    buffer_previewer_maker = new_maker,
                    mappings = {
                        i = {
                            ["<C-n>"] = history_next,
                            ["<C-p>"] = history_prev,

                            ["<C-j>"] = selection_next,
                            ["<C-k>"] = selection_prev,
                            ["<C-S-j>"] = selection_next,
                            ["<C-S-k>"] = selection_prev,

                            ["<Down>"] = selection_next,
                            ["<Up>"] = selection_prev,

                            ["<Cr>"] = default_action,

                            ["<C-S-h>"] = show_in_h_split,
                            ["<C-S-v>"] = show_in_v_split,
                            ["<C-S-t>"] = show_in_new_tab,

                            ["<C-h>"] = results_up,
                            ["<C-l>"] = results_down,

                            ["<Del>"] = delete_buf,

                            ["<Tab>"] = toggle_sel_and_up,
                            ["<S-tab>"] = toggle_sel_and_down,

                            ["<C-w>"] = send_sel_to_qf,
                            ["<C-S-w>"] = send_all_to_qf,

                            ["<C-t>"] = complete_tag,
                            ["<C-_>"] = show_keymaps, -- keys from pressing <c-/>
                            ["<M-p>"] = toggle_preview,
                            ["<Esc>"] = close,

                            -- de-clutter
                            ["<C-q>"] = false,
                            ["<C-v>"] = false,
                            ["<C-x>"] = false,
                            ["<C-f>"] = false,
                            ["<M-f>"] = false,
                            ["<M-k>"] = false,
                            ["<M-q>"] = false,
                            ["<PageUp>"] = false,
                            ["<PageDown>"] = false,
                        },
                    },
                    vimgrep_arguments = {
                        "rg", "--no-ignore", "--hidden", "--color=never",
                        "--no-messages", "--no-ignore-messages", "--no-heading",
                        "--with-filename", "--line-number", "--column", "--smart-case",
                        "--max-filesize", "2M", "--trim", "--glob=!*.kdb",
                        "--glob=!*.kdbx", "--glob=!*.key", "--glob=!*cache/",
                        "--glob=!.cargo/", "--glob=!.cert", "--glob=!.fpm/",
                        "--glob=!.git/", "--glob=!.gnupg/", "--glob=!.gphoto/",
                        "--glob=!.hyprland/", "--glob=!.ipython/", "--glob=!.jupyter/",
                        "--glob=!.keepass/", "--glob=!.keepassxc/",
                        "--glob=!.lastpass/", "--glob=!.npm/", "--glob=!.nv",
                        "--glob=!.password-store/", "--glob=!.perl5/", "--glob=!.pki/",
                        "--glob=!.snapshots/", "--glob=!.ssh/", "--glob=!.svn/",
                        "--glob=!.texlive/", "--glob=!.vscode-oss/", "--glob=!.wine/",
                        "--glob=!__pycache__/", "--glob=!bitwarden/",
                        "--glob=!containers/", "--glob=!go/", "--glob=!keepass/",
                        "--glob=!keepass/", "--glob=!keepassx/", "--glob=!keepassxc/",
                        "--glob=!keepassxcrc/", "--glob=!keyrings/",
                        "--glob=!librewolf*/", "--glob=!lost+found",
                        "--glob=!mozilla*/", "--glob=!node_modules/", "--glob=!rclone/",
                        "--glob=!thunderbird/",
                    }
                },
                preview = {
                    filesize_limit = 0.1, -- mb
                },
                pickers = {
                    find_files = {
                        find_command = {
                            "fd", "--type", "f", "--unrestricted", "--follow",
                            "--exclude", "*.kdb", "--exclude", "*.kdbx",
                            "--exclude", "*.key", "--exclude", "*cache/",
                            "--exclude", ".cargo/", "--exclude", ".cert",
                            "--exclude", ".fpm/", "--exclude", ".git/",
                            "--exclude", ".gnupg/", "--exclude", ".gphoto/",
                            "--exclude", ".hyprland/", "--exclude", ".ipython/",
                            "--exclude", ".jupyter/", "--exclude", ".keepass/",
                            "--exclude", ".keepassxc/", "--exclude", ".lastpass/",
                            "--exclude", ".npm/", "--exclude", ".nv", "--exclude",
                            ".password-store/", "--exclude", ".perl5/", "--exclude",
                            ".pki/", "--exclude", ".snapshots/", "--exclude", ".ssh/",
                            "--exclude", ".svn/", "--exclude", ".texlive/",
                            "--exclude", ".vscode-oss/", "--exclude", ".wine/",
                            "--exclude", "bitwarden/", "--exclude", "keepass/",
                            "--exclude", "keepassxcrc/", "--exclude", "__pycache__/",
                            "--exclude", "containers/", "--exclude", "go/",
                            "--exclude", "keepass/", "--exclude", "keepassx/",
                            "--exclude", "keepassxc/", "--exclude", "keyrings/",
                            "--exclude", "lost+found", "--exclude", "mozilla*/",
                            "--exclude", "librewolf*/", "--exclude", "node_modules/",
                            "--exclude", "rclone/", "--exclude", "thunderbird/",
                        },
                    },

                    -- The default action is check out the commit. Too
                    -- dangerous. Disable them.
                    git_commits = {
                        mappings = {
                            i = { ["<Cr>"] = false },
                        },
                    },
                    git_bcommits = {
                        mappings = {
                            i = { ["<Cr>"] = false },
                        },
                    },
                    git_branches = {
                        mappings = {
                            i = { ["<Cr>"] = false },
                        },
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- "smart_case", "ignore_case" or "respect_case"
                    }
                },
            }
            -- Let others plugins to override the opts
            return vim.tbl_deep_extend("force", default_opts, opts)
        end,
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
        end,
        keys = {
            {
                "<C-p>",
                function() require("telescope.builtin").buffers() end,
                desc = "Find buffers",
                mode = { "n", "x", "i" }
            },
            {
                "<C-S-p>",
                function() require("telescope.builtin").find_files() end,
                desc = "Find files",
                mode = { "n", "x", "i" }
            },
            {
                "<C-S-j>",
                function() require("telescope.builtin").buffers() end,
                desc = "Find buffers",
                mode = { "n", "x", "i" }
            },
            {
                "<C-S-k>",
                function() require("telescope.builtin").buffers() end,
                desc = "Find buffers",
                mode = { "n", "x", "i" }
            },
            {
                "<leader>i",
                function() require("telescope.builtin").buffers() end,
                desc = "Find buffers",
                mode = { "n", "x" }
            },

            {
                "<leader>fb",
                function() require("telescope.builtin").buffers() end,
                desc = "Buffers",
                mode = { "n", "x" }
            },
            {
                "<leader>fc",
                function() require("telescope.builtin").commands() end,
                desc = "Command",
                mode = { "n", "x" }
            },
            {
                "<leader>fC",
                function() require("telescope.builtin").command_history() end,
                desc = "Command history",
                mode = { "n", "x" }
            },
            {
                "<leader>fd",
                function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end,
                desc = "Diagnostics (Buffer)",
                mode = { "n", "x" }
            },
            {
                "<leader>fD",
                function() require("telescope.builtin").diagnostics({ bufnr = nil }) end,
                desc = "Diagnostics (workspace)",
                mode = { "n", "x" }
            },

            -- <leader>ff = Find+/Files in
            {
                "<leader>ffg",
                function() require("telescope.builtin").git_files() end,
                desc = "Git",
                mode = { "n", "x" }
            },
            {
                "<leader>ffr",
                function() require("telescope.builtin").oldfiles() end,
                desc = "Recent files",
                mode = { "n", "x" }
            },
            {
                "<leader>ffw",
                function() require("telescope.builtin").find_files() end,
                desc = "Workspace",
                mode = { "n", "x" }
            },

            {
                "<leader>fh",
                function() require("telescope.builtin").help_tags() end,
                desc = "Help",
                mode = { "n", "x" }
            },
            {
                "<leader>fi",
                function() require("telescope.builtin").lsp_implementations() end,
                desc = "Implementations",
                mode = { "n", "x" }
            },
            {
                "<leader>fj",
                function() require("telescope.builtin").jumplist() end,
                desc = "Jumplist",
                mode = { "n", "x" }
            },
            {
                "<leader>fk",
                function() require("telescope.builtin").keymaps() end,
                desc = "Keymaps",
                mode = { "n", "x" }
            },
            {
                "<leader>fl",
                function() require("telescope.builtin").loclist() end,
                desc = "Location list",
                mode = { "n", "x" }
            },
            {
                "<leader>fo",
                function() require("telescope.builtin").colorscheme() end,
                desc = "Colour scheme",
                mode = { "n", "x" }
            },
            {
                "<leader>fq",
                function() require("telescope.builtin").quickfix() end,
                desc = "Quickfix",
                mode = { "n", "x" }
            },
            {
                "<leader>fQ",
                function() require("telescope.builtin").quickfixhistory() end,
                desc = "Quickfix history",
                mode = { "n", "x" }
            },
            {
                "<leader>fr",
                function() require("telescope.builtin").lsp_references() end,
                desc = "References",
                mode = { "n", "x" }
            },
            {
                "<leader>fs",
                function() require("telescope.builtin").lsp_document_symbols() end,
                desc = "Document symbols",
                mode = { "n", "x" }
            },
            {
                "<leader>fS",
                function() require("telescope.builtin").lsp_workspace_symbols() end,
                desc = "Workspace symbols",
                mode = { "n", "x" }
            },
            {
                "<leader>ft",
                function() require("telescope.builtin").lsp_type_definitions() end,
                desc = "Type definitions",
                mode = { "n", "x" }
            },
            {
                "<leader>fW",
                function()
                    require("telescope.builtin")
                        .lsp_dynamic_workspace_symbols()
                end,
                desc = "Dynamic workspace symbols",
                mode = { "n", "x" }
            },

            -- <leader>ff = Find+/Words in
            {
                "<leader>fwb",
                function() require("telescope.builtin").current_buffer_fuzzy_find() end,
                desc = "Cur buffer",
                mode = { "n", "x" }
            },
            {
                "<leader>fwB",
                function()
                    require("telescope.builtin").live_grep({
                        grep_open_files = true
                    })
                end,
                desc = "Opened buffers",
                mode = { "n", "x" }
            },
            {
                "<leader>fwc",
                function() require("telescope.builtin").grep_string() end,
                desc = "Under cursor",
                mode = { "n", "x" }
            },
            {
                "<leader>fww",
                function() require("telescope.builtin").live_grep() end,
                desc = "Workspace",
                mode = { "n", "x" }
            },

            -- <leader>g = Git+
            {
                "<leader>gc",
                function() require("telescope.builtin").git_bcommits() end,
                desc = "Commits (buf)",
                mode = "n"
            },
            {
                "<leader>gc",
                function() require("telescope.builtin").git_bcommits_range() end,
                desc = "Commits (buf, lines)",
                mode = "x"
            },
            {
                "<leader>gB",
                function() require("telescope.builtin").git_branches() end,
                desc = "Checkout branch",
                mode = { "n", "x" }
            },
            {
                "<leader>gC",
                function() require("telescope.builtin").git_commits() end,
                desc = "Commits",
                mode = { "n", "x" }
            },
            {
                "<leader>gl",
                function() require("telescope.builtin").git_status() end,
                desc = "List changed files",
                mode = { "n", "x" }
            },
            {
                "<leader>gL",
                function() require("telescope.builtin").git_stash() end,
                desc = "List stash",
                mode = { "n", "x" }
            },
            {
                "<leader>O",
                function() require("telescope.builtin").oldfiles() end,
                desc = "Old/Recent files",
                mode = { "n", "x" }
            },

            -- Show
            {
                "<leader>sj",
                function() require("telescope.builtin").jumplist() end,
                desc = "Jump list",
                mode = { "n", "x" }
            },
            {
                "<leader>sm",
                function() require("telescope.builtin").marks() end,
                desc = "Marks",
                mode = { "n", "x" }
            },
            {
                "<leader>sM",
                function() require("telescope.builtin").man_pages() end,
                desc = "Man page",
                mode = { "n", "x" }
            },
            {
                "<leader>sr",
                function() require("telescope.builtin").registers() end,
                desc = "Registers",
                mode = { "n", "x" }
            },
            {
                "<leader>sS",
                function() require("telescope.builtin").registers() end,
                desc = "Search history",
                mode = { "n", "x" }
            },
        }
    },
    {
        -- Find in selected dir
        "princejoogie/dir-telescope.nvim",
        dependencies = { "telescope.nvim" },
        opts = {
            -- these are the default options set
            hidden = true,
            no_ignore = false,
            show_preview = true,
            follow_symlinks = true,
        },
        config = function(_, opts)
            require("dir-telescope").setup(opts)
            require("telescope").load_extension("dir")
        end,
        keys = {
            {
                "<leader>ffd",
                "<Cmd>Telescope dir find_files<Cr>",
                desc = "Dirs",
                mode = { "n", "x" },
                noremap = true,
                silent = true
            },
            {
                "<leader>fwd",
                "<Cmd>Telescope dir live_grep<Cr>",
                desc = "Dirs",
                mode = { "n", "x" },
                noremap = true,
                silent = true
            },
        }
    },
    {

        -- Find adjacent file
        "MaximilianLloyd/adjacent.nvim",
        dependencies = {
            { "telescope.nvim", opts = { extensions = { adjacent = { level = 1 } } } },
        },
        keys = {
            {
                "<leader>ffa",
                "<Cmd> Telescope adjacent <Cr>",
                desc = "Adjacent",
                mode = { "n", "x" }
            },
        }

    },
    {
        -- Yank an undo
        "debugloop/telescope-undo.nvim",
        dependencies = {
            {
                "telescope.nvim",
                opts = {
                    extensions = {
                        undo = {
                            mappings = {
                                i = {
                                    ["<Cr>"] = function(bufnr)
                                        return require("telescope-undo.actions")
                                            .yank_additions(bufnr)
                                    end,
                                    ["<S-Cr>"] = function(bufnr)
                                        require("telescope-undo.actions")
                                            .yank_deletions(bufnr)
                                    end,
                                    ["<C-Cr>"] = function(bufnr)
                                        require("telescope-undo.actions").restore(
                                            bufnr)
                                    end,
                                },
                                n = {
                                    ["y"] = function(bufnr)
                                        require("telescope-undo.actions")
                                            .yank_additions(bufnr)
                                    end,
                                    ["Y"] = function(bufnr)
                                        require("telescope-undo.actions")
                                            .yank_deletions(bufnr)
                                    end,
                                    ["u"] = function(bufnr)
                                        require("telescope-undo.actions").restore(
                                            bufnr)
                                    end,
                                }
                            }
                        }
                    }
                }
            },
        },
        config = function()
            require("telescope").load_extension("undo")
        end,
        keys = {
            {
                "<leader>su",
                function() require("telescope").extensions.undo.undo() end,
                desc = "Undo history",
                mode = { "n", "x" }
            },
        }
    },
    {
        -- open source license
        "chip/telescope-software-licenses.nvim",
        dependencies = { "telescope.nvim" },
        config = function()
            require("telescope").load_extension("software-licenses")
        end,
        keys = {
            {
                "<leader>sL",
                "<Cmd> Telescope software-licenses find  <Cr>",
                desc = "Software licenses",
                mode = { "n", "x" }
            },
        }
    },
    {
        "folke/todo-comments.nvim",
        optional = true,
        keys = {
            {
                "<leader>fT",
                "<CMD> TodoTelescope <CR>",
                desc = "Todo tags",
                mode = { "n", "x" }
            }
        }
    }
}
