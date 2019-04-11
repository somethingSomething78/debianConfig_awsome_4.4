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


#up()     ## StephenKitt coded ## 
#{
#  local d=..
#  for ((i = 1; i < ${1:-1}; i++)); do d=$d/..; done
#  cd $d
#}


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

taocl()
{
    if [[ ! -x /usr/bin/pandoc && ! -x /usr/bin/xmlstarlet && ! -x /usr/bin/curl ]]
    then
        printf "%s\n" "There is a missing program to run the funtion please install either pandoc, xmlstarlet or curl..........."
        sleep 10
    fi
    curl -s https://raw.githubusercontent.com/jlevy/the-art-of-command-line/master/README.md |
    sed '/cowsay[.]png/d' |
    pandoc -f markdown -t html |
    xmlstarlet fo --html --dropdtd |
    xmlstarlet sel -t -v "(html/body/ul/li[count(p)>0])[$RANDOM mod last()+1]" |
    xmlstarlet unesc | fmt -80 | iconv -t US
}


chmpt()
{
	echo "Successfuly called"
	if [ "$1" -eq 1 ]
	then
		PS1='[\t][\u] \[\033[01;34m\]\w\[\033[00m\] [\[\033[01;32m\]\h\[\033[00m\]]\n~↓↓$↓↓ '
		taocl
	elif [ "$1" -eq 2 ]
	then
		PS1='[\t][\u] \[\033[01;34m\]\w\[\033[00m\] ~↓↓$↓↓ '
		taocl
	elif [ "$1" -eq 3 ]
	then
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        printf "%s\n" "fuck you!!!!!?"
        taocl
    elif [ "$1" -eq 7 ]
    then
        PS1="\[\033]0;[\h] \w\007\]\[\033[1m\]\[\033[37m\](\[\033[m\]\[\033[35m\]\u@\[\033[m\]\[\033[32m\]\h\[\033[1m\]\[\033[37m\]\[\033[1m\])\[\033[m\]-\[\033[1m\](\[\033[m\]\t\[\033[37m\]\[\033[1m\])\[\033[m\]-\[\033[1m\](\[\033[m\]\[\033[36m\]\w\[\033[1m\]\[\033[37m\])\[\033[35m\]${git_branch}\[\033[m\]-(`ls | wc -w`)\n$"
        printf "%s\n" "You are an g↓ooħd PROGRAMMER and will become a(maybe a math genious) and p.s. it's not comming back.............----->"
        taocl
    elif [ "$1" -eq 4 ]
    then
        PS1="\`if [ \$? = 0 ]; then echo \[\e[33m\]^_^\[\e[0m\]; else echo \[\e[31m\]O_O\[\e[0m\]; fi\`[\u@\h:\w]\\$ "
        printf "%s\n" "You are going to learn bash, python, C, C\+\+ and lisp in the next few years and become rich"
        taocl
    elif [ "$1" -eq 5 ]
    then
        #PROMPT_COMMAND='
        PS1="\[\033[0;33m\][\!]\`if [[ \$? = "0" ]]; then echo "\\[\\033[32m\\]"; else echo "\\[\\033[31m\\]"; fi\`[\u.\h: \`if [[ `pwd|wc -c|tr -d " "` > 18 ]]; then echo "\\W"; else echo "\\w"; fi\`]\$\[\033[0m\] "; echo -ne "\033]0;`hostname -s`:`pwd`\007"
#'
        taocl
    elif [ "$1" -eq 6 ]
    then
        PS1="\n\[\033[35m\]\$(/bin/date)\n\[\033[32m\]\w\n\[\033[1;31m\]\u@\h: \[\033[1;34m\]\$(/usr/bin/tty | /bin/sed -e 's:/dev/::'): \[\033[1;36m\]\$(/bin/ls -1 | /usr/bin/wc -l | /bin/sed 's: ::g') files \[\033[1;33m\]\$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')b\[\033[0m\] -> \[\033[0m\]"
        taocl
    elif [ "$1" -eq 0 ]
    then
        PS1="\[\033[35m\]\t\[\033[m\]-\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
    elif [ "$1" -eq 8 ]
    then
        PS1="\n\[\e[30;1m\]\[\016\]l\[\017\](\[\e[34;1m\]\u@\h\[\e[30;1m\])-(\[\e[34;1m\]\j\[\e[30;1m\])-(\[\e[34;1m\]\@ \d\[\e[30;1m\])->\[\e[30;1m\]\n\[\016\]m\[\017\]-(\[\[\e[32;1m\]\w\[\e[30;1m\])-(\[\e[32;1m\]\$(/bin/ls -1 | /usr/bin/wc -l | /bin/sed 's: ::g') files, \$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')b\[\e[30;1m\])--> \[\e[0m\]"
        taocl
    elif [ "$1" -eq 9 ]
    then
        PS1="\n\[\e[1;30m\][$$:$PPID - \j:\!\[\e[1;30m\]]\[\e[0;36m\] \T \[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY:-o} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "
        taocl
    elif [ "$1" -eq 10 ]
    then
        #PROMPT_COMMAND='echo -en "\033[m\033[38;5;2m"$(( `sed -n "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/1024))"\033[38;5;22m/"$((`sed -n "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/1024 ))MB"\t\033[m\033[38;5;55m$(< /proc/loadavg)\033[m"' \
        PS1='\[\e[m\n\e[1;30m\][$$:$PPID \j:\!\[\e[1;30m\]]\[\e[0;36m\] \T \d \[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n($SHLVL:\!)\$ '
        taocl
    elif [ "$1" -eq 11 ]
    then
        #PROMPT_COMMAND='export H1="`history 1|sed -e "s/^[\ 0-9]*//; s/[\d0\d31\d34\d39\d96\d127]*//g; s/\(.\{1,50\}\).*$/\1/g"`";history -a;echo -e "sgr0\ncnorm\nrmso"|tput -S'
        PS1='\n\e[1;30m[\j:\!\e[1;30m]\e[0;36m \T \d \e[1;30m[\e[1;34m\u@\H\e[1;30m:\e[0;37m`tty 2>/dev/null` \e[0;32m+${SHLVL}\e[1;30m] \e[1;37m\w\e[0;37m\[\033]0;[ ${H1}... ] \w - \u@\H +$SHLVL @`tty 2>/dev/null` - [ `uptime` ]\007\]\n\[\]\$ '
        taocl
    elif [ "$1" -eq 12 ]
    then
        PS1='\n\e[1;30m[\j:\!\e[1;30m]\e[0;36m \T \d \e[1;30m[\e[1;34m\u@\H\e[1;30m:\e[0;37m`tty 2>/dev/null` \e[0;32m+${SHLVL}\e[1;30m] \e[1;37m\w\e[0;37m\[\033]0;[ ${H1}... ] \w - \u@\H +$SHLVL @`tty 2>/dev/null` - [ `uptime` ]\007\]\n\[\]\$ '
        taocl
    elif [ "$1" -eq 13 ]
    then
        PS1="\n[$?]\e[1;37m[\e[0;32m\u\e[0;35m@\e[0;32m\h\e[1;37m]\e[1;37m[\e[0;31m\w\e[1;37m]($SHLVL:\!)\n\[\033[0m\]\$ "
        taocl
    else
        printf "%s\n" "Bad input........->...#Try again↓"
	fi
}


sara()
{
   local colors=`tput colors 2>/dev/null||echo -n 1` C=;

   if [[ $colors -ge 256 ]]; then
      C="`tput setaf 33 2>/dev/null`";
      AA_P='mf=x mt=x n=0; while [[ $n < 1 ]];do read a mt a; read a mf a; (( n++ )); done</proc/meminfo; export AA_PP="\033[38;5;2m"$((mf/1024))/"\033[38;5;89m"$((mt/1024))MB; unset -v mf mt n a';
   else
      C="`tput setaf 4 2>/dev/null`";
      AA_P='mf=x mt=x n=0; while [[ $n < 1 ]];do read a mt a; read a mf a; (( n++ )); done</proc/meminfo; export AA_PP="\033[92m"$((mf/1024))/"\033[32m"$((mt/1024))MB; unset -v mf mt n a';
   fi;

   eval $AA_P; 

   PROMPT_COMMAND='stty echo; history -a; echo -en "\e[34h\e[?25h"; (($SECONDS % 2==0 )) && eval $AA_P; echo -en "$AA_PP";';
   SSH_TTY=${SSH_TTY:-`tty 2>/dev/null||readlink /proc/$$/fd/0 2>/dev/null`}

   PS1="\[\e[m\n\e[1;30m\][\$\$:\$PPID \j:\!\[\e[1;30m\]]\[\e[0;36m\] \T \d \[\e[1;30m\][${C}\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY/\/dev\/} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\]\n\\$ ";

   export PS1 AA_P PROMPT_COMMAND SSH_TTY
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
alias ls="ls --color=auto"

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
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/Unetbootin:/opt/bin
export EDITOR=nano
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/Unetbootin:/opt/bin:/usr/games
export PATH=/opt/vuze:$PATH
if [ -z "$SSH_AUTH_SOCK" ]
then
    eval `ssh-agent`
    ssh-add
fi

