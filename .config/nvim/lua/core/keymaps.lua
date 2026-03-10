-- Modes
--   normal_mode, visual_mode, select_mode and Operator-pending = "",
--   normal_mode = "n",
--   insert_mode = "i",
--   command_mode = "c",
--   visual_mode and select_mode = "v",
--   visual_mode = "x",
--   select_mode = "s",
--   Operator-pending = "o",
--   term_mode = "t",
--   insert_mode, command_mode and language mappings = "l",

-- Use ":h keycodes" to check names of special keys

---------- Key mappings ----------

-- Mode shorthands
local n = "n"
local x = "x"
local i = "i"
local nx = { "n", "x" }
local nxi = { "n", "x", "i" }
local nxit = { "n", "x", "i", "t" }
local ni = { "n", "i" }
local xi = { "x", "i" }

local default_keymaps = {

    ---------- Key chords ----------
    -- Disable space in normal and visual mode.
    -- Do not set hidden flag. Which-key will not show panel as space is the leader key.
    { "<Space>", "<Nop>", mode = { "n", "v" } },

    -- Swap screen line and line
    {
        "j",
        "v:count ? 'j' : 'gj'",
        desc = "Next screen line",
        mode = nx,
        expr = true,
        hidden = true
    },
    {
        "k",
        "v:count ? 'k' : 'gk'",
        desc = "Prev screen line",
        mode = nx,
        expr = true,
        hidden = true
    },
    {
        "gj",
        "j",
        desc = "Next line",
        mode = nx,
        hidden = true
    },
    {
        "gk",
        "k",
        desc = "Prev line",
        mode = nx,
        hidden = true
    },

    {
        "<C-q>",
        "<C-q>",
        desc = "Next key literally",
        mode = i,
    },

    -- Hide for plugin such as flit, override for which key spec does not work well
    {
        "f",
        mode = nx,
        hidden = true
    },
    {
        "F",
        mode = nx,
        hidden = true
    },
    {
        "t",
        mode = nx,
        hidden = true
    },
    {
        "T",
        mode = nx,
        hidden = true
    },
    {
        "<Up>",
        mode = i,
        hidden = true
    },
    {
        "<Down>",
        mode = i,
        hidden = true
    },
    {
        "<Left>",
        mode = i,
        hidden = true
    },
    {
        "<Right>",
        mode = i,
        hidden = true
    },
    {
        "<Tab>",
        mode = i,
        hidden = true
    },
    {
        "<S-Tab>",
        mode = i,
        hidden = true
    },
    {
        "<C-u>",
        mode = i,
        hidden = true
    },
    {
        "<C-d>",
        mode = i,
        hidden = true
    },
    {
        "<C-e>",
        mode = i,
        hidden = true
    },
    {
        "<C-j>",
        mode = i,
        hidden = true
    },
    {
        "<C-k>",
        mode = i,
        hidden = true
    },
    {
        "<C-Space>",
        mode = i,
        hidden = true
    },

    -- Nvim builtin
    { "<Space>", group = "More", mode = nx },
    { "g", group = "g commands", mode = nx },
    { "z", group = "z commands", mode = nx },
    { "]", group = "] commands", mode = nx },
    { "[", group = "[ commands", mode = nx },

    {
        "}",
        "}",
        desc = "Next Paragraph",
        mode = nx,
    },
    {
        "{",
        "{",
        desc = "Prev Paragraph",
        mode = nx,
    },

    -- Paste without saving deleted content
    {
        "p",
        "pgvy`>",
        desc = "paste",
        mode = x,
        hidden = true
    },

    -- Switch windows
    { "<C-h>", "<C-w>h", desc = "Window left", mode = nx },
    { "<C-l>", "<C-w>l", desc = "Window right", mode = nx },
    { "<C-j>", "<C-w>j", desc = "Window down", mode = nx },
    { "<C-k>", "<C-w>k", desc = "Window up", mode = nx },
    { "<C-h>", "<C-o><C-w>h", desc = "Window left", mode = i },
    { "<C-l>", "<C-o><C-w>l", desc = "Window right", mode = i },
    { "<C-j>", "<C-o><C-w>j", desc = "Window down", mode = i },
    { "<C-k>", "<C-o><C-w>k", desc = "Window up", mode = i },

    -- Select all
    { "<C-a>", "gg0VG", desc = "Select all", mode = n },
    { "<C-a>", "<Esc>gg0VG", desc = "Select all", mode = xi },

    -- Save
    { "<C-s>", "<Cmd> w <Cr>", desc = "Save file", mode = nxi },
    { "<C-S-s>", "<Cmd> wa <Cr>", desc = "Save all", mode = nxi },

    -- Copy/Cut
    { "<C-c>", '"+y', desc = "Copy", mode = x },
    { "<C-x>", '"+d', desc = "Cut", mode = x },

    -- Paste
    { "<C-v>", '"+p', desc = "Paste", mode = nx },
    { "<C-v>", '<C-o>"+p', desc = "Paste", mode = i },

    -- Close buffer
    { "<C-w>", "<Cmd> bdelete <Cr>", desc = "Delete buffer", mode = nxit },
    { "<C-S-w>", "<Cmd> bdelete! <Cr>", desc = "Delete buffer!", mode = nxit },

    -- Undo. Override terminal suspend key binding
    { "<C-z>", "u", desc = "Undo", mode = n },
    { "<C-z>", "<C-c>u", desc = "Undo", mode = x },
    { "<C-z>", "<C-o>u", desc = "Undo", mode = i },

    -- Resize with arrows
    { "<C-Up>", "<Cmd> resize +2 <Cr>", desc = "Window height +2", mode = nx },
    { "<C-Down>", "<Cmd> resize -2 <Cr>", desc = "Window height -2", mode = nx },
    {
        "<C-Right>",
        "<Cmd> vertical resize +2 <Cr>",
        desc = "Window width +2",
        mode = nx
    },
    {
        "<C-Left>",
        "<Cmd> vertical resize -2 <Cr>",
        desc = "Window width -2",
        mode = nx
    },

    -- Switch tab
    {
        "<C-Tab>",
        "<Cmd> tabnext <Cr>",
        desc = "Next tab",
        mode = nx
    },
    {
        "<C-S-Tab>",
        "<Cmd> tabprevious <Cr>",
        desc = "Prev tab",
        mode = nx
    },

    -- Move line up/down, indent/outdent
    {
        "<A-j>",
        "<Cmd> move .+1 <Cr>",
        desc = "Move line up",
        mode = ni
    },
    {
        "<A-k>",
        "<Cmd> move .-2 <Cr>",
        desc = "Move line down",
        mode = ni
    },
    {
        "<A-l>",
        ">>",
        desc = "Indent line",
        mode = n
    },
    {
        "<A-h>",
        "<<",
        desc = "Outdent line",
        mode = n
    },
    {
        "<A-j>",
        ":move '>+1<Cr>gv-gv",
        desc = "Move line up",
        silent = true,
        mode = x
    },
    {
        "<A-k>",
        ":move '<-2<Cr>gv-gv",
        desc = "Move line down",
        silent = true,
        mode = x
    },
    {
        "<A-l>",
        ">gv",
        desc = "Indent line",
        silent = true,
        mode = x
    },
    {
        "<A-h>",
        "<gv",
        desc = "Outdent line",
        silent = true,
        mode = x
    },
    {
        ">",
        ">gv",
        silent = true,
        desc = "Indent lines",
        mode = x
    },
    {
        "<",
        "<gv",
        silent = true,
        desc = "Outdent line",
        mode = x
    },
    {
        "<Tab>",
        ">gv",
        silent = true,
        desc = "Indent line",
        mode = x
    },
    {
        "<S-Tab>",
        "<gv",
        silent = true,
        desc = "Outdent line",
        mode = x
    },

    {
        "<A-l>",
        "<C-o>>>",
        silent = true,
        desc = "Indent line",
        mode = i
    },
    {
        "<A-h>",
        "<C-o><<",
        silent = true,
        desc = "Outdent line",
        mode = i
    },

    -- Navigate tabs
    {
        "<C-1>",
        "<Cmd> 1tabnext <Cr>",
        desc = "Goto tab 1",
        mode = nxi
    },
    {
        "<C-2>",
        "<Cmd> 2tabnext <Cr>",
        desc = "Goto tab 2",
        mode = nxi
    },
    {
        "<C-3>",
        "<Cmd> 3tabnext <Cr>",
        desc = "Goto tab 3",
        mode = nxi
    },
    {
        "<C-4>",
        "<Cmd> 4tabnext <Cr>",
        desc = "Goto tab 4",
        mode = nxi
    },
    {
        "<C-5>",
        "<Cmd> 5tabnext <Cr>",
        desc = "Goto tab 5",
        mode = nxi
    },
    {
        "<C-6>",
        "<Cmd> 6tabnext <Cr>",
        desc = "Goto tab 6",
        mode = nxi
    },
    {
        "<C-7>",
        "<Cmd> 7tabnext <Cr>",
        desc = "Goto tab 7",
        mode = nxi
    },
    {
        "<C-8>",
        "<Cmd> 8tabnext <Cr>",
        desc = "Goto tab 8",
        mode = nxi
    },
    {
        "<C-9>",
        "<Cmd> 9tabnext <Cr>",
        desc = "Goto tab 9",
        mode = nxi
    },
    {
        "<C-0>",
        "<Cmd> 10tabnext <Cr>",
        desc = "Goto tab 10",
        mode = nxi
    },

    {
        "<C-S-,>",
        "<Cmd> -tabmove <Cr>",
        desc = "Move tab left",
        mode = nxi
    },
    {
        "<C-S-.>",
        "<Cmd> +tabmove <Cr>",
        desc = "Move tab right",
        mode = nxi
    },
    {
        "<C-t>",
        "<Cmd> tabnew <Cr>",
        desc = "New tab",
        mode = nxi
    },

    {
        "<C-S-l>",
        "<Cmd> tabnext +1  <Cr>",
        desc = "Goto next tab",
        mode = nxi
    },
    {
        "<C-S-h>",
        "<Cmd> tabnext -1  <Cr>",
        desc = "Goto prev tab",
        mode = nxi
    },

    -- Navigate buffers
    {
        "<C-S-j>",
        "<Cmd> bnext <Cr>",
        desc = "Goto next buffer",
        mode = nxi
    },
    {
        "<C-S-k>",
        "<Cmd> bprevious <Cr>",
        desc = "Goto prev buffer",
        mode = nxi
    },

    -- Misc
    {
        "]c",
        "g,",
        desc = "Newer edit pos",
        mode = n
    },
    {
        "[c",
        "g;",
        desc = "Older edit pos",
        mode = n
    },
    {
        "]q",
        "<Cmd> cnext <Cr>",
        desc = "Next quickfix",
        mode = n
    },
    {
        "[q",
        "<Cmd> cprev <Cr>",
        desc = "Prev quickfix",
        mode = n
    },
    {
        "]<Space>",
        "o<Esc>k",
        desc = "Add blank line below",
        mode = n
    },
    {
        "[<Space>",
        "O<Esc>j",
        desc = "Add blank line above",
        mode = n
    },

    {
        "gq",
        "gq",
        desc = "format line (+ motion)",
        mode = nx
    },
    {
        "gw",
        "gw",
        desc = "wrap line (+ motion)",
        mode = nx
    },
    {
        "<c-g>",
        "g<c-g>",
        desc = "Word count",
        mode = x
    },
    {
        "g<c-g>",
        "g<c-g>",
        desc = "Word count",
        mode = n
    },

    -- Delete and backspace
    {
        "<C-;>",
        "<Bs>",
        desc = "Backspace",
        mode = i
    },
    {
        "<A-Bs>",
        "<C-w>",
        desc = "Backspace word",
        mode = i
    },
    {
        "<C-'>",
        "<Del>",
        desc = "Delete",
        mode = i
    },

    -- Goto normal mode
    {
        "jk",
        "<Esc>",
        desc = "<Esc>",
        mode = i,
        hidden = true
    },
    {
        "kj",
        "<Esc>",
        desc = "<Esc>",
        mode = i,
        hidden = true
    },

    -- Goto beginning/end of line
    {
        "<C-b>",
        "<C-o>I",
        desc = "Beginning of line",
        mode = i
    },
    {
        "<C-e>",
        "<End>",
        desc = "End of line",
        mode = i
    },

    -- New line
    {
        "<C-Enter>",
        "<C-o>o",
        desc = "New line",
        mode = i
    },

    -- Toggle comment
    {
        "<C-/>",
        "gcc",
        desc = "Toggle comment",
        mode = n,
        remap = true
    },
    {
        "<C-/>",
        "gcgv",
        desc = "Toggle comment",
        mode = x,
        remap = true
    },
    {
        "<C-/>",
        "<C-o>gcc",
        desc = "Toggle comment",
        mode = i,
        remap = true
    },

    ---------- LSP ----------
    -- Set in autocmd. Only set if LSP has hover support
    -- { "K", vim.lsp.buf.hover, desc = "Hover", mode = nx },

    ---------- g ----------
    {
        "gd",
        vim.lsp.buf.definition,
        desc = "Goto definition",
        mode = n
    },
    {
        "gD",
        vim.lsp.buf.declaration,
        desc = "Goto declaration",
        mode = n
    },
    {
        "gi",
        vim.lsp.buf.implementation,
        desc = "Goto implementation",
        mode = n
    },
    {
        "gy",
        vim.lsp.buf.type_definition,
        desc = "Goto type definition",
        mode = n
    },
    {
        "g;",
        "g;",
        desc = "Goto older edit pos",
        mode = n
    },
    {
        "g,",
        "g,",
        desc = "Goto newer edit pos",
        mode = n
    },

    ---------- z ----------
    {
        "zl",
        "zr",
        desc = "Fold less",
        mode = n
    },

    ---------- Terminal ----------
    -- Escape terminal
    {
        "<C-x>",
        "<C-\\><C-n>",
        desc = "Escape terminal",
        mode = "t"
    },

    -- Switch windows
    {
        "<C-h>",
        "<C-\\><C-n><C-w>h",
        desc = "Window left",
        mode = "t"
    },
    {
        "<C-j>",
        "<C-\\><C-n><C-w>j",
        desc = "Window down",
        mode = "t"
    },
    {
        "<C-k>",
        "<C-\\><C-n><C-w>k",
        desc = "Window up",
        mode = "t"
    },
    {
        "<C-l>",
        "<C-\\><C-n><C-w>l",
        desc = "Window right",
        mode = "t"
    },

    ---------- Leader ----------
    {
        "<leader>a",
        vim.lsp.buf.code_action,
        desc = "Code action",
        mode = n
    },
    {
        "<leader>A",
        vim.lsp.codelens.run,
        desc = "Code lens action",
        mode = n
    },

    -- <leader>B = toggle break point for DAP

    -- Buffer
    { "<leader>b", group = "Buffer", mode = nx },
    {
        "<leader>bd",
        "<Cmd> bdelete <Cr>",
        desc = "Delete buffer",
        mode = n
    },
    {
        "<leader>bD",
        "<Cmd> bdelete! <Cr>",
        desc = "Delete buffer!",
        mode = n
    },
    {
        "<leader>bn",
        "<Cmd> enew <Cr>",
        desc = "New buffer",
        mode = n
    },

    -- Close
    {
        "<leader>c",
        "<Cmd> close <Cr>",
        desc = "Close window",
        mode = n
    },
    {
        "<leader>C",
        "<Cmd> tabclose <Cr>",
        desc = "Close tab",
        mode = n
    },

    -- Diff
    { "<leader>D", group = "Diff", mode = nx },
    {
        "<leader>Df",
        "<Cmd> diffoff <Cr>",
        desc = "Diff off (window)",
        mode = nx
    },
    {
        "<leader>DF",
        "<Cmd> diffoff! <Cr>",
        desc = "Diff off (tab)",
        mode = nx
    },
    {
        "<leader>Dg",
        "<Cmd> diffget <Cr>",
        desc = "Get from the other",
        mode = nx
    },
    {
        "<leader>DG",
        ":diffget ",
        desc = "Get from {buff/file}",
        mode = nx
    },
    {
        "<leader>Dd",
        "<Cmd> vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis <Cr>",
        desc = "Diff with disk",
        mode = nx
    },
    {
        "<leader>DO",
        "<Cmd> windo diffthis <Cr>",
        desc = "Diff on (tab)",
        mode = nx
    },
    {
        "<leader>Do",
        "<Cmd> diffthis <Cr>",
        desc = "Diff on (windows)",
        mode = nx
    },
    {
        "<leader>Dp",
        "<Cmd> diffput <Cr>",
        desc = "Put to the other",
        mode = nx
    },
    {
        "<leader>DP",
        ":diffput ",
        desc = "Put to {buff/file}",
        mode = nx
    },
    {
        "<leader>Ds",
        ":diffsplit ",
        desc = "Split and diff with {file}",
        mode = nx
    },
    {
        "<leader>Du",
        "<Cmd> diffupdate <Cr>",
        desc = "Update diff",
        mode = nx
    },
    -- <leader>d = Debug+
    { "<leader>d", group = "Debug", mode = nx },
    { "<leader>dr", group = "Run debug", mode = nx },

    -- Edit
    { "<leader>e", group = "Edit", mode = nx },
    {
        "<leader>ec",
        "g<C-g>",
        desc = "Word count",
        mode = nx
    },
    {
        "<leader>ei",
        "i<C-q><tab>",
        desc = "Insert tab <C-q><tab>",
        mode = nx
    },

    -- <leader>ej = mini param split/join

    {
        "<leader>en",
        "<Cmd> setlocal fileformat=unix <Cr>",
        desc = "Use unix newline",
        mode = nx
    },
    {
        "<leader>eN",
        "<Cmd> setlocal fileformat=dos <Cr>",
        desc = "Use dos newline",
        mode = nx
    },
    { "<leader>es", ":sort<Cr>", desc = "Sort", mode = nx },
    -- <leader>eS = Sessions+
    { "<leader>eS", group = "Sessions", mode = nx },
    { "<leader>et", "<Cmd>g/^$/d<Cr>", desc = "Trim Blank lines", mode = nx },
    { "<leader>eT", ":setlocal shiftwidth=", desc = "Tab stop width", mode = nx },
    {
        "<leader>eu",
        "<Cmd> setlocal fileencoding=utf-8 <Cr>",
        desc = "Convert to utf8",
        mode = nx
    },
    { "<leader>ew", "<Cmd> w <Cr>", desc = "Write to file", mode = nx },
    { "<leader>eW", "<Cmd> wa <Cr>", desc = "Write to all file", mode = nx },
    {
        "<leader>ey",
        '<Cmd> let @+ = expand("%:p") <Cr>',
        desc = "Copy file path",
        mode = nx
    },

    -- Format current document
    {
        "<leader>F",
        vim.lsp.buf.format,
        desc = "Format document",
        mode = nx,
    },

    -- <leader>f = Find+
    { "<leader>f", group = "Find", mode = nx },
    { "<leader>ff", group = "Files in", mode = nx },
    { "<leader>fw", group = "Words in", mode = nx },

    -- <leader>g = Git+
    { "<leader>g", group = "Git", mode = nx },
    { "<leader>gv", group = "Diffview", mode = nx },

    -- Window split
    {
        "<leader>h",
        "<Cmd> split <Cr>",
        desc = "Horizontal split",
        mode = nx,
    },
    {
        "<leader>v",
        "<Cmd> vsplit <Cr>",
        desc = "Vertical split",
        mode = nx,
    },

    -- <leader>i = Telescope buffer
    -- <leader>j = LF file explorer

    {
        "<leader>k",
        vim.diagnostic.open_float,
        desc = "Diagnostic pop-up",
        mode = nx,
    },

    -- LSP
    -- <C-?> used for showing whichkey for non-leader key prefix funcitons
    { "<leader>l", group = "LSP", mode = nx },
    { "<leader>la", vim.lsp.buf.code_action, desc = "Code action", mode = nx },
    { "<leader>lc", group = "Code lens", mode = nx },
    { "<leader>lca", vim.lsp.codelens.run, desc = "Action", mode = nx },
    { "<leader>lcc", vim.lsp.codelens.clear, desc = "Clear", mode = nx },
    { "<leader>lcr", vim.lsp.codelens.refresh, desc = "Refresh", mode = nx },
    { "<leader>ld", vim.lsp.buf.definition, desc = "Definition", mode = nx },
    { "<leader>lD", vim.lsp.buf.declaration, desc = "Declaration", mode = nx },
    {
        "<leader>lf",
        function()
            vim.lsp.buf.signature_help({ border = "rounded", focusable = false })
        end,
        desc = "Signature (cycle=x2,C-s)",
        mode = nx
    },
    { "<leader>lF", vim.lsp.buf.format, desc = "Format document", mode = nx },
    {
        "<leader>lh",
        function()
            vim.lsp.buf.hover({ border = "rounded", focusable = false })
        end,
        desc = "Hover",
        mode = nx
    },
    { "<leader>li", vim.lsp.buf.implementation, desc = "Implementation", mode = nx },
    { "<leader>lI", vim.lsp.buf.incoming_calls, desc = "Incoming calls", mode = nx },
    { "<leader>lO", vim.lsp.buf.outgoing_calls, desc = "Outgoing calls", mode = nx },
    { "<leader>lr", vim.lsp.buf.rename, desc = "Rename symbol", mode = nx },
    { "<leader>lR", vim.lsp.buf.references, desc = "References", mode = nx },
    {
        "<leader>lS",
        vim.lsp.buf.workspace_symbol,
        desc = "Workspace symbols",
        mode = nx
    },
    { "<leader>ls", vim.lsp.buf.document_symbol, desc = "Document symbols", mode = nx },
    { "<leader>lt", vim.lsp.buf.type_definition, desc = "Type definition", mode = nx },
    { "<leader>lw", group = "Workspace", mode = nx },
    {
        "<leader>lwa",
        vim.lsp.buf.add_workspace_folder,
        desc = "LSP add folder",
        mode = nx
    },
    {
        "<leader>lwl",
        function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
        desc = "LSP list folder",
        mode = nx
    },
    {
        "<leader>lwr",
        vim.lsp.buf.remove_workspace_folder,
        desc = "LSP remove folder",
        mode = nx
    },

    -- Macro over range
    {
        "<leader>m",
        function()
            print("Enter registry (single char):")
            local ok, char = pcall(vim.fn.getchar)
            if not ok or char == 27 then
                return
            end
            if type(char) == "number" then
                char = vim.fn.nr2char(char)
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes(
                        ":'<,'>norm! @" .. char .. "<Cr>",
                        true, false, true
                    ),
                    "n",
                    false
                )
            end
        end,
        desc = "Macro over range",
        mode = x,
    },

    -- Turn off highlight
    {
        "<leader>n",
        "<Cmd> noh <Cr>",
        desc = "Search HL off",
        mode = nx,
    },

    -- New buffer
    {
        "<leader>N",
        "<Cmd> enew <Cr>",
        desc = "New buffer",
        mode = nx,
    },

    -- o = toggle outline for symbols
    -- O = recently closed files

    -- Paste from system clip board
    {
        "<leader>p",
        '"+p',
        desc = "Paste from sys clipboard",
        mode = nx,
    },
    {
        "<leader>P",
        '"+P',
        desc = "Paste from sys clipboard",
        mode = nx,
    },

    -- Quit all
    {
        "<leader>q",
        "<Cmd> quitall <Cr>",
        desc = "Quit all!",
        mode = nx,
    },
    {
        "<leader>Q",
        "<Cmd> quitall! <Cr>",
        desc = "Quit all!",
        mode = nx,
    },

    -- r/R = Replace string in buffer/ workspace
    { "<leader>r", group = "Replace (cur buffer)", mode = nx },
    {
        "<leader>ro",
        ":%s///gI<Left><left><Left><Left>",
        desc = "Open (simple)",
        mode = { "n" }
    },
    {
        "<leader>rw",
        ":%s/<C-R><C-W>//gI<Left><left><Left>",
        desc = "Word (simple)",
        mode = { "n" }
    },
    {
        "<leader>rs",
        "y:%s/<C-R>0//gI<Left><left><Left>",
        desc = "Selection (simple)",
        mode = { "x" }
    },
    {
        "<leader>ri",
        ":s///gI<Left><left><Left><Left>",
        desc = "In selection",
        mode = { "x" }
    },
    { "<leader>R", group = "Replace (workspace)", mode = nx },

    -- S = Send lines to terminal
    -- Show
    { "<leader>s", group = "Show", mode = nx },
    --<leader>sb = show blame
    {
        "<leader>sC",
        "<Cmd> changes <Cr>",
        desc = "Change list",
        mode = nx
    },
    {
        "<leader>sd",
        vim.diagnostic.setloclist,
        desc = "Document diagnostic",
        mode = nx
    },
    {
        "<leader>sh",
        function()
            vim.lsp.buf.hover({ border = "rounded", focusable = false })
        end,
        desc = "Hover",
        mode = nx
    },
    {
        "<leader>si",
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end,
        desc = "Inlay hint from LSP",
        mode = nx
    },
    { "<leader>sj", "<Cmd> jumps <Cr>", desc = "Jump list", mode = nx },
    { "<leader>sl", "<Cmd> lopen <Cr>", desc = "Location list", mode = nx },
    -- <leader>sL = telescope software licenses
    -- <leader>sm = telescope marks
    -- <leader>sM = telescope man page
    { "<leader>sq", "<Cmd> copen <Cr>", desc = "Quickfix", mode = nx },
    -- <leader>sr = telescope registers
    { "<leader>sR", vim.lsp.buf.references, desc = "References", mode = nx },
    {
        "<leader>ss",
        function()
            vim.lsp.buf.signature_help({ border = "rounded" })
        end,
        desc = "Signature (cycle=x2,C-s)",
        mode = nx
    },
    -- <leader>sS = telescope search history
    -- <leader>sy = telescope-yanky, yank history

    -- Tab
    { "<leader>T", group = "Tab", mode = nx },
    { "<leader>Tc", "<Cmd> tabclose <Cr>", desc = "Close tab", mode = nx },
    { "<leader>TC", "<Cmd> tabonly <Cr>", desc = "Close other tabs", mode = nx },
    { "<leader>Te", "<Cmd> tabedit <Cr>", desc = "Edit in new tab", mode = nx },
    { "<leader>Tl", "<Cmd> tabs <Cr>", desc = "List tabs", mode = nx },
    { "<leader>Tm", "<Cmd> tabmove -1 <Cr>", desc = "Move tab left", mode = nx },
    { "<leader>TM", "<Cmd> tabmove +1 <Cr>", desc = "Move tab right", mode = nx },
    { "<leader>Tn", "<Cmd> tabnew <Cr>", desc = "New tab", mode = nx },

    -- Toggle
    { "<leader>t", group = "Toggle", mode = nx },
    --<leader>tb = toggle git blame
    {
        "<leader>tc",
        function()
            if vim.opt.conceallevel["_value"] ~= 0 then
                vim.opt_local.conceallevel = 0
            else
                vim.opt_local.conceallevel = 2
            end
        end,
        desc = "Conceal",
        mode = nx
    },
    -- <leader>tC = toggle context
    -- <leader>td = toggle git deleted lines
    -- <leader>tD = toggle DAP UI
    {
        "<leader>ti",
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end,
        desc = "Inlay hint from LSP",
        mode = nx
    },
    { "<leader>tl", "<Cmd> set number! <Cr>", desc = "Line number", mode = nx },
    {
        "<leader>tr",
        "<Cmd> set relativenumber! <Cr>",
        desc = "Relative line number",
        mode = nx
    },
    {
        "<leader>ts",
        "<Cmd> setlocal spell! <Cr>",
        desc = "Spellcheck (window)",
        mode = nx
    },
    { "<leader>tS", "<Cmd> set spell! <Cr>", desc = "Spellcheck (global)", mode = nx },
    -- <leader>tt = toggle twilight
    { "<leader>tw", "<Cmd> set wrap! <Cr>", desc = "Wrap", mode = nx },
    -- <leader>tz = toggle zen mode
    { "<leader>t<Space>", "<Cmd> set list! <Cr>", desc = "Space visibility", mode = nx },

    -- Update
    { "<leader>u", group = "Update", mode = nx },
    {
        "<leader>uP",
        "<Cmd> Lazy sync <Cr>",
        desc = "Update also lazy-lock.json",
        mode = nx
    },
    {
        "<leader>up",
        "<Cmd> Lazy update <Cr>",
        desc = "Update plugins",
        mode = nx
    },

    -- Window
    { "<leader>w", group = "windows", mode = nx },
    {
        "<leader>wd",
        "<C-w>d",
        desc = "Show diagnostics",
        mode = nx
    },
    {
        "<leader>wh",
        "<C-w>h",
        desc = "Go left",
        mode = nx
    },
    {
        "<leader>wj",
        "<C-w>j",
        desc = "Go down",
        mode = nx
    },
    {
        "<leader>wk",
        "<C-w>k",
        desc = "Go up",
        mode = nx
    },
    {
        "<leader>wl",
        "<C-w>l",
        desc = "Go right",
        mode = nx
    },
    {
        "<leader>wo",
        "<C-w>o",
        desc = "Close others",
        mode = nx
    },
    {
        "<leader>wq",
        "<C-w>q",
        desc = "Quit",
        mode = nx
    },
    {
        "<leader>ws",
        "<C-w>s",
        desc = "Horizontal split",
        mode = nx
    },
    {
        "<leader>wT",
        "<C-w>T",
        desc = "Break into new tab",
        mode = nx
    },
    {
        "<leader>wv",
        "<C-w>v",
        desc = "Vertical split",
        mode = nx
    },
    {
        "<leader>ww",
        "<C-w>w",
        desc = "Switch window",
        mode = nx
    },
    {
        "<leader>wx",
        "<C-w>x",
        desc = "Swap with next",
        mode = nx
    },
    {
        "<leader>w+",
        "<C-w>+",
        desc = "Height-",
        mode = nx
    },
    {
        "<leader>w-",
        "<C-w>-",
        desc = "Height+",
        mode = nx
    },
    {
        "<leader>w<",
        "<C-w><",
        desc = "Width-",
        mode = nx
    },
    {
        "<leader>w=",
        "<C-w>=",
        desc = "Equal height/width",
        mode = nx
    },
    {
        "<leader>w>",
        "<C-w>>",
        desc = "Width+",
        mode = nx
    },
    {
        "<leader>w_",
        "<C-w>_",
        desc = "Max out height",
        mode = nx
    },
    {
        "<leader>w|",
        "<C-w>|",
        desc = "Max out width",
        mode = nx
    },
    {
        "<leader>w<C-d>",
        "<C-w><C-d>",
        desc = "Show diagnostics",
        mode = nx
    },

    -- Execute
    { "<leader>x", group = "Execute", mode = nx },
    { "<Leader>xC", group = "Colour", mode = nx },
    {
        "<leader>xh",
        "<Cmd> %!xxd <Cr>",
        desc = "xxd to hex",
        mode = nx
    },
    {
        "<leader>xH",
        "<Cmd> %!xxd -r <Cr>",
        desc = "xxd to bin",
        mode = nx
    },

    -- Yank to system clipboard
    {
        "<leader>y",
        '"+y',
        desc = "Yank to sys clipboard",
        mode = nx
    },
    {
        "<leader>Y",
        '"+Y',
        desc = "Yank to sys clipboard",
        mode = nx
    },

    -- <leader>; = overseer
    { "<leader>;", group = "Tasks", mode = nx },

    ---------- Leader Leader ----------
    { "<leader><leader>", group = "More", mode = nx },
    {
        "<leader><leader>b",
        require("core.my_func").build_by_filetype,
        desc = "Build",
        mode = nx
    },
    {
        "<leader><leader>B",
        require("core.my_func").repeat_last_build,
        desc = "Repeat last build",
        mode = nx
    },
    {
        "<leader><leader>c",
        "<Cmd> call setqflist([]) <Cr>",
        desc = "Clear quickfix",
        mode = nx
    },
    {
        "<leader><leader>C",
        require("core.my_func").clear_term,
        desc = "Clear terminal",
        mode = nx
    },
    {
        "<leader><leader>d",
        function() vim.diagnostic.jump({ count = 1 }) end,
        desc = "Prev diagnostic",
        mode = nx
    },
    {
        "<leader><leader>D",
        function() vim.diagnostic.jump({ count = -1 }) end,
        desc = "Next diagnostic",
        mode = nx
    },
    { "<leader><leader>m", "<Cmd> make <Cr>", desc = "Make/Run", mode = nx },
    { "<leader><leader>p", '"0p', desc = "Paste last yank", mode = nx },
    { "<leader><leader>P", '"0P', desc = "Paste last yank", mode = nx },
    { "<leader><leader>q", "<Cmd> cclose <Cr>", desc = "Close quickfix", mode = nx },
    { "<leader><leader>t", "<Cmd> terminal <Cr>", desc = "Open terminal", mode = nx },
    {
        "<leader><leader>v",
        require("core.my_func").view,
        desc = "View output",
        mode = nx
    },
}

return default_keymaps
