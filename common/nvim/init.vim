runtime functions.vim
runtime augroups.vim

colorscheme default

" Otherwise Python will be indented 4 spaces and pretty much impossible to override
let g:python_recommended_style=0

" Abide to .editorconfig files
let g:editorconfig = v:true

" One-time setup for the Windows shell pipe (doesn't need to change per buffer)
if has('win32')
  set shellpipe=>%s\ 2>&1
endif

set number expandtab autoindent smartcase ignorecase

" Search related
set guicursor=c:block

" Standard file treatment
set tabstop=2 shiftwidth=2

" Allows `gf` on filenames with line/col info appended (e.g. file.cs:1: ...)
set includeexpr=substitute(v:fname,':.*','','g')

" Ctrl+C a visual block as if it was highlighted text (Windows)
vnoremap <C-c> "*y

" Common command typos
cabbrev w' w
cabbrev w] w
cabbrev we w
cabbrev B b

" Easy escape rope
command! Q quitall!
