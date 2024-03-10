-- https://github.com/nvim-telescope/telescope.nvim
require('telescope').setup({
	pickers = {
    buffers = {
      mappings = {
        i = {
          ["<C-d>"] = "delete_buffer",
        },
      },
    },
  },
	extensions = {
		fzf = {
			fuzzy = true,										-- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, 		-- override the file sorter
			case_mode = 'smart_case', 			-- or "ignore_case" or "respect_case"
																			-- the default case_mode is "smart_case"
		},
	},
})

-- https://github.com/nvim-telescope/telescope-fzf-native.nvim
require('telescope').load_extension('fzf')

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Custom key-binding
map('n', '<C-p>', function() require('telescope.builtin').find_files() end, opts)

-- Builtin key-binding
map('n', '<leader>ff', function() return require('telescope.builtin').find_files() end, opts)
map('n', '<leader>fg', function() return require('telescope.builtin').live_grep() end, opts)
map('n', '<leader>fr', function() return require('telescope.builtin').registers() end, opts)
map('n', '<leader>fb', function() return require('telescope.builtin').buffers() end, opts)

map('n', '<leader>help', function() return require('telescope.builtin').help_tags() end, opts)
map('n', '<leader>man', function() return require('telescope.builtin').man_pages() end, opts)
