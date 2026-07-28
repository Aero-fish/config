-- Timeout is set in 'options.lua', which can be very short. Need to press the map very fast.
return {
    "MagicDuck/grug-far.nvim",
    opts = {
        engines = {
            ripgrep = {
                extraArgs = "--max-filesize 2M",
            }
        },

        -- specifies the command to run (with `vim.cmd(...)`) in order to create
        -- the window in which the grug-far buffer will appear
        -- ex (horizontal bottom right split): 'botright split'
        -- ex (open new tab): 'tab split'
        -- Default 'vsplit'
        windowCreationCommand = "botright split",

        -- whether or not to make a transient buffer which is both unlisted and fully deletes itself when not in use
        transient = true,
    },
    keys = {
        {
            "<leader>rO",
            function()
                require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
            end,
            mode = "n",
            desc = "Open (rg & diff)"
        },
        {
            "<leader>rW",
            function()
                require("grug-far").open({
                    prefills = {
                        search = vim.fn.expand("<cword>"),
                        paths = vim.fn.expand("%")
                    }
                })
            end,
            mode = "n",
            desc = "Word (rg & diff)"
        },
        {
            "<leader>rS",
            function()
                require("grug-far").with_visual_selection({
                    prefills = {
                        paths = vim.fn.expand("%")
                    }
                })
            end,
            mode = "x",
            desc = "Selection (rg & diff)"
        },
        {
            "<leader>Ro",
            function()
                require("grug-far").open()
            end,
            mode = "n",
            desc = "Open"
        },
        {
            "<leader>Rw",
            function()
                require("grug-far").open({
                    prefills = { search = vim.fn.expand("<cword>") }
                })
            end,
            mode = "n",
            desc = "Word"
        },
        {
            "<leader>Rs",
            function()
                require("grug-far").with_visual_selection()
            end,
            mode = "x",
            desc = "Selection"
        },
    }
}
