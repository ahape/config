set number
set guicursor=c:block
" Indentation related
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
" Search related
set smartcase
set ignorecase

" Otherwise Python will be indented 4 spaces and pretty much impossible to
" override
let g:python_recommended_style=0

" Use git grep instead of default grep program.
" Use 'vimgrep' if outside of a git repo or searching non-checked-in code
set grepprg=git\ grep\ -n\ $*

" Adhere to work style guide
"autocmd BufRead,BufNewFile *.js,*.ts,*.html,*css setlocal sw=4 ts=4

" Show git branch in statusline--may show error text if outside of git branch
autocmd BufRead,BufNewFile *
  \   let branch = system("git branch --sh")
  \ | set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P\  
  \ | exec "silent! set statusline+=".branch

autocmd BufRead,BufNewFile *.cs,*.csx setlocal sw=4 ts=4 filetype=cs
autocmd BufRead,BufNewFile *.rst setlocal ts=3 sw=3
autocmd BufRead,BufNewFile *.txt setlocal tw=80 ts=2 sw=2

" Has the quickfix window show up immediately instead of previewing results
" first
autocmd QuickFixCmdPost [^l]* cwindow
cabbrev w' w
cabbrev w] w

" Ctrl+C a visual block as if it was highlighted text (Windows)
vnoremap <C-c> "*y

" Returns:
" ----------
" 2022-04-27
" ----------
function Date()
    let hr = "----------"
    return hr."\n".strftime("%Y-%m-%d")."\n".hr."\n"
endfunction

" Loads entire change history for current branch into buffers
function MakeSession(...)
  let base_branch = get(a:, 1, "master")
  let files = system("git diff --name-only ".l:base_branch)
  args `=l:files`
  silent! argdo edit
endfunction

" Browse recent files. Better than `browse oldfiles` because you can
" actually `gf` the file you want
function Recent()
  let @x = ""
  silent browse oldfiles "Not sure if I need this?
  for file in v:oldfiles
    if match(file, '\.[a-z]\{1,10}$')
      let @X = file.."\n"
    endif
  endfor
  exec 'enew | "xp'
endfunction
