

call plug#begin()

Plug 'whatyouhide/vim-gotham'
Plug 'wadackel/vim-dogrun'
Plug 'TheNiteCoder/mountaineer.vim'
Plug 'morhetz/gruvbox'
Plug 'flazz/vim-colorschemes'

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

syntax on


if has('termguicolors')
	set termguicolors
endif

colorscheme mountaineer

hi Normal guibg=NONE ctermbg=NONE
hi EndOfBuffer guibg=NONE ctermbg=NONE

