"=====================================================
"===================== PLUGIN ========================
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'tpope/vim-fugitive'

Plug 'junegunn/vim-easy-align'

Plug 'kaicataldo/material.vim'

Plug 'vim-airline/vim-airline'

Plug 'vim-airline/vim-airline-themes'

call plug#end()


"=====================================================
"===================== SETTINGS ======================
set nocompatible
filetype off
filetype plugin indent on

syntax on
colorscheme material
set background=dark

language en_US.UTF-8
set guifont=Droid\ Sans\ Mono\ for\ Powerline:h15
let g:Powerline_symbols = 'fancy'
set t_Co=256
set term=xterm-256color
set termencoding=utf-8

set ttyfast
set ttymouse=xterm2
set ttyscroll=3
set laststatus=2
set expandtab
set ts=2 sw=2 sts=2 shiftwidth=2 tabstop=2
set encoding=utf-8
set autoread
set autoindent
set backspace=indent,eol,start
set incsearch
set hlsearch
set mouse=a

set noerrorbells
set number
set showcmd
set noswapfile
set nobackup
set splitright
set splitbelow
set autowrite
set hidden
set fileformats=unix,mac,dos
set noshowmatch
set noshowmode
set ignorecase
set smartcase
set completeopt=menu,menuone
set nocursorcolumn
set cursorline

set pumheight=10
set lazyredraw

highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%121v.\+/

" open help vertically
command! -nargs=* -complete=help Help vertical belowright help <args>
autocmd FileType help wincmd L

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.txt setlocal noet ts=4 sw=4
autocmd BufNewFile,BufRead *.md setlocal noet ts=4 sw=4
autocmd BufNewFile,BufRead *.vim setlocal expandtab shiftwidth=2 tabstop=2

autocmd FileType json setlocal expandtab shiftwidth=2 tabstop=2


"=====================================================
"===================== MAPPINGS ======================

let mapleader = ","

" 이 옵션은 버퍼를 수정한 직후 버퍼를 감춰지도록 한다.
set hidden

" 다음 버퍼로 이동
nmap <leader>l :bnext<CR>

" 이전 버퍼로 이동
nmap <leader>h :bprevious<CR>

" 현재 버퍼를 닫고 이전 버퍼로 이동
" 탭 닫기 단축키를 대체한다.
nmap <leader>bq :bp <BAR> bd #<CR>

" 현재 버퍼를 아래 탭으로 이동
nmap <leader>sp :bp <BAR> sp #<CR>

" 현재 버퍼를 옆 탭으로 이동
nmap <leader>vsp :bp <BAR> vsp #<CR>

" 모든 버퍼와 각 버퍼 상태 출력
nmap <leader>bl :ls<CR>

" ==================== Fugitive ====================
vnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gb :Gblame<CR>

" ==================== CtrlP ====================
" 기본 무시 설정
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
  \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg)$',
\}

" 가장 가까운 .git 디렉토리를 cwd(현재 작업 디렉토리)로 사용
" .svn, .hg, .bzr도 지원한다.
let g:ctrlp_working_path_mode = 'ra'

let g:ctrlp_user_command = 'pt %s -l --nocolor --hidden -g ""'
let g:ctrlp_mruf_max=356
let g:ctrlp_max_files=0
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
let g:ctrlp_match_window = 'bottom,order:btt,min:3,max:18'

" ==================== NerdTree ====================
noremap <Leader>t :TagbarToggle<cr>

" ==================== NerdTree ====================
noremap <Leader>n :NERDTreeToggle<cr>

let NERDTreeShowHidden=1

" ==================== vim-color-solarized ====================
"let g:Powerline_symbols = 'fancy'
"let g:solarized_termtrans=1
"let g:solarized_termcolors=256

" ==================== vim-material ====================
let g:material_terminal_italics = 1
let g:material_theme_style = 'darker'

" ==================== EasyAlign ====================
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" ==================== airline =======================
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

