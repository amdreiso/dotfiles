
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
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'alvan/vim-closetag'
Plug 'https://github.com/wolandark/vim-live-server.git'
Plug 'w0ng/vim-hybrid'
Plug 'ap/vim-css-color'

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
set nocompatible

filetype plugin on
syntax on

set background=dark
set clipboard=unnamedplus

colorscheme	retrobox

hi Normal guibg=NONE
hi NormalNC guibg=NONE ctermbg=NONE
hi EndOfBuffer guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE

let mapleader=" "

autocmd FileType html set omnifunc=htmlcomplete#CompleteTags

inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : "\<CR>"
xnoremap <leader>i :s/\d\+/\=line('.') - line("'<")<CR>

nnoremap <leader>q <C-^>
nnoremap <leader>f :Files<CR>

" go to file and create directories if inexistent
nnoremap <leader>cf :call CreateFileUnderCursor()<CR>

command! W w

function! CreateFileUnderCursor()
  " Get the file under the cursor
  let l:file = expand('<cfile>')
  let l:path = fnamemodify(l:file, ':p')

  " Create parent directories if missing
  call mkdir(fnamemodify(l:path, ':h'), 'p')

  " Create the file if it doesn't exist
  if !filereadable(l:path)
    call writefile([], l:path)
    silent! echo "Created file: " . l:path
  else
    echo "File already exists: " . l:path
  endif
endfunction



" tolin
autocmd BufNewFile,BufRead *.tolin setfiletype tolin

autocmd FileType tolin call TolinSyntax()

function! TolinSyntax()
  syntax clear

  syntax keyword tolinDefinition func set if for while end include struct get assign array do

  syntax match tolinNumber "\b\d\+\b"
  syntax match tolinComment "//.*$"

  highlight link tolinControl    Statement
  highlight link tolinDefinition Type
  highlight link tolinNumber     Constant
  highlight link tolinComment    Comment
endfunction





