#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls -la --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
PS1='\e[0;1m \h \e[m\w $ '

export PATH=~/.local/bin:$PATH
export PATH=~/.local/share:$PATH

setxkbmap -option caps:escape

