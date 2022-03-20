alias ls='ls --color'

set completion-ignore-case on

# See http://aperiodic.net/screen/title_examples
# Allows for screen command to read current process name out to window title
alias postcmd 'echo -ne "^[k\!#:0^[\\"'

# Allows for screen command to read current process name out to window title
preexec () {
  echo -ne "\ek${1%% *}\e\\"
}
