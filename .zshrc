# Change this to based on wherever your Python lives.
HOMEBREW_BIN="/opt/homebrew/bin"

alias ls="ls --color"
alias py="$HOMEBREW_BIN/python3.13"
alias python=$py

# Makes autocompletion of commands case insensitive
compctl -M '' 'm:{a-zA-Z}={A-Za-z}'

# Add wireshark executables
export PATH="$PATH:/Applications/Wireshark.app/Contents/MacOS/" 

export PATH="$PATH:$HOMEBREW_BIN"

# Add own custom executables
export PATH="$PATH:/Users/alanhape/Commands"

# Add frequently used commands in typeformer project
export PATH="$PATH:/Users/alanhape/Projects/typeformer/tools"

# Add .NET Core SDK tools
export PATH="$PATH:/Users/alanhape/.dotnet/tools"

# Add powershell
export PATH="$PATH:/usr/local/microsoft/powershell/7"

# Add GoogleCloud stuff?
#export PATH="$PATH:/Users/alanhape/Downloads/google-cloud-sdk/bin"

# Add Chromium build tools
export PATH="$PATH:/Users/alanhape/Projects/chromium-workspace/depot_tools"

export EDITOR=nvim

# See http://aperiodic.net/screen/title_examples
# Allows for screen command to read current process name out to window title
#alias postcmd 'echo -ne "^[k\!#:0^[\\"'

# Test to see if we're using screen
#is_screen_session=`ps t | grep "login -pflq alanhape /bin/zsh" | grep -v grep`

#if test "$is_screen_session"
#then
#  # Allows for screen command to read current process name out to window title
#  preexec () {
#    echo -ne "\ek${1%% *}\e\\"
#  }
#fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/alanhape/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/alanhape/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/alanhape/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/alanhape/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
