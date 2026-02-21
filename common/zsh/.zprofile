# .zprofile runs once at login (e.g., opening a terminal)
# Use .zprofile for environment variables (like PATH via eval "$(brew shellenv)")

if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 1. Ensure the path array cannot contain duplicates
typeset -U path

# 2. Define your custom paths
paths_to_add=(
  "$HOME/.dotnet/tools"
  "$HOME/.opencode/bin"
  "$HOME/Projects/llmchat/bin"
  "/usr/local/microsoft/powershell/7"
)
# 3. Add valid directories to the PATH
# switch 'path+=...' to 'path=(... $path)' if you want these to have higher priority than system paths
for dir in $paths_to_add; do
  [ -d "$dir" ] && path+=("$dir")
done

unset paths_to_add

# Load secrets if the file exists
if [[ -f "$HOME/.zprofile.secrets" ]]; then
  source "$HOME/.zprofile.secrets"
fi

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
