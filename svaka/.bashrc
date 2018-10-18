# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
#PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
PS1='[\t][\u] \[\033[01;34m\]\w\[\033[00m\] ~↓↓$↓↓ '
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

export PAGER="/usr/bin/most -s"

up()
{
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

down()
{
    limit=$1
    
    for ((i=1 ; i <= limit ; i++))
    do
        cd ..
    done
}

chmpt()
{
	echo "Successfuly called"
	if [ "$1" -eq 1 ]
	then
		PS1='[\t][\u] \[\033[01;34m\]\w\[\033[00m\] [\[\033[01;32m\]\h\[\033[00m\]]\n~↓↓$↓↓ '
		#source /home/kristjan/.bashrc
	elif [ "$1" -eq 2 ]
	then
		PS1='[\t][\u] \[\033[01;34m\]\w\[\033[00m\] ~↓↓$↓↓ '
		#source /home/kristjan/.bashrc
	elif [ "$1" -eq 3 ]
    #then
    #    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    #    #fuck you!!!!!?
    #else
    #    printf "%s\n" "Bad input........-\>...\#Try again↓"
	#fi
	then
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        #fuck you!!!!!?
    elif [ "$1" -eq 7 ]
    then
        PS1="\[\033]0;[\h] \w\007\]\[\033[1m\]\[\033[37m\](\[\033[m\]\[\033[35m\]\u@\[\033[m\]\[\033[32m\]\h\[\033[1m\]\[\033[37m\]\[\033[1m\])\[\033[m\]-\[\033[1m\](\[\033[m\]\t\[\033[37m\]\[\033[1m\])\[\033[m\]-\[\033[1m\](\[\033[m\]\[\033[36m\]\w\[\033[1m\]\[\033[37m\])\[\033[35m\]${git_branch}\[\033[m\]\n$"
        printf "%s\n" "You are an g↓ooħd PROGRAMMER and will become a(maybe a math genious) and p.s. it's not comming back.............----->"
    else
        printf "%s\n" "Bad input........->...#Try again↓"
	fi
}

export HISTFILESIZE=20000
export HISTSIZE=10000
#Avoid duplicatesðĸ↓
export HISTCONTROL=ignoredups:erasedups
#HISTCONTROL=ignoredups
# Ignore duplicates, ls without options and builtin commands
export HISTIGNORE="&:ls:[bf]g:exit"
shopt -s histappend
# After each command, append to the history file and reread it
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
# Combine multiline commands into one in history
#shopt -s cmdhist
#ls --color=always
#LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33'
#export LS_COLORS
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS
alias ls="ls --color=always"

# Avoid duplicates
#export HISTCONTROL=ignoredups:erasedups  
# When the shell exits, append to the history file instead of overwriting it
#shopt -s histappend

# After each command, append to the history file and reread it
#export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"


# Powerline prompt worth investigating---------<><<<
#powerline-daemon -q
#POWERLINE_BASH_CONTINUATION=1
#POWERLINE_BASH_SELECT=1

#. /home/kristjan/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
eval $(dircolors -b $HOME/.dircolors)
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/Unetbootin:/opt/bin
export EDITOR=nano
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/Unetbootin:/opt/bin:/usr/games
export PATH=/opt/vuze:$PATH
