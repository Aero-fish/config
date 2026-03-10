local M = {}

----- Simulate key press ---
-- function M.feedkey(key)
--     vim.api.nvim_feedkeys(
--         vim.api.nvim_replace_termcodes(key, true, false, true),
--         "n",
--         false)
-- end

----- Auto make directory when save -----
-- M.auto_mkdir = function ()
--     local dir = vim.fn.expand("<afile>:p:h")
--
--     -- This handles URLs using netrw. See ':help netrw-transparent' for details.
--     if dir:find("%l+://") == 1 then
--         return
--     end
--
--     if vim.fn.isdirectory(dir) == 0 then
--         vim.fn.mkdir(dir, "p")
--     end
-- end

----- Auto build/compile -----
function M.build_by_filetype()
    local filetype = vim.bo.filetype
    local has_overseer, overseer = pcall(require, "overseer")

    ---------- LaTex ----------
    if filetype == "tex" or filetype == "plaintex" or filetype == "bib" then
        if vim.fn.exists(":LspTexlabBuild") then
            print("Compiling Latex...")
            vim.cmd.LspTexlabBuild()
        else
            print("Texlab not installed.")
        end

        ---------- Markdown ----------
    elseif filetype == "markdown" then
        if has_overseer then
            local file_path = vim.fn.expand("%:p")
            local dir, file_name, ext = file_path:match(
                "^(.-)([^\\/]-)%.([^\\/%.]-)%.?$"
            )
            local pdf_path = dir .. file_name .. ".pdf"
            local beamer_path = dir .. file_name .. "_beamer.pdf"
            local html_path = dir .. file_name .. ".html"

            if vim.fn.filereadable(beamer_path) == 1 then
                print("Building markdown to beamer pdf")
                overseer.run_template({ name = "Markdown to beamer" }, nil)
            elseif vim.fn.filereadable(html_path) == 1 then
                print("Building markdown to revealjs")
                overseer.run_template({ name = "Markdown to revealjs" }, nil)
            else
                print("Building markdown to pdf")
                overseer.run_template({ name = "Markdown to PDF" }, nil)
            end
        else
            print("overseer is not installed")
        end

        ---------- d2 ----------
    elseif filetype == "d2" then
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
        local output_path = dir .. file_name .. ".svg"

        if vim.fn.filereadable(file_path) == 1 then
            os.execute("( setsid d2 '" ..
                file_path .. "' '" .. output_path .. "' >/dev/null 2>&1 </dev/null &)")
            print("Building " .. file_name .. "." .. ext .. " to svg")
        end
    elseif filetype == "rust" then
        if vim.fn.exists(":RustRun") then
            vim.cmd.RustRun()
        else
            print("Rust analyzer not installed.")
        end
    end
end

function M.repeat_last_build()
    local overseer_ok, overseer = pcall(require, "overseer")

    ---------- Re-run last task if exist ----------
    if overseer_ok then
        local tasks = overseer.list_tasks({ recent_first = true })
        if not vim.tbl_isempty(tasks) then
            overseer.run_action(tasks[1], "restart")
            return
        end
    end

    M.build_by_filetype()
end

----- Auto viewer -----
function M.view()
    local filetype = vim.bo.filetype
    if filetype == "tex" or filetype == "plaintex" then
        if vim.fn.exists(":LspTexlabForward") then
            vim.cmd.LspTexlabForward()
        else
            print("TexLab not installed.")
        end
    elseif filetype == "markdown" then
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
        local pdf_path = dir .. file_name .. ".pdf"
        local beamer_path = dir .. file_name .. "_beamer.pdf"
        local html_path = dir .. file_name .. ".html"

        if vim.fn.filereadable(beamer_path) == 1 then
            os.execute(
                "( setsid evince '" .. beamer_path .. "' >/dev/null 2>&1 </dev/null &)"
            )
        elseif vim.fn.filereadable(html_path) == 1 then
            os.execute(
                "( setsid librewolf '" .. html_path .. "' >/dev/null 2>&1 </dev/null &)"
            )
        elseif vim.fn.filereadable(pdf_path) == 1 then
            os.execute(
                "( setsid evince '" .. pdf_path .. "' >/dev/null 2>&1 </dev/null &)"
            )
        else
            print("Cannot find the pandoc generated file.")
        end
    elseif filetype == "d2" then
        local file_path = vim.fn.expand("%:p")
        local dir, file_name, ext = file_path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
        local svg_path = dir .. file_name .. ".svg"
        local png_path = dir .. file_name .. ".png"

        if vim.fn.filereadable(svg_path) == 1 then
            print("Open " .. svg_path)
            os.execute("( setsid xdg-open '" .. svg_path ..
                "' >/dev/null 2>&1 </dev/null &)")
        elseif vim.fn.filereadable(png_path) == 1 then
            os.execute(
                "( setsid xdg-open '" .. png_path .. "' >/dev/null 2>&1 </dev/null &)"
            )
        end
    elseif filetype == "typst" then
        if vim.fn.exists(":TypstPreview") then
            vim.cmd.TypstPreview()
        else
            print("'typst-preview' not installed.")
        end
    end
end

----- Clear terminal -----
function M.clear_term()
    if vim.bo.buftype == "terminal" then
        vim.opt_local.scrollback = 0
        vim.api.nvim_command("startinsert")
        vim.api.nvim_feedkeys("clear", "t", false)
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Cr>", true, false, true), "t", true
        )
        vim.opt_local.scrollback = 10000
    end
end

----- Functions to set keymaps -----
function M.set_keymap(args)
    -- which-key.add({ {mapping_1}, {mapping_2}, ... }):
    --     [1]: (string) lhs (key combinations, required)
    --     [2]: (string|fun()) rhs (cmd, optional): when present, it will create the mapping
    --     desc: (string|fun():string) description (required for non-groups)
    --     group: (string|fun():string) group name (optional)
    --     mode: (string|string[]) mode (optional, defaults to "n")
    --     cond: (boolean|fun():boolean) condition to enable the mapping (optional)
    --     hidden: (boolean) hide the mapping (optional)
    --     icon: (string|wk.Icon|fun():(wk.Icon|string)) icon spec (optional)
    --     proxy: (string) proxy to another mapping (optional)
    --     expand: (fun():wk.Spec) nested mappings (optional)
    --     any other option valid for vim.keymap.set. These are only used for creating mappings.

    -- if not args.keys or type(args.keys) ~= "string" then
    --     print("'set_keymap' function requires 'keys'")
    --     return
    -- end

    -- Options for which-key and builtin key mapping
    -- local keys = args.1
    -- local cmd = args.2 or nil
    -- local desc = args.desc or nil
    -- local group = args.group or nil
    -- local mode = args.mode or nil
    -- local cond = args.cond or nil
    -- local hidden = args.hidden or nil
    -- local icon = args.icon or nil
    -- local proxy = args.proxy or nil
    -- local expand = args.expand or nil

    -- Options for vim.keymap.set
    -- local buffer = args.buffer or nil    -- Global (nil) / Current Buffer only (true)
    -- local silent = args.silent or true   -- Do not echo on command line
    -- local noremap = args.noremap or true -- Disables recursive mapping
    -- local nowait = args.nowait or nil
    -- local script = args.script or nil
    -- local expr = args.expr or nil

    -- Map using builtin API
    for _, keymap in pairs(args) do
        if keymap[2] ~= nil then
            -- Set default options
            local opts = {}
            if keymap.buffer ~= nil then
                opts.buffer = keymap.buffer
            end

            if keymap.silent ~= nil then
                opts.silent = keymap.silent
            end

            if keymap.remap ~= nil then
                opts.remap = keymap.remap
            elseif keymap.noremap ~= nil then
                opts.noremap = keymap.noremap
            else
                opts.noremap = true
            end

            if keymap.nowait ~= nil then
                opts.nowait = keymap.nowait
            end

            if keymap.script ~= nil then
                opts.script = keymap.script
            end

            if keymap.expr ~= nil then
                opts.expr = keymap.expr
            end

            if keymap.desc ~= nil then
                opts.desc = keymap.desc
            end

            vim.keymap.set(
                keymap.mode,
                keymap[1],
                keymap[2],
                opts
            )
        end
    end
end

return M
