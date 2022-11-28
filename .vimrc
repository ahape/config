syntax enable

" UI
set number
set showcmd
set wrap
set ruler

" spaces & tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set ai
set listchars+=space:-,trail:Z

" stuff
filetype indent on
set ls=2
set re=0

" files
set nobackup
set nowb
set noswapfile

" searching
set incsearch
set hlsearch
set smartcase
set ignorecase

" abbreviations
iabbrev funciton function
iabbrev funciotn function
iabbrev fucniton function

" mappings
let mapleader = ","
"nnoremap j jzz
"nnoremap k kzz
"nnoremap n nzz
"nnoremap N Nzz
"nnoremap J +zz
"nnoremap K -zz
"nnoremap B ^
"nnoremap E $
nnoremap <Space>o o<Esc>k
nnoremap <Space>O O<Esc>j
"nnoremap <C-j> <C-w>j
"nnoremap <C-k> <C-w>k
"nnoremap <C-h> <C-w>h
"nnoremap <C-l> <C-w>l
nnoremap <Leader>w :w<Return>
nnoremap <Leader>c I//<Esc>
nnoremap <Leader>" ciw""<Esc>P
nnoremap <Leader>' ciw''<Esc>P
nnoremap <Leader>` ciw``<Esc>P
vnoremap <Leader>" c""<Esc>P
vnoremap <Leader>' c''<Esc>P
vnoremap <Leader>` c``<Esc>P

augroup AutoCommands
    autocmd BufRead,BufNewFile *.txt,*.md setlocal spell
    autocmd BufRead,BufNewFile *.txt,*.md setlocal tw=80
augroup END

" start vim-plug
"call plug#begin('~/.vim/plugged')

" plugin section
"Plug 'pangloss/vim-javascript'
"Plug 'leafgarland/typescript-vim'
"Plug 'maxmellon/vim-jsx-pretty'
"Plug 'prettier/vim-prettier', { 'do': 'yarn install', 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }
"let g:prettier#autoformat = 0
"autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" end vim-plug
"call plug#end()
