if ls --color > /dev/null 2>&1; then
  alias ls="ls --color"
  alias dir="ls -l --color"
else
  alias ls="ls -G"
  alias dir="ls -l -G"
fi
alias py="python3"
#
# zsh 5.9 (arm64-apple-darwin)
#
autoload -Uz compinit && compinit
# Support for auto-completing `echo *oob<TAB>` to `echo FooBar`
zstyle ':completion:*' completer _expand _complete _match _ignored
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:match:*' matcher 'm:{a-zA-Z}={A-Za-z}'

setopt NO_CASE_GLOB
setopt GLOB_COMPLETE

HISTFILE=~/.zsh_history   # Where the history file will be saved
HISTSIZE=10000            # How many lines of history to keep in memory
SAVEHIST=10000            # How many lines of history to save to the HISTFILE
setopt HIST_IGNORE_DUPS   # Don't record a command if it was the last one typed
setopt HIST_IGNORE_SPACE  # Don't record commands starting with a space
setopt SHARE_HISTORY      # Share history between all active sessions
setopt APPEND_HISTORY     # Append to history file rather than overwriting
bindkey '^R' history-incremental-search-backward
