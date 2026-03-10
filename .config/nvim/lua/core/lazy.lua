-- Automatically install lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Auto-command that reloads neovim whenever you save this file
-- local lazy_autocmd_id = vim.api.nvim_create_augroup("lazy_user_config",
--     { clear = true })
-- vim.api.nvim_create_autocmd("BufWritePost", {
--     group = lazy_autocmd_id,
--     pattern = os.getenv("HOME") .. "/.config/nvim/lua/core/load_plugins.lua",
--     command = "source <afile> | Lazy sync",
-- })

-- Set default keymaps and leader keys before loading any plugins
-- Which-key, if installed, will set them again with its API.
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\" -- Supposed to be local to buffer
-- require("core.my_func").set_keymap(require("core.keymaps"))


local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
    print("Lazy is not installed")
    return
end

lazy.setup({
    -- Disable luarock
    rocks = { enabled = false, hererocks = false },

    -- Disable automatic checks for plugin updates
    checker = { enabled = false, },

    -- Lazy load all plugins
    defaults = { lazy = true, }, -- Default lazy loading
    change_detection = { enabled = false },

    -- Load work space spec at the end. Allow them to modify plugin options or
    -- install new plugins.
    local_spec = true,

    -- Install plugins from the spec in the 'plugins' folder
    spec = {
        { import = "plugins" }
    }
})
