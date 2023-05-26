-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = "'"

vim.opt.fileencoding = 'utf-8'
vim.opt.termguicolors = true

vim.opt.hidden = true
vim.opt.pumheight = 10

vim.opt.wrap = false

vim.o.backup = false
vim.o.swapfile = false
vim.o.writebackup = false

vim.opt.clipboard = 'unnamedplus'

-- Highlight Yank
local group = vim.api.nvim_create_augroup('HighlightYank', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 120 })
  end,
  group = group,
})
