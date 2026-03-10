return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            local overseer_ok, overseer = pcall(require, "overseer")
            if overseer_ok then
                overseer.enable_dap()
            end

            local dapui_ok, dapui = pcall(require, "dapui")
            if dapui_ok then
                dap.listeners.before.attach.dapui_config = dapui.open
                dap.listeners.before.launch.dapui_config = dapui.open
                dap.listeners.before.event_terminated.dapui_config = dapui.close
                dap.listeners.before.event_exited.dapui_config = dapui.close
            end
        end,
        keys = {
            {
                "<F3>",
                function() require("dap").run_last() end,
                desc = "Run last",
                mode = { "n", "x" }
            },
            {
                "<F4>",
                function() require("dap").pause() end,
                desc = "Pause",
                mode = { "n", "x" }
            },
            {
                "<F5>",
                function() require("dap").continue() end,
                desc = "Run/continue",
                mode = { "n", "x" }
            },
            {
                "<F6>",
                function() require("dap").terminate() end,
                desc = "Terminate",
                mode = { "n", "x" }
            },
            {
                "<F8>",
                function() require("dap").step_back() end,
                desc = "Step back",
                mode = { "n", "x" }
            },
            {
                "<F9>",
                function() require("dap").step_into() end,
                desc = "Step into",
                mode = { "n", "x" }
            },
            {
                "<F10>",
                function() require("dap").step_over() end,
                desc = "Step over",
                mode = { "n", "x" }
            },
            {
                "<F11>",
                function() require("dap").step_out() end,
                desc = "Step out",
                mode = { "n", "x" }
            },
            {
                "<F12>",
                function() require("dap").run_to_cursor() end,
                desc = "Run to cursor",
                mode = { "n", "x" }
            },

            -- Disabled builtin break point mapping, use 'persistent-breakpoints.nvim'
            -- {
            --     "<leader>B",
            --     function() require("dap").toggle_breakpoint() end,
            --     desc = "Toggle breakpoint",
            --     mode = { "n", "x" }
            -- },

            -- <leader>d = Debug+
            -- {
            --     "<leader>db",
            --     function() require("dap").toggle_breakpoint() end,
            --     desc = "Toggle breakpoint",
            --     mode = { "n", "x" }
            -- },
            -- {
            --     "<leader>dC",
            --     function() require("dap").clear_breakpoints() end,
            --     desc = "Clear breakpoints",
            --     mode = { "n", "x" }
            -- },

            {
                "<leader>dc",
                function()
                    require("dap").set_breakpoint(vim.fn.input("[Condition] > "))
                end,
                desc = "Conditional breakpoint",
                mode = { "n", "x" }
            },
            {
                "<leader>de",
                function() require("dap").set_exception_breakpoints() end,
                desc = "Breakpoint on exception",
                mode = { "n", "x" }
            },
            {
                "<leader>dl",
                function()
                    require("dap").list_breakpoints()
                    local trouble_ok, trouble = pcall(require, "trouble")
                    if trouble_ok then
                        trouble.open("quickfix")
                    else
                        vim.cmd("copen")
                    end
                end,
                desc = "List breakpoints",
                mode = { "n", "x" }
            },

            -- <leader>dr = Debug+/Run
            {
                "<leader>drb",
                function()
                    require("dap").step_back()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Step back",
                mode = { "n", "x" }
            },
            {
                "<leader>drc",
                function()
                    require("dap").continue()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Run/Continue",
                mode = { "n", "x" }
            },
            {
                "<leader>drC",
                function()
                    require("dap").run_to_cursor()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Run to cursor",
                mode = { "n", "x" }
            },
            {
                "<leader>dri",
                function()
                    require("dap").step_into()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Step into",
                mode = { "n", "x" }
            },
            {
                "<leader>drl",
                function()
                    require("dap").run_last()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Run last",
                mode = { "n", "x" }
            },
            {
                "<leader>dro",
                function()
                    require("dap").step_over()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Step over",
                mode = { "n", "x" }
            },
            {
                "<leader>drO",
                function()
                    require("dap").step_out()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Step out <11>",
                mode = { "n", "x" }
            },
            {
                "<leader>drp",
                function() require("dap").pause() end,
                desc = "Pause",
                mode = { "n", "x" }
            },
            {
                "<leader>drt",
                function() require("dap").terminate() end,
                desc = "Terminate",
                mode = { "n", "x" }
            },
            {
                "<leader>drr",
                function()
                    require("dap").restart()
                    -- if which_key_ok then
                    --     which_key.show({
                    --         keys = "<leader>dr",
                    --         loop = true
                    --     })
                    -- end
                end,
                desc = "Restart",
                mode = { "n", "x" }
            },
        }
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        config = function()
            require("dap-python").setup("python3")
        end,
    },
    "nvim-neotest/nvim-nio", -- 'dapui' dependency
    {
        "rcarriga/nvim-dap-ui",
        opts = {
            controls = {
                element = "repl",
                enabled = true,
                icons = {
                    disconnect = "",
                    pause = "󱊮",
                    play = "󱊯",
                    run_last = "󱊭",
                    step_back = "󱊲",
                    step_into = "󱊳",
                    step_out = "󱊵",
                    step_over = "󱊴",
                    terminate = "󱊰"
                }
            },
            element_mappings = {},
            expand_lines = true,
            floating = {
                border = "rounded",
                mappings = {
                    close = { "q", "<Esc>" }
                }
            },
            force_buffers = true,
            icons = {
                collapsed = "",
                current_frame = "",
                expanded = ""
            },
            layouts = {
                {
                    elements = {
                        {
                            id = "scopes",
                            size = 0.25
                        },
                        {
                            id = "breakpoints",
                            size = 0.25
                        },
                        {
                            id = "stacks",
                            size = 0.25
                        },
                        {
                            id = "watches",
                            size = 0.25
                        }
                    },
                    position = "left",
                    size = 40
                },
                {
                    elements = {
                        {
                            id = "repl",
                            size = 0.5
                        },
                        {
                            id = "console",
                            size = 0.5
                        }
                    },
                    position = "bottom",
                    size = 10
                }
            },
            mappings = {
                edit = "e",
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                repl = "r",
                toggle = "t"
            },
            render = {
                indent = 1,
                max_value_lines = 100
            }
        },
        config = function(_, opts)
            require("dapui").setup(opts)
        end,
        keys = {
            {
                "<leader>tD",
                function() require("dapui").toggle() end,
                desc = "DAP UI",
                mode = { "n", "x" }
            }
        }
    },
    {
        "Weissle/persistent-breakpoints.nvim",
        event = { "BufReadPost" },
        opts = {
            -- save_dir = vim.fn.stdpath('data') .. '/nvim_checkpoints',

            -- when to load the breakpoints? "BufReadPost" is recommanded.
            load_breakpoints_event = { "BufReadPost" }

            -- record the performance of different function.
            -- run :lua require('persistent-breakpoints.api').print_perf_data() to see the result.
            -- perf_record = false,

            -- perform callback when loading a persisted breakpoint
            --- @param opts DAPBreakpointOptions options used to create the breakpoint ({condition, logMessage, hitCondition})
            --- @param buf_id integer the buffer the breakpoint was set on
            --- @param line integer the line the breakpoint was set on
            -- on_load_breakpoint = nil,
        },
        keys = {
            {
                "<leader>B",
                function()
                    require("persistent-breakpoints.api").toggle_breakpoint()
                end,
                desc = "Toggle breakpoint",
                mode = { "n", "x" }
            },
            {
                "<leader>db",
                function()
                    require("persistent-breakpoints.api").toggle_breakpoint()
                end,
                desc = "Toggle breakpoint",
                mode = { "n", "x" }
            },
            {
                "<leader>dC",
                function()
                    require("persistent-breakpoints.api").clear_all_breakpoints()
                end,
                desc = "Clear breakpoints",
                mode = { "n", "x" }
            },
        }
    }
}
