set number

" Indentation related
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent

" Search related
set smartcase
set ignorecase

set guicursor=c:block

" Otherwise Python will be indented 4 spaces and pretty much impossible to override
let g:python_recommended_style=0

" Ctrl+C a visual block as if it was highlighted text
vnoremap <C-c> "*y

" Only for work--see the git 
"autocmd BufRead,BufNewFile *.js,*.ts,*.html,*css setlocal sw=4 ts=4

" Show git branch in statusline--may show error text if outside of git branch
autocmd BufRead,BufNewFile *
  \   let branch = system("git branch --sh")
  \ | set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P\  
  \ | exec "silent! set statusline+=".branch

autocmd BufRead,BufNewFile *.cs,*.csx setlocal sw=4 ts=4 filetype=cs
autocmd BufRead,BufNewFile *.rst setlocal ts=3 sw=3
autocmd BufRead,BufNewFile *.txt setlocal tw=80 ts=2 sw=2

"
" The following settings replace 'grep' with 'git grep'. Use 'vimgrep' if
" outside of a git repo.
"
set grepprg=git\ grep\ -n\ $*
" Has the quickfix window show up immediately
autocmd QuickFixCmdPost [^l]* cwindow

" Returns:
" ----------
" 2022-04-27
" ----------
function Date()
    let hr = "----------"
    return hr."\n".strftime("%Y-%m-%d")."\n".hr."\n"
endfunction
