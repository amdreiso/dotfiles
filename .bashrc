#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim="nvim"
PS1=' \[\e[07m\] \h \[\e[0m\] \W\ > '

export PATH="$HOME/.local/bin:$PATH"
export FZF_DEFAULT_OPTS="--no-preview"
export FZF_CTRL_T_OPTS="--no-preview"
export FZF_ALT_C_OPTS="--no-preview"

eval "$(starship init bash)"

