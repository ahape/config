alias ls="ls --color"
alias py="/usr/bin/python3"

# Makes autocompletion of commands case insensitive
compctl -M '' 'm:{a-zA-Z}={A-Za-z}'

# See http://aperiodic.net/screen/title_examples
# Allows for screen command to read current process name out to window title
#alias postcmd 'echo -ne "^[k\!#:0^[\\"'

# Test to see if we're using screen
is_screen_session=`ps t | grep "login -pflq alanhape /bin/zsh" | grep -v grep`

if test "$is_screen_session"
then
  # Allows for screen command to read current process name out to window title
  preexec () {
    echo -ne "\ek${1%% *}\e\\"
  }
fi

export PATH="/Users/alanhape/Commands:$PATH"
