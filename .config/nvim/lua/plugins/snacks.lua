local filetypes_need_close_window = { "qf", "help", "man", "lspinfo" }
local del_cmd = function(force)
    local window_count = 0
    for _ in pairs(vim.api.nvim_list_wins()) do
        window_count = window_count + 1
        if window_count > 1 then
            break
        end
    end

    if window_count <= 1 then
        require("snacks").bufdelete({ force = force })
        return
    end

    if vim.tbl_contains(filetypes_need_close_window, vim.bo.filetype) then
        vim.api.nvim_win_close(0, true)
        return
    else
        require("snacks").bufdelete({ force = force })
    end
end

local del_cmd_force = function()
    del_cmd(true)
end

local hydra = [[
    *   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣭⣿⣶⣿⣦⣼⣆         *
    *    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       *
    *          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷⠄⠄⠄⠄⠻⠿⢿⣿⣧⣄     *
    *           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    *
    *          ⢠⣿⣿⣿⠈  ⠡⠌⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   *
    *   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘⠄ ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  *
    *  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   *
    * ⣠⣿⠿⠛⠄⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  *
    * ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇⠄⠛⠻⢷⣄ *
    *      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     *
    *       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     *
    *     ⢰⣶  ⣶ ⢶⣆⢀⣶⠂⣶⡶⠶⣦⡄⢰⣶⠶⢶⣦  ⣴⣶     *
    *     ⢸⣿⠶⠶⣿ ⠈⢻⣿⠁ ⣿⡇ ⢸⣿⢸⣿⢶⣾⠏ ⣸⣟⣹⣧    *
    *     ⠸⠿  ⠿  ⠸⠿  ⠿⠷⠶⠿⠃⠸⠿⠄⠙⠷⠤⠿⠉⠉⠿⠆   *
    ]]

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = {
            enabled = true,
            size = 2 * 1024 * 1024,
            -- notify = false,
        },
        dashboard = {
            enabled = true,
            preset = {
                keys = {
                    {
                        icon = " ",
                        key = "f",
                        desc = "Find File",
                        action = ":lua Snacks.dashboard.pick('files')"
                    },
                    {
                        icon = " ",
                        key = "n",
                        desc = "New File",
                        action = "<Cmd> ene <BAR> startinsert <CR>"
                    },
                    {
                        icon = " ",
                        key = "g",
                        desc = "Find Text",
                        action = ":lua Snacks.dashboard.pick('live_grep')"
                    },
                    {
                        icon = " ",
                        key = "r",
                        desc = "Recent Files",
                        action = ":lua Snacks.dashboard.pick('oldfiles')"
                    },
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action =
                        -- ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})"
                        "<Cmd> cd ~/.config/nvim | e ~/.config/nvim/init.lua <CR>"
                    },
                    {
                        icon = " ",
                        key = "r",
                        desc = "Restore Session",
                        section = "session"
                    },
                    -- {
                    --     icon = "󰒲 ",
                    --     key = "L",
                    --     desc = "Lazy",
                    --     action = ":Lazy",
                    --     enabled = package.loaded.lazy ~= nil
                    -- },
                    { icon = " ", key = "q", desc = "Quit", action = "<Cmd> qa<CR>" },

                },
                header = hydra,
            },
            formats = {
                footer = { "%s", align = "center" },
                header = { "%s", align = "center" },
            },
            sections = {
                {
                    section = "terminal",
                    cmd = "fortune -s | cowsay",
                    hl = "header",
                    height = 15,
                    padding = 1,
                    indent = 8
                },
                -- { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
            },
        },
        -- dim: Only disable highlight for irrelevant text. Twinight set them to light grey.
        -- Indent: does not show leading tab
        -- scroll = { enabled = true },  -- smooth scrolling for mouse
        scope = { enabled = true } -- [i and ]i
    },
    keys = {
        {
            "<C-w>",
            del_cmd,
            desc = "Delete buffer",
            mode = { "n", "x", "i", "t" }
        },
        {
            "<C-S-w>",
            del_cmd_force,
            desc = "Delete buffer!",
            mode = { "n", "x", "i", "t" }
        },
        {
            "<leader>ba",
            function()
                require("snacks").bufdelete.all()
            end,
            desc = "Delete all",
            mode = { "n", "x" }
        },
        {
            "<leader>bA",
            function()
                require("snacks").bufdelete.all({ force = true })
            end,
            desc = "Delete all!",
            mode = { "n", "x" }
        },
        { "<leader>bd", del_cmd, desc = "Delete buffer", mode = { "n", "x" } },
        {
            "<leader>bD",
            del_cmd_force,
            desc = "Delete buffer!",
            mode = { "n", "x" }
        },
        {
            "<leader>bo",
            function()
                require("snacks").bufdelete.other()
            end,
            desc = "Delete others",
            mode = { "n", "x" }
        },
        {
            "<leader>bO",
            function()
                require("snacks").bufdelete.other({ force = true })
            end,
            desc = "Delete others!",
            mode = { "n", "x" }
        },
    }
}
