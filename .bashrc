#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='lsd -la --color=auto'
alias grep='grep --color=auto'
alias vim="nvim"
PS1='\n \[\e[07m\] 󱃋 isopod 󱃋 \[\e[0m\] \W\ > '
#PS1='\n  󰢚  \W\ > '

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

export FZF_DEFAULT_OPTS="--no-preview"
export FZF_CTRL_T_OPTS="--no-preview"
export FZF_ALT_C_OPTS="--no-preview"

