-- https://github.com/akinsho/bufferline.nvim
require('bufferline').setup{}

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Builtin key-binding
map('n', '<leader>gb', function() return require('bufferline').pick_buffer() end, opts)
