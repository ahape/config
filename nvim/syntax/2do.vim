" 1. Match content between triple backticks (multiline)
"    We use 'syntax region' for blocks that have a start and end.
syntax region TwoDoBlock start="^```" end="^```"

" 2. Match lines starting with "- " (allowing for indentation)
"    We use 'syntax match' for single-line patterns.
syntax match TwoDoList "^\s*- .*"

" 3. Link your matches to specific highlight groups
"    'Comment' is usually gray in most themes.
"    'Error' is usually red in most themes.
"highlight link TwoDoBlock Comment
"highlight link TwoDoList Error

" Alternatively, if you want very specific control over colors
" independent of your theme, you can define them manually:
highlight TwoDoBlock guifg=#414141
highlight TwoDoList guifg=#ffff00
