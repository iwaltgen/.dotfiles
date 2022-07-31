-- https://github.com/nvim-treesitter/nvim-treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
		'toml', 'yaml', 'json', 'markdown',
		'lua', 'vim', 'bash', 'make',
		'html', 'css', 'javascript', 'typescript',
		'go', 'rust',
	},
}
