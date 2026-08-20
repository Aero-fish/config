return {
    "zgs225/pi2.nvim",

    -- render-markdown.nvim powers the default chat-history renderer
    -- (render.engine = "render-markdown"); img-clip.nvim is optional and
    -- required only for `:PiPasteImage` (clipboard image paste).
    dependencies = {
        "MeanderingProgrammer/render-markdown.nvim",
        "HakonHarnes/img-clip.nvim",
    },
    opts = {
        cli = {
            args = { "--thinking", "off" },
        },
        panels = {
            history = { title = "Pi agent" },
            prompt = { title = "prompt", bash_title = "bash" },
            attachments = { title = "attached" },
        },
        expand_startup_details = false,
        layout = {
            side = {
                width = 0.4
            },
        },
    },
    cmd = {
        "Pi",
        "PiAbort",
        "PiAbortBash",
        "PiAttachImage",
        "PiAttention",
        "PiCompact",
        "PiContinue",
        "PiCycleModel",
        "PiCycleThinking",
        "PiDiff",
        "PiNewSession",
        "PiResume",
        "PiSelectModel",
        "PiSelectModelAll",
        "PiSelectThinking",
        "PiSendMention",
        "PiSessionName",
        "PiSessions",
        "PiSessionStats",
        "PiStop",
        "PiToggleAutoCompaction",
        "PiToggleChat",
        "PiToggleDebug",
        "PiToggleLayout",
        "PiToggleStartupDetails",
        "PiToggleThinking",
        "PiTree",
    },
    keys = {
        {
            "<leader>c",
            function()
                if vim.bo.filetype == "pi-chat-history" or vim.bo.filetype == "pi-chat-prompt" then
                    vim.cmd("PiStop")
                else
                    vim.cmd("close")
                end
            end,
            desc = "Close window",
            mode = { "n" }
        },
        {
            "<C-w>",
            function()
                if vim.bo.filetype == "pi-chat-history" or vim.bo.filetype == "pi-chat-prompt" then
                    require("pi").toggle()
                else
                    vim.cmd("bdelete")
                end
            end,
            desc = "Delete buffer",
            mode = { "n", "x", "i", "t" }
        },
        {
            "<C-S-w>",
            function()
                if vim.bo.filetype == "pi-chat-history" or vim.bo.filetype == "pi-chat-prompt" then
                    require("pi").toggle()
                else
                    vim.cmd("bdelete!")
                end
            end,
            desc = "Delete buffer!",
            mode = { "n", "x", "i", "t" }
        },
        {
            "<leader>c",
            function()
                if vim.bo.filetype == "pi-chat-history" or vim.bo.filetype == "pi-chat-prompt" then
                    require("pi").toggle()
                else
                    vim.cmd("close")
                end
            end,
            desc = "Close window",
            mode = { "n", "x" }
        },
        {
            "<leader>z",
            function()
                require("pi").toggle()
            end,
            desc = "AI prompt",
            mode = { "n", "x" }
        },
        {
            "<leader><leader>z",
            "<Cmd> PiSendMention <Cr>",
            desc = "AI send mention",
            mode = { "n", "x" }
        },
        {
            "<leader>Za",
            "<Cmd> PiAbort <Cr>",
            desc = "Abort agent operation",
            mode = { "n", "x" }
        },
        {
            "<leader>Zc",
            "<Cmd> PiContinue <Cr>",
            desc = "Continue most recent",
            mode = { "n", "x" }
        },
        {
            "<leader>Zn",
            "<Cmd> PiNewSession <Cr>",
            desc = "New session",
            mode = { "n", "x" }
        },
        {
            "<leader>Zr",
            "<Cmd> PiResume <Cr>",
            desc = "Resume a past session",
            mode = { "n", "x" }
        },
        {
            "<leader>Zs",
            "<Cmd> PiSessions <Cr>",
            desc = "List sessions",
            mode = { "n", "x" }
        },
        {
            "<leader>ZS",
            "<Cmd> PiSessionName <Cr>",
            desc = "Set session name",
            mode = { "n", "x" }
        },
        {
            "<leader>Zt",
            "<Cmd> PiToggleThinking <Cr>",
            desc = "Toggle thinking",
            mode = { "n", "x" }
        },
    },
}
