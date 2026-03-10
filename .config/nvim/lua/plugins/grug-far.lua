return {
    "MagicDuck/grug-far.nvim",
    opts = {
        engines = {
            ripgrep = {
                extraArgs = "--max-filesize 2M --trim",
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

        -- shortcuts for the actions you see at the top of the buffer
        -- set to '' or false to unset. Mappings with no normal mode value will be removed from the help header
        -- you can specify either a string which is then used as the mapping for both normal and insert mode
        -- or you can specify a table of the form { [mode] = <lhs> } (e.g. { i = '<C-enter>', n = '<localleader>gr'})
        -- it is recommended to use <localleader> though as that is more vim-ish
        -- see https://learnvimscriptthehardway.stevelosh.com/chapters/11.html#local    leader
        keymaps = {
            replace = { n = "<localleader>r" },
            -- qflist = { n = "<localleader>q" },
            qflist = false,
            syncLocations = { n = "<localleader>s" }, -- Sync all
            -- syncLine = { n = "<localleader>l" },
            syncLine = false,
            close = { n = "<localleader>c" },
            historyOpen = { n = "<localleader>h" },
            historyAdd = { n = "<localleader>a" },
            refresh = { n = "<localleader>r" },
            openLocation = { n = "<localleader>o" },
            openNextLocation = { n = "<down>" },
            openPrevLocation = { n = "<up>" },
            gotoLocation = { n = "<enter>" },
            pickHistoryEntry = { n = "<enter>" },
            abort = { n = "<localleader>b" },
            help = { n = "<localleader>?" },
            -- toggleShowCommand = { n = "<localleader>p" },
            toggleShowCommand = false,
            -- swapEngine = { n = "<localleader>e" },
            swapEngine = false,
            -- previewLocation = { n = "<localleader>i" },
            previewLocation = false,
            -- swapReplacementInterpreter = { n = "<localleader>x" },
            swapReplacementInterpreter = false,
            -- applyNext = { n = "<localleader>j" },
            applyNext = { n = "<localleader>l" },
            -- applyPrev = { n = "<localleader>k" },
            applyPrev = false,
        },
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
