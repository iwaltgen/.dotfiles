-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap.set

-- Stay in indent mode
keymap({ "n", "v" }, "<S-Tab>", "<gv", { desc = "Unindent line" })
keymap({ "n", "v" }, "<Tab>", ">gv", { desc = "Indent line" })
