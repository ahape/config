set number

" Indentation-related
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent

" Search related
set smartcase
set ignorecase

" Otherwise cursor will be thin impreceptible line
set guicursor=c:block

" Otherwise Python will be indented 4 spaces and pretty much impossible to override
let g:python_recommended_style=0

" Have C# tabs be 4 spaces
au BufRead,BufNewFile *.cs, *.csx setlocal sw=4 ts=4
