" Have git grep be the grep program if w/in a repo
augroup GitGrep
  autocmd!
  autocmd BufEnter * if !empty(finddir('.git', expand('%:p:h') . ';'))
        \ |   let b:in_git_repo = v:true
        \ |   set grepprg=git\ grep\ -n\ $*
        \ |   set grepformat=%f:%l:%m,%m\ %f\ match%ts,%f
        \ | else
        \ |   let b:in_git_repo = v:false
        \ |   set grepprg=internal " Or your preferred default grep
        \ | endif
augroup END

" Specific file treatment
augroup FileTypeSettings
  autocmd!
  autocmd FileType cs,csx setlocal sw=4 ts=4
  autocmd FileType rst setlocal ts=3 sw=3
  autocmd FileType text setlocal tw=80 ts=2 sw=2
  if match(getcwd(), 'projects\C') >= 0
    autocmd FileType javascript,typescript,html,css setlocal sw=4 ts=4
  endif
augroup END

augroup Random
  autocmd!
  " Has the quickfix window show up immediately instead of previewing results first
  autocmd QuickFixCmdPost [^l]* cwindow
augroup END
