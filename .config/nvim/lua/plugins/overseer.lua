return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerSaveBundle",
            "OverseerLoadBundle",
            "OverseerDeleteBundle",
            "OverseerRunCmd",
            "OverseerRun",
            "OverseerInfo",
            "OverseerBuild",
            "OverseerQuickAction",
            "OverseerTaskAction",
            "OverseerClearCache"
        },
        opts = {
            dap = false,  -- Do not load dap until it is really needed.
            -- strategy = {
            --     "toggleterm",
            --     -- load your default shell before starting the task
            --     use_shell = true,
            --     -- overwrite the default toggleterm "direction" parameter
            --     direction = nil,
            --     -- overwrite the default toggleterm "highlights" parameter
            --     highlights = nil,
            --     -- overwrite the default toggleterm "auto_scroll" parameter
            --     auto_scroll = nil,
            --     -- have the toggleterm window close and delete the terminal buffer
            --     -- automatically after the task exits
            --     close_on_exit = false,
            --     -- have the toggleterm window close without deleting the terminal buffer
            --     -- automatically after the task exits
            --     -- can be "never, "success", or "always". "success" will close the window
            --     -- only if the exit code is 0.
            --     quit_on_exit = "never",
            --     -- open the toggleterm window when a task starts
            --     open_on_start = true,
            --     -- mirrors the toggleterm "hidden" parameter, and keeps the task from
            --     -- being rendered in the toggleable window
            --     hidden = false,
            --     -- command to run when the terminal is created. Combine with `use_shell`
            --     -- to run a terminal command before starting the task
            --     on_create = nil,
            -- },
            templates = {
                -- "builtin",  -- 'Shell' task etc.
                "build.cpp_build",
                "build.md_to_beamer",
                "build.md_to_pdf",
                "build.md_to_revealjs",
                "build.run_script",
            },
            -- actions = {
            --     ["My custom action"] = {
            --         desc = "This is an optional description. It may be omitted.",
            --         -- Optional function that will determine when this action is available
            --         condition = function(task)
            --             if task.name == "foobar" then
            --                 return true
            --             else
            --                 return false
            --             end
            --         end,
            --         run = function(task)
            --             -- Your custom logic here
            --         end,
            --     },

            --     -- Disable built-in actions by setting them to 'false'
            --     watch = false,
            -- },
            -- -- You can optionally add keymaps to run your action in the task list
            -- -- It will always be available in the "RunAction" menu, but it may be
            -- -- worth mapping it directly if you use it often.
            -- task_list = {
            --     bindings = {
            --         ['P'] = '<Cmd> OverseerQuickAction My custom action <CR>',
            --     }
            -- }
        },
        keys = {
            {
                "<leader>;i",
                "<Cmd> OverseerInfo <Cr>",
                desc = "Info",
                mode = { "n", "x" }
            },
            {
                "<leader>;l",
                "<Cmd> OverseerToggle <Cr>",
                desc = "List status",
                mode = { "n", "x" }
            },
            {
                "<leader>;r",
                "<Cmd> OverseerRun <Cr>",
                desc = "Run",
                mode = { "n", "x" }
            },
            {
                "<leader>;R",
                "<Cmd> OverseerRunCmd <Cr>",
                desc = "Run shell command",
                mode = { "n", "x" }
            },
        }
    },
}
