----- Options -----
local options = {
    autoread = true,
    backup = false, -- creates a backup file
    cmdheight = 1,  -- space in the neovim command line for displaying messages
    colorcolumn = { "89" },
    completeopt = { "menuone", "noinsert" },
    conceallevel = 0,  -- 0 = No conceal
    cursorline = true, -- highlight the current line
    expandtab = true,  -- convert tabs to spaces
    exrc = true,       -- source workspace .nvim.lua
    -- fileencoding = "utf-8", -- the encoding written to a file
    -- guifont = "Fira Code, Noto Sans Mono CJK SC, Noto Color Emoji, Noto Emoji, Font Awesome 6 Pro, Font Awesome 6 Brands, FiraCode Nerd Font:h12", -- the font used in graphical neovim applications
    hidden = true,     -- required to keep multiple buffers and open multiple buffers
    hlsearch = true,   -- highlight all matches on previous search pattern
    ignorecase = true, -- ignore case in search patterns
    -- inccommand = "split",   -- Preview substitute in a split. split/nosplit
    list = true,
    listchars = "tab:→ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨",
    -- listchars = "tab: →,nbsp:␣,trail:•,extends:⟩,precedes:⟨,space:⋅,eol:↲",
    -- listchars = "tab:→ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨",
    mouse = "a",             -- allow the mouse to be used in neovim
    number = true,           -- set numbered lines
    numberwidth = 4,         -- set number column width to 4 {default 4}
    pumheight = 10,          -- pop up menu height
    -- relativenumber = true,   -- set relative numbered lines
    scrolloff = 3,           -- number of screen lines to keep above and below the cursor
    sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,terminal",
    shiftwidth = 4,          -- the number of spaces inserted for each indentation
    showbreak = "↪",
    showmode = false,        -- Show current mode like '-- INSERT --'. Display using lualine.
    showtabline = 2,         -- 1:only when more than one tab 2:always show tabs
    sidescrolloff = 8,       -- number of charactersrs to keep around the cursor
    signcolumn = "yes:1",    -- Sign column width "yes:3", "auto:1-2", "auto:3", reserve one col for DAP break point
    smartcase = true,        -- smart case
    smartindent = true,      -- make indenting smarter again
    spell = false,           -- No ignore word with number, only check comments in source code, use 'spellfile', no quick list of all error.  Use cpell.
    spelllang = "en_gb,cjk", --ignore cjk
    spelloptions = "camel",
    splitbelow = true,       -- force all horizontal splits to go below current window
    splitright = true,       -- force all vertical splits to go to the right of current window
    swapfile = false,        -- creates a swapfile
    tabstop = 4,             -- insert 4 spaces for a tab
    termguicolors = true,    -- set term gui colors (most terminals support this)
    timeout = true,
    timeoutlen = 200,        -- Shorten timeout for jk and kj. Which-key adds timeout when pop-up is shown.
    title = true,
    titlestring = "%F - Neovim",
    undofile = false,    -- enable persistent undo
    updatetime = 300,    -- faster completion (4000ms default)
    -- winborder = "rounded",  -- Do not use, added unwanted border for snack dashboard text art, and which key bottom row
    wrap = true,         -- display lines as one long line
    writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- Define what to show in-place of the folded section
vim.opt.fillchars:append("fold: ")

-- This is a global function
function Custom_fold_text()
    local line_text = vim.fn.getline(vim.v.foldstart)
    -- local first_char = string.sub(line_text, 1, 1)
    if string.sub(line_text, 1, 1) ~= " " then
        line_text = " " .. line_text
    end
    local number_of_lines = vim.v.foldend - vim.v.foldstart + 1
    local fill_count = vim.fn.winwidth(0) - string.len(line_text) -
        string.len(number_of_lines) - 15

    return string.format(
        ">%s %s %s lines",
        line_text,
        string.rep(".", fill_count),
        number_of_lines
    )
end

vim.opt.foldtext = "v:lua.Custom_fold_text()"

-- Set filetype of *.tex to 'latex' if no favour specific keywords is found.
-- vim.g.tex_flavor = "plain"  -- Default
-- vim.g.tex_flavor = "context"
vim.g.tex_flavor = "latex"

-- Disable intro message when starting Vim
vim.opt.shortmess:append({ I = true })

vim.opt.iskeyword:append({ "-" })

-- When pressing enter at the end of a comment, Neovim automatically insert the current
-- comment leader for the new line. The following disables this feature.
-- Not work, use autocmd to set this
-- vim.opt.formatoptions:remove('c')
-- vim.opt.formatoptions:remove('r')
-- vim.opt.formatoptions:remove('o')

----- Diagnostic -----
-- Set icons to empty, use line number colour to determine diagnostic error/warning.
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = false,
    severity_sort = true,
    update_in_insert = true,
    signs = {
        -- priority = 1,
        text = {
            -- [vim.diagnostic.severity.ERROR] = "",
            -- [vim.diagnostic.severity.HINT] = Hint = "",
            -- [vim.diagnostic.severity.INFO] = Info = "",
            -- [vim.diagnostic.severity.WARN] =  "",
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.WARN] = "",
        },

        ----- highlight line number only ------
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        },
    },
    float = {
        focusable = false,
        border = "rounded",
        source = true,
        header = "",
        prefix = "-",
    },
})

---------- Setup UI ----------
-- Nuclear method. Override builtin to set the default LSP floating window style
-- Set style for individual type of pop-up/float window
-- https://neovim.io/doc/user/api.html#nvim_open_win()

-- local default_handler = vim.lsp.util.open_floating_preview
-- vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
--     opts = opts or {}
--     opts.border = opts.border or "rounded"
--     opts.focusable = opts.focusable or false
--     return default_handler(contents, syntax, opts, ...)
-- end

-- Disable lsp log
vim.lsp.log.set_level(vim.log.levels.OFF)
