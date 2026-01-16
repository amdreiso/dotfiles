#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1=' \[\e[07m\] \h \[\e[0m\] \W\ > '

export PATH="$HOME/.local/bin:$PATH"

