return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerRun",
            "OverseerInfo",
            "OverseerShell",
            "OverseerTaskAction",
            "OverseerRestartLast",
        },
        config = function()
            vim.api.nvim_create_user_command("OverseerRestartLast", function()
                local overseer = require("overseer")
                local task_list = require("overseer.task_list")
                local tasks = overseer.list_tasks({
                    status = {
                        overseer.STATUS.SUCCESS,
                        overseer.STATUS.FAILURE,
                        overseer.STATUS.CANCELED,
                    },
                    sort = task_list.sort_finished_recently
                })
                if vim.tbl_isempty(tasks) then
                    vim.notify("No tasks found", vim.log.levels.WARN)
                else
                    local most_recent = tasks[1]
                    print(most_recent.name)
                    overseer.run_action(most_recent, "restart")
                end
            end, {})
        end,
        opts = {
            -- Patch nvim-dap to support preLaunchTask and postDebugTask
            dap = false, -- Do not load dap until it is really needed.
        },
        keys = {
            {
                "<leader>so",
                "<Cmd> OverseerToggle <Cr>",
                desc = "Overseer(task)",
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
                "<Cmd> OverseerRestartLast <Cr>",
                desc = "Restart last",
                mode = { "n", "x" }
            },
        }
    },
}
