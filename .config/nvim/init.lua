-- Fake that built-in explorer is loaded
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- Compile and caches Lua files
vim.loader.enable()

----- Setup custom keymaps -----
vim.g.mapleader = " "

-- Supposed to be local to buffer, used by plugins for local keymaps
-- E.g. <localleader>q to increase qoute level in email file .eml
vim.g.maplocalleader = "\\"

require("core.my_func").set_keymap(require("core.keymaps"))

-- Delete residual default keymap
vim.keymap.del("n", "<C-w>d")
vim.keymap.del("n", "<C-w><C-d>")

----- Setup options and autocmds -----
require("core.options")
require("core.autocmds")

----- Load packages -----
require("core.lazy")

----- Set tabline with name and icons -----
-- Use pcall(require, 'nvim-web-devicons'), set after loading all packages
vim.opt.tabline = "%!v:lua.require'core.tabline'.tabline()"
