alias ls="ls --color"
alias dir="ls -l --color"
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
