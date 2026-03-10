----- General -----
local general_id = vim.api.nvim_create_augroup("general", { clear = true })

----- Auto reload config on dir change -----
-- vim.api.nvim_create_autocmd("DirChanged", {
--     group = general_id,
--     pattern = "*",
--     callback = function()
--         local workspace_config_path = vim.fn.getcwd() .. "/.nvim.lua"
--         local lua_code = vim.secure.read(workspace_config_path)
--         if lua_code then
--             local func, _ = load(lua_code)
--             if func then
--                 func()
--             end
--         end
--     end,
-- })

----- Overwrite terminal theme to solarize -----
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
    group = general_id,
    pattern = "*",
    callback = function()
        -- Do not set theme for TTY
        if os.getenv("TERM") == "linux" then
            return
        end
        vim.g.terminal_color_0 = "#073642"
        vim.g.terminal_color_1 = "#dc322f"
        vim.g.terminal_color_2 = "#859900"
        vim.g.terminal_color_3 = "#b58900"
        vim.g.terminal_color_4 = "#268bd2"
        vim.g.terminal_color_5 = "#d33682"
        vim.g.terminal_color_6 = "#2aa198"
        vim.g.terminal_color_7 = "#eee8d5"
        vim.g.terminal_color_8 = "#002b36"
        vim.g.terminal_color_9 = "#cb4b16"
        vim.g.terminal_color_10 = "#586e75"
        vim.g.terminal_color_11 = "#657b83"
        vim.g.terminal_color_12 = "#839496"
        vim.g.terminal_color_13 = "#6c71c4"
        vim.g.terminal_color_14 = "#93a1a1"
        vim.g.terminal_color_15 = "#fdf6e3"
    end,
})

----- Use q to close help files -----
vim.api.nvim_create_autocmd("FileType", {
    group = general_id,
    pattern = { "qf", "help", "man", "lspinfo" },
    callback = function(data)
        vim.keymap.set("n", "q", "<Cmd>close<CR>", { silent = true, buffer = data.buf })
    end,
})

----- Conceal bold italic etc. in files -----
-- Using the plugin render-markdown for this
-- vim.api.nvim_create_autocmd("FileType", {
--     group = general_id,
--     pattern = { "markdown" },
--     callback = function()
--         vim.opt_local.conceallevel = 2
--     end,
-- })

----- Highlight yanked text -----
-- Yanky also has the same function, use autocmd version. Less depencency.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = general_id,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 600 })
    end,
})

----- Set autoformat -----
-- By default, pressing enter at the end of a comment, Neovim will
-- automatically insert the current comment leader for the new line. This
-- autocmd disables this.
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = general_id,
    pattern = "*",
    -- Do not auto continue comment
    -- vim.opt.formatoptions:remove("cro") not work
    -- command = ":set formatoptions-=cro"
    command = ":set formatoptions-=ro"
})

----- Hide quick fix buffer -----
vim.api.nvim_create_autocmd("FileType", {
    group = general_id,
    pattern = "qf",
    callback = function(data)
        vim.bo[data.buf].buflisted = false
    end,
})

----- Trim tailing space on save -----
local trailspace_ok, trailspace = pcall(require, "mini.trailspace")
if trailspace_ok then
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = general_id,
        pattern = "*",
        callback = trailspace.trim
    })
else
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = general_id,
        pattern = "*",
        command = ":exe 'norm m`' | %s/\\s\\+$//e | norm g``",
    })
end

----- Set file type for .shrc -----
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = general_id,
    pattern = ".shrc",
    command = ":set filetype=sh",
})

----- Auto mkdir for new files -----
-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = general_id,
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

----- Resize splits if window got resized ---
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = general_id,
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

----- LSP -----
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client == nil then
            return
        end

        ----- Prefer LSP folding if client supports it -----
        if client:supports_method("textDocument/foldingRange") then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        end

        ----- Map K to hover with border -----
        if client:supports_method("textDocument/hover") then
            require("core.my_func").set_keymap({
                {
                    "K",
                    function()
                        vim.lsp.buf.hover({ border = "rounded", focusable = false })
                    end,
                    buffer = args.buf,
                    desc = "Hover",
                    mode = { "n", "x" },
                }
            })
        end

        ----- Highlight symbol under cursor -----
        if client:supports_method("textDocument/documentHighlight") then
            vim.api.nvim_create_augroup("lsp_document_highlight", {
                clear = false
            })
            vim.api.nvim_clear_autocmds({
                buffer = args.buf,
                group = "lsp_document_highlight",
            })
            vim.api.nvim_create_autocmd(
                { "CursorHold", "CursorHoldI" }, {
                    group = "lsp_document_highlight",
                    buffer = args.buf,
                    callback = vim.lsp.buf.document_highlight,
                })
            vim.api.nvim_create_autocmd(
                {
                    "CursorMoved",
                    "CursorMovedI"
                }, {
                    group = "lsp_document_highlight",
                    buffer = args.buf,
                    callback = vim.lsp.buf.clear_references,
                })
        end

        ----- Auto refresh codelens from LSP -----
        -- This will always display the virtual text. E.g., number of references.
        -- Use key bind to manually toggle it.
        -- if client:supports_method("textDocument/codeLens") then
        --     vim.api.nvim_create_autocmd(
        --         { "BufEnter", "CursorHold", "InsertLeave" }, {
        --             buffer = args.buf,
        --             callback = vim.lsp.codelens.refresh,
        --         })
        -- end

        ----- Builtin LSP autocomplete -----
        -- No multiple source, not snippets, no documentation
        -- if client:supports_method("textDocument/completion") then
        --     vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        -- end
    end,
})

----- Builtin make -----

vim.api.nvim_create_autocmd("FileType", {
    group = general_id,
    pattern = { "python" },
    callback = function(args)
        -- Modifier :p=full_path, :~=reduce_to_home, :S=escape_for_shell
        -- Can use "$*" to place the arguments of ":make", can be used multiple times.
        vim.opt_local["makeprg"] = "python3 %:p:S"
        -- vim.opt_local["errorformat"] = ""
    end,
})
