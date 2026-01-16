

call plug#begin()

Plug 'whatyouhide/vim-gotham'
Plug 'wadackel/vim-dogrun'
Plug 'TheNiteCoder/mountaineer.vim'
Plug 'sainnhe/sonokai'
Plug 'Stoozy/vimcord'
Plug 'morhetz/gruvbox'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'terryma/vim-multiple-cursors'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'vimwiki/vimwiki'

call plug#end()

set number
set relativenumber

set tabstop=2
set shiftwidth=2

set smartindent
set autoindent

set ruler
set cursorline

set hlsearch

set wrap

set noswapfile

set termguicolors
syntax on

set nocompatible
filetype plugin on
syntax on

set background=dark

" let g:gruvbox_contrast_dark = 'hard'

colorscheme	wildcharm

hi Normal guibg=NONE
hi NormalNC guibg=NONE ctermbg=NONE
hi EndOfBuffer guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE

let mapleader=" "

inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : "\<CR>"


" nnoremap <leader>q <C-^>






