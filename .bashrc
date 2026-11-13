#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls -la --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
PS1='\n\e[0;31m\W/\e[m \e[0;1m>\e[m '

export PATH=~/.local/bin:$PATH
export PATH=~/.local/share:$PATH

setxkbmap -option caps:escape

