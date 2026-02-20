" Fix synchronization issues by forcing the parser to look from the start of the file
syntax sync fromstart

" ```
" this will be highlighted (including backticks)
" ```
syntax region TwoDoRawBlock start="^```" end="^```"

" - This is an action item
syntax match TwoDoActionItem "^\s*- .*"

" x This is a completed item
syntax match TwoDoListItemCompleted "^\s*x .*"

syntax match TwoDoSectionHeader "^\(Changes\|Review\|Task\|Meeting\):"

highlight TwoDoRawBlock guifg=#414141
highlight TwoDoActionItem guifg=#ffff00
highlight TwoDoListItemCompleted guifg=#00ff00

" Added gui=bold and cterm=bold to make the header bold
highlight TwoDoSectionHeader guifg=#ffffff gui=bold cterm=bold
