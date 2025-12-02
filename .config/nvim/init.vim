runtime functions.vim

set number
set guicursor=c:block
" Indentation related
set expandtab
"set tabstop=2 shiftwidth=2
set tabstop=4 shiftwidth=4
set autoindent
" Search related
set smartcase
set ignorecase

colorscheme default

" Otherwise Python will be indented 4 spaces and pretty much impossible to
" override
let g:python_recommended_style=0
" Abide to .editorconfig files
let g:editorconfig = v:true

" Use git grep instead of default grep program.
" Use 'vimgrep' if outside of a git repo or searching non-checked-in code
set grepprg=git\ grep\ -n\ $*

" A simple statusline without blocking system calls on every buffer read
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

autocmd FileType cs,csx setlocal sw=4 ts=4
autocmd FileType rst setlocal ts=3 sw=3
autocmd FileType text,txt setlocal tw=80 ts=2 sw=2
autocmd FileType javascript,typescript,html,css setlocal sw=4 ts=4

" Has the quickfix window show up immediately instead of previewing results
" first
autocmd QuickFixCmdPost [^l]* cwindow

" Ctrl+C a visual block as if it was highlighted text (Windows)
vnoremap <C-c> "*y
cabbrev w' w
cabbrev w] w
cabbrev we w
cabbrev B b

" Easy escape rope
command Q quitall!

" Allows `gf` on filenames with line/col info appended (e.g. file.cs:1: ...)
set includeexpr=substitute(v:fname,':.*','','g')
