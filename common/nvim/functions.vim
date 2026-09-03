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
  silent! argdo badd
endfunction

" Browse recent files. Better than `browse oldfiles` because you can
" actually `gf` the file you want
function Recent()
  let @x = ""
  silent bro old "Not sure if I need this?
  for file in v:oldfiles
    if match(file, '\.[a-z]\{1,10}$') > 0
      let @X = file.."\n"
    endif
  endfor
  exec 'enew | normal "xp'
endfunction

" Echo current git branch
function! GitBranch()
  let l:dir = expand('%:p:h')
  let l:cmd = 'git -C ' . fnameescape(l:dir) . ' branch --show-current'
  let l:branch = system(l:cmd . ' 2> ' . (has('win32') ? '`$null' : '/dev/null'))
  echo substitute(l:branch, '\r\?\n\?$', '', '')
endfunction
