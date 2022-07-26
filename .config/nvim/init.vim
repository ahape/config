set number

" Indentation related
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent

" Search related
set smartcase
set ignorecase

" Otherwise cursor will be thin imperceptible line
set guicursor=c:block

" Otherwise Python will be indented 4 spaces and pretty much impossible to override
let g:python_recommended_style=0

if !empty($RESTEndpoint)
  set sw=4 ts=4 " Keep it classy at work
endif

autocmd BufRead,BufNewFile *.cs,*.csx setlocal sw=4 ts=4 filetype=cs
autocmd BufRead,BufNewFile todos.txt setlocal tw=80 ts=2 sw=2

"
" The following settings replace 'grep' with 'git grep'. Use 'vimgrep' if
" outside of a git repo.
"
set grepprg=git\ grep\ -n\ $*
" Has the quickfix window show up immediately
autocmd QuickFixCmdPost [^l]* cwindow
" Aliases :grep to :G as well as doesn't jump to the first hit, and silences
" the 'Press ENTER to continue' prompt
command! -nargs=? G execute "silent grep! <args>"

" A convenience command for running grep on the word under the cursor (`C-x ]`).
function GitGrepWord()
  let filetype = split(getreg("%"), "[.]")[-1]
  normal! "zyiw
  execute "G -w -e ".getreg("z")." **/*.".filetype
endfunction
nmap <C-x>] :call GitGrepWord()<CR>

" Returns:
" ----------
" 2022-04-27
" ----------
function Date()
    let hr = "----------"
    return hr."\n".strftime("%Y-%m-%d")."\n".hr."\n"
endfunction
