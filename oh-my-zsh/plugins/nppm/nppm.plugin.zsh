# ------------------------------------------------------------------------------
#          FILE:  nppm.plugin.zsh
#   DESCRIPTION:  oh-my-zsh nppm plugin file.
#        AUTHOR:  Guillaume Maïssa(g.maissa@novactive.com)
#       VERSION:  1.0.0
# ------------------------------------------------------------------------------

# NPPM basic command completion
_nppm_get_command_list () {
    $_comp_command1 --no-ansi | sed "1,/Available commands/d" | awk '/^[ \t]*[a-z]+/ { print $1 }'
}

_nppm_get_required_list () {
    $_comp_command1 show -s --no-ansi | sed '1,/requires/d' | awk 'NF > 0 && !/^requires \(dev\)/{ print $1 }'
}

_nppm () {
  local curcontext="$curcontext" state line
  typeset -A opt_args
  _arguments \
    '1: :->command'\
    '*: :->args'

  case $state in
    command)
      compadd $(_nppm_get_command_list)
      ;;
    *)
      compadd $(_nppm_get_required_list)
      ;;
  esac
}

compdef _nppm nppm
compdef _nppm nppm.phar

# Aliases
alias npsu='nppm self-update'
alias nper='nppm env:reconfigure'

# install nppm in the current directory
alias npget='wget -nc -q --user dev --password nov@ctiv3  http://nppm.novactive.net/downloads/nppm.phar'
