local hide_in_width = function()
    return vim.fn.winwidth(0) > 80
end

local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { "error", "warn" },
    -- symbols = { error = "E", warn = "W" },
    symbols = { error = " ", warn = " " },
    colored = false,
    update_in_insert = false,
    always_visible = true,
}

local diff = {
    "diff",
    colored = false,
    -- symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
    cond = hide_in_width
}

local mode = {
    "mode",
    fmt = function(str)
        return "--" .. str .. "--"
    end,
}

local filetype = {
    "filetype",
    icons_enabled = false,
    icon = nil,
}

local branch = {
    "branch",
    icons_enabled = true,
    icon = "",
}

local location = {
    "location",
    padding = 0,
}

local fileformat = {
    "fileformat",
    symbols = {
        unix = "LF",
        dos = "CRLF",
        mac = "CR",
        -- unix = '', -- e712
        -- dos = '',  -- e70f
        -- mac = '',  -- e711
    }
}

local filename = {
    "filename",
    -- file_status = false,
    path = 1,
    shorting_target = 40,
    symbols = {
        modified = " ", -- Text to show when the file is modified.
        readonly = " ", -- Text to show when the file is non-modifiable or readonly.
        unnamed = "[No Name]", -- Text to show for unnamed buffers.
    }
}
-- cool function for progress
local progress = function()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")

    local line_ratio = math.ceil(current_line / total_lines * 100)
    return line_ratio .. "%%"

    -- local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
    -- local index = math.ceil(line_ratio * #chars)
    -- return chars[index]
end

local spaces = function()
    return "SPC:" .. vim.api.nvim_get_option_value("shiftwidth", { scope = "local" })
end

return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                icons_enabled = true,
                -- theme = "solarized_light",
                theme = "OceanicNext",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                -- disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
                always_divide_middle = true,
                globalstatus = true,
            },
            sections = {
                lualine_a = { branch, diagnostics },
                lualine_b = { mode, filename },
                lualine_c = {},
                -- lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_x = {
                    diff,
                    "overseer",
                    spaces,
                    fileformat,
                    "encoding",
                    filetype
                },
                lualine_y = { location },
                lualine_z = { progress },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = { progress },
            },
            -- winbar = {
            --     lualine_a = {},
            --     lualine_b = {},
            --     lualine_c = { 'filename' },
            --     lualine_x = {},
            --     lualine_y = {},
            --     lualine_z = {}
            -- },
            -- tabline = {
            --     lualine_a = { 'buffers' },
            --     lualine_b = { 'branch' },
            --     lualine_c = { filename },
            --     lualine_x = {},
            --     lualine_y = {},
            --     lualine_z = { 'tabs' }
            -- },
            extensions = {},
        }
    }
}
