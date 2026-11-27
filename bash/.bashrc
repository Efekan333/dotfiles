#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias kickstart-vim='NVIM_APPNAME="kickstart-vim" nvim'


export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH



PS1='[\u@\h \W]\$ '

# bash parameter completion for the dotnet CLI

function _dotnet_bash_complete()
{
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n' # On Windows you may need to use use IFS=$'\r\n'
  local candidates

  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
}

complete -f -F _dotnet_bash_complete dotnet
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PATH="$HOME/.local/bin:$PATH"

# fastfetch once per kitty window. Exported flag: nested `bash` inherits it (no repeat),
# new kitty windows/splits don't (kitty forks them from its own env).
if [[ $TERM == xterm-kitty && -z $FASTFETCH_SHOWN ]]; then
  export FASTFETCH_SHOWN=1
  fastfetch
fi
