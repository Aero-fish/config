-- Terminal manager
-- Not used, not using lf.nvim any more

return {
    "akinsho/toggleterm.nvim",
    opts = {
        -- size can be a number or function which is passed the current terminal
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,

        -- open_mapping = [[<c-\>]],
        open_mapping = "<c-`>",

        shade_terminals = false,
        -- direction = 'vertical' | 'horizontal' | 'tab' | 'float',
        direction = "tab",

        insert_mappings = true,   -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals

        close_on_exit = true,     -- close the terminal window when the process exits

        auto_scroll = true,       -- automatically scroll to the bottom on terminal output

        -- This field is only relevant if direction is set to 'float'
        float_opts = {
            -- The border key is *almost* the same as 'nvim_open_win'
            -- see :h nvim_open_win for details on borders however
            -- the 'curved' border is a custom border type
            -- not natively supported but implemented in this plugin.
            -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
            border = "curved"
            -- like `size`, width and height can be a number or function which is passed the current terminal
            -- width = <value>,
            -- height = <value>,
            -- winblend = 3,
            -- zindex = <value>,
        },

        -- winbar = {
        --     enabled = false,
        --     name_formatter = function(term) --  term: Terminal
        --         return term.name
        --         end
        -- },
    },
    keys = function()
        local trim_spaces = false
        return {
            {
                "<leader>S",
                function()
                    require("toggleterm").send_lines_to_terminal("single_line",
                        trim_spaces,
                        { args = vim.v.count })
                end,
                desc = "Send cur line to terminal",
                mode = "n"
            },
            {
                "<leader>S",
                function()
                    require("toggleterm").send_lines_to_terminal("visual_lines",
                        trim_spaces,
                        { args = vim.v.count })
                end,
                desc = "Send sel lines to terminal",
                mode = "x"
            }

        }
    end
}
