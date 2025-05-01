

call plug#begin()

Plug 'whatyouhide/vim-gotham'
Plug 'wadackel/vim-dogrun'
Plug 'TheNiteCoder/mountaineer.vim'
Plug 'morhetz/gruvbox'
Plug 'flazz/vim-colorschemes'
Plug 'sainnhe/sonokai'
Plug 'girishji/vimcomplete'
Plug 'vimsence/vimsence'

call plug#end()

set t_Co=256

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
set showtabline=2


set termguicolors
syntax on

colorscheme mountaineer

hi Normal guibg=NONE ctermbg=NONE
hi EndOfBuffer guibg=NONE ctermbg=NONE

