set enc=utf-8
set ts=2 sw=2 sts=2 et shiftwidth=2 tabstop=2
set autoindent copyindent
set nu cursorline scrolloff=2
set guifont=Hack\ Nerd\ Font\ Mono

if has("syntax")
	syntax on
endif

if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
	set inccommand=nosplit
endif

if (has("termguicolors"))
 set termguicolors
endif

" Plugins are installed at ~/.local/share/nvim/plugged
call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'kyazdani42/nvim-web-devicons' " optional, for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'projekt0n/github-nvim-theme'
Plug 'gpanders/editorconfig.nvim'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" Load lua-based configurations
lua require('core')
lua require('lsp')
lua require('plugins')