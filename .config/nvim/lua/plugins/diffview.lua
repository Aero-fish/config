-- Show git diff between commits/branch/work tree


-- show diffview for the selected commit/branch and current work tree
local function diffview_worktree()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local buf = vim.api.nvim_get_current_buf()
    local hash = action_state.get_selected_entry().value
    actions.close(buf)
    vim.cmd(("DiffviewOpen %s"):format(hash))
end

-- show diffview for the selected commit
local function diffview_commits()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local buf = vim.api.nvim_get_current_buf()
    local picker = action_state.get_current_picker(buf)

    local entries = {}
    local count = 0
    for _, entry in ipairs(picker:get_multi_selection()) do
        table.insert(entries, entry)
        count = count + 1
        if count >= 2 then
            break
        end
    end
    actions.close(buf)

    if count == 2 then
        vim.cmd(("DiffviewOpen %s..%s"):format(entries[1].value,
            entries[2].value))
    else
        local hash = action_state.get_selected_entry().value
        vim.cmd(("DiffviewOpen %s^!"):format(hash))
    end
end

-- show diffview comparing the selected branch with the current branch HEAD
local function diffview_branchs()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local buf = vim.api.nvim_get_current_buf()
    local picker = action_state.get_current_picker(buf)

    local entries = {}
    local count = 0
    for _, entry in ipairs(picker:get_multi_selection()) do
        table.insert(entries, entry)
        count = count + 1
        if count >= 2 then
            break
        end
    end
    actions.close(buf)

    if count == 2 then
        vim.cmd(("DiffviewOpen %s..%s"):format(entries[1].value,
            entries[2].value))
    else
        local hash = action_state.get_selected_entry().value
        vim.cmd(("DiffviewOpen %s.."):format(hash))
    end
end
return {
    {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewClose",
            "DiffviewFileHistory",
            "DiffviewFocusFiles",
            "DiffviewLog",
            "DiffviewOpen",
            "DiffviewRefresh",
            "DiffviewToggleFiles"
        },
        config = function()
            require("diffview").setup()
        end,
        keys = {
            {
                "<leader>gH",
                "<Cmd> DiffviewFileHistory % <Cr>",
                desc = "Diffview file history",
                mode = { "n" }
            },
            {
                "<leader>gH",
                "<Cmd> '<,'> DiffviewFileHistory <Cr>",
                desc = "Diffview file history",
                mode = { "x" }
            },
            {
                "<leader>gvc",
                "<Cmd> DiffviewClose <Cr>",
                desc = "Close",
                mode = { "n", "x" }
            },
            {
                "<leader>gvf",
                "<Cmd> DiffviewToggleFiles <Cr>",
                desc = "Toggle file",
                mode = { "n", "x" }
            },
            {
                "<leader>gvo",
                "<Cmd> DiffviewOpen <Cr>",
                desc = "Open",
                mode = { "n", "x" }
            },
            {
                "<leader>gvr",
                "<Cmd> DiffviewRefresh <Cr>",
                desc = "Refresh",
                mode = { "n", "x" }
            },
        }
    },
    {
        "nvim-telescope/telescope.nvim",
        optional = true,
        opts = function(_, opts)
            -- All keyed values, safe to extend
            local override_opts = {
                pickers = {
                    git_commits = {
                        mappings = {
                            i = {
                                ["<Cr>"] = diffview_worktree,
                                ["<S-Cr>"] = diffview_commits,
                                -- ["<C-S-Cr>"] = actions.select_default,
                            },
                        },
                    },
                    git_bcommits = {
                        mappings = {
                            i = {
                                ["<Cr>"] = diffview_worktree,
                                ["<S-Cr>"] = diffview_commits,
                                -- ["<C-S-Cr>"] = actions.select_default,
                            },
                        },
                    },
                    git_branches = {
                        mappings = {
                            i = {
                                ["<Cr>"] = diffview_worktree,
                                ["<S-Cr>"] = diffview_branchs,
                                -- ["<C-S-Cr>"] = actions.select_default,
                            },
                        },
                    },
                }
            }
            return vim.tbl_deep_extend("force", opts, override_opts)
        end,
    }
}
