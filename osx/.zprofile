# .zprofile runs once at login (e.g., opening a terminal)
# Use .zprofile for environment variables (like PATH via eval "$(brew shellenv)")

eval "$(/opt/homebrew/bin/brew shellenv)"

# Add own custom executables
export PATH="$PATH:/Users/alanhape/Commands"

# Add .NET Core SDK tools
export PATH="$PATH:/Users/alanhape/.dotnet/tools"

# Add powershell
export PATH="$PATH:/usr/local/microsoft/powershell/7"

# Add Chromium build tools
#export PATH="$PATH:/Users/alanhape/Projects/chromium-workspace/depot_tools"

# Add wireshark executables
#export PATH="$PATH:/Applications/Wireshark.app/Contents/MacOS/"

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
