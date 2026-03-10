-- Shop a pop-up for keymaps

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            -- Extract groups names
            local keymap_to_process = {}
            for _, keymap in pairs(require("core.keymaps")) do
                if keymap.hidden ~= nil then
                    local empty_keymap = {
                        keymap[1],
                        mode = keymap.mode,
                        hidden = true
                    }
                    table.insert(keymap_to_process, empty_keymap)
                elseif keymap.group ~= nil then
                    table.insert(keymap_to_process, keymap)
                end
            end

            local default_opts = {
                preset = "modern",
                triggers = {
                    { "g", mode = { "n", "v" } },
                    { "z", mode = { "n", "v" } },
                    { "]", mode = { "n", "v" } },
                    { "[", mode = { "n", "v" } },
                    { "<leader>", mode = { "n", "v" } },
                },
                plugins = {
                    marks = true,     -- shows a list of your marks on ' and `
                    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
                    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
                    -- No actual key bindings are created
                    spelling = {
                        enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                        suggestions = 20, -- how many suggestions should be shown in the list?
                    },

                    presets = {
                        operators = false,    -- adds help for operators like d, y, ...
                        motions = false,      -- adds help for motions
                        text_objects = false, -- help for text objects triggered after entering an operator
                        windows = false,      -- default bindings on <c-w>
                        nav = false,          -- misc bindings to work with windows
                        z = true,             -- bindings for folds, spelling and others prefixed with z
                        g = true,             -- bindings for prefixed with g
                    },
                },
                icons = {
                    mappings = false
                },
                spec = keymap_to_process,
            }
            return default_opts
        end,
        keys = function()
            return {
                {
                    "<leader>?",
                    function()
                        require("which-key").show()
                    end,
                    mode = { "n", "v" },
                    desc = "Show keymaps",
                },
                {
                    "<C-S-/>",
                    function()
                        require("which-key").show()
                    end,
                    mode = { "n", "v", "i" },
                    desc = "Show keymaps",
                },
            }
        end
    }
}
