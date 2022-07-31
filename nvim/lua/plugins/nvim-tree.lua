-- https://github.com/kyazdani42/nvim-tree.lua
require('nvim-tree').setup {
  view = {
    adaptive_size = true,
  },
  update_focused_file = {
    enable = true,
  },
  filters = {
    dotfiles = false,
    custom = { '^\\.git' }
  },
}

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Custom key-binding
map('n', '<C-n>', function() require('nvim-tree').toggle() end, opts)

-- Builtin key-binding
map('n', '<leader>n', function() return require('nvim-tree').toggle() end, opts)
