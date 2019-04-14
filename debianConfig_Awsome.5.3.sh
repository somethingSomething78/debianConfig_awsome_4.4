#!/bin/bash -x

########### Copy or Move the accompanied directory called "svaka" to /tmp ######################
################################################################################################

################## shopt (shopt [-pqsu] [-o] [optname …]) = This builtin allows you to change additional shell optional behavior. 
################## -s = Enable (set) each optname.
################## -o = Restricts the values of optname to be those defined for the -o option to the set builtin (see The Set Builtin). 
################## nounset = Treat unset variables and parameters other than the special parameters ‘@’ or ‘*’ as an error when performing parameter expansion. An
# error message will be written to the standard error, and a non-interactive shell will exit.
################## The Set Builtin
#This builtin is so complicated that it deserves its own section. set allows you to change the values of shell options and set the positional parameters, or to
#display the names and values of shell variables. 
shopt -s -o nounset

############################################################
#The set -e option instructs bash to immediately exit if any command [1] has a non-zero exit status. You wouldn't want to set this for your command-line shell, 
#but in a script it's massively helpful. In all widely used general-purpose programming languages, an unhandled runtime error - whether that's a thrown exception
#in Java, or #a segmentation fault in C, or a syntax error in Python - immediately halts execution of the program; subsequent lines are not executed.

#set -u affects variables. When set, a reference to any variable you haven't previously defined - with the exceptions of $* and $@ - is an error, and causes the
#program to immediately exit. Languages like Python, C, Java and more all behave the same way, for all sorts of good reasons. One is so typos don't create new
#variables without you realizing it.

#set -o pipefail
#This setting prevents errors in a pipeline from being masked. If any command in a pipeline fails, that return code will be used as the return code of the whole
#pipeline. By default, the pipeline's return code is that of the last command - even if it succeeds. Imagine finding a sorted list of matching lines in a file:

#    % grep some-string /non/existent/file | sort
#    grep: /non/existent/file: No such file or directory
#    % echo $?
#    0
#set -euo pipefail
#set -euo pipefail
#####33 Also use this↓↓↓↓↓↑↑↑↑↑↑↑↑↑↑
#set -euo pipefail
IFS_OLD=$IFS
IFS=$'\n\t'
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
#Setting IFS to $'\n\t' means that word splitting will happen only on newlines and tab characters. This very often produces useful splitting behavior. By default, 
#bash sets this to $' \n\t' - space, newline, tab - which is too eager.
#######################↑↑↑↑↑↑↑↑
#
################################### Successful exit then this cleanup ###########################################################3

#successfulExit()
#{
#    IFS=$IFS_OLD
#    cd "$HOME" || { echo "cd $HOME failed"; exit 155; }
#    rm -rf /tmp/svaka || { echo "Failed to remove the install directory!!!!!!!!"; exit 155; }
#}
################################### Better cleanup code: THANKS GILLES OG UNIX&LINUXstackexchange #####################################################

cleanup ()
{
    if [ -n "$1" ]; then
        echo "Aborted by $1"
    elif [ $status -ne 0 ]; then
        echo "Failure (status $status)"
    else
        echo "Success"
        IFS=$IFS_OLD
        cd "$HOME" || { echo "cd $HOME failed"; exit 155; }
        rm -rf /tmp/svaka || { echo "Failed to remove the install directory!!!!!!!!"; exit 155; }
    fi
}
trap 'status=$?; cleanup; exit $status' EXIT
trap 'trap - HUP; cleanup SIGHUP; kill -HUP $$' HUP
#trap 'trap - INT; cleanup SIGINT; kill -INT $$' INT
#trap 'trap - TERM; cleanup SIGTERM; kill -TERM $$' TERM

###############################################################################################################################33
####### Catch the program on successful exit and cleanup
#trap successfulExit EXIT
####### Catch signals that could stop the script
trap : SIGINT SIGQUIT SIGTERM
#################################

####################################################### Setup system to send email with your google/gmail account and sendmail ##############################
######################################################## TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO ##############################


# Configuring Gmail as a Sendmail email relay
#
#
#Introduction
#
#In this configuration tutorial we will guide you through the process of configuring sendmail to be an email relay for your gmail or google apps account. 
#This allows #you to send email from your bash scripts, hosted website or from command line using mail command. 
#Other examples where you can utilize this setting is for a #notification purposes such or failed backups etc.
#Sendmail is just one of many utilities which can be configured to rely on gmail account where the others include #postfix, exim , ssmpt etc. 
#In this tutorial we will use Debian and sendmail for this task.
#Install prerequisites
#
## CODE:apt-get install sendmail mailutils sendmail-bin 
#
#Create Gmail Authentication file
#
## CODE:mkdir -m 700 /etc/mail/authinfo/
## CODE:cd /etc/mail/authinfo/
#
#next we need to create an auth file with a following content. File can have any name, in this example the name is gmail-auth:
#
# CODE: printf 'AuthInfo: "U:root" "I:YOUR GMAIL EMAIL ADDRESS" "P:YOUR PASSWORD"\n' > gmail-auth
#
#Replace the above email with your gmail or google apps email.
#
#Please note that in the above password example you need to keep 'P:' as it is not a part of the actual password.
#
#In the next step we will need to create a hash map for the above authentication file:
#
## CODE:makemap hash gmail-auth < gmail-auth
#
#Configure your sendmail 
#
#Put bellow lines into your sendmail.mc configuration file right above first "MAILER" definition line: ######################################################
#
#define(`SMART_HOST',`[smtp.gmail.com]')dnl
#define(`RELAY_MAILER_ARGS', `TCP $h 587')dnl
#define(`ESMTP_MAILER_ARGS', `TCP $h 587')dnl
#define(`confAUTH_OPTIONS', `A p')dnl
#TRUST_AUTH_MECH(`EXTERNAL DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl
#define(`confAUTH_MECHANISMS', `EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl
#FEATURE(`authinfo',`hash -o /etc/mail/authinfo/gmail-auth.db')dnl
#############################################################################################################################################################
#Do not put the above lines on the top of your sendmail.mc configuration file !
#
#In the next step we will need to re-build sendmail's configuration. To do that execute:
#
## CODE: make -C /etc/mail
#
#Reload sendmail service:
#
# CODE:/etc/init.d/sendmail reload
#
#and you are done.
#Configuration test
#
#Now you can send an email from your command line using mail command:
#
# CODE: echo "Just testing my sendmail gmail relay" | mail -s "Sendmail gmail Relay" "This email address is being protected from spambots."
#

#######################################################3 Trap signals and exit to send email on it #######################################################
#trap 'echo "Subject: Program finsihed execution" | sendmail -v "This email address is being protected from spambots."' exit # It will mail on normal exit
#trap 'echo "Subject: Program interrupted" | /usr/sbin/sendmail -v "This email address is being protected from spambots."' INT HUP
# it will mail on interrupt or hangup  of the process

# redirect all errors to a file                                                                    #### MUNA setja þetta í sshd_config="#HISTAMIN98"
if [ -w /tmp/svaka ]
then
	exec 2>debianConfigVersion5.3__ERRORS__.txt
else
	echo "can't write error file!"
	exit 127
fi
##################################################################################################### TODO exec 3>cpSuccessCodes.txt ## 
#############################################################################################################


SCRIPTNAME=$(basename "$0")

if [ "$UID" != 0 ]
    then
    echo "This program should be run as root, exiting! now....."
    sleep 3
    exit 1
fi

if [ "$#" -eq 0 ]
then
    echo "RUN AS ROOT...Usage if you want to create users:...$SCRIPTNAME USER_1 USER_2 USER_3 etc."
    echo "If you create users they will be set with a semi strong password which you need to change later as root with the passwd command"
    echo
    echo
    echo "#################### ↓↓↓↓↓↓↓↓↓↓↓ OR ↓↓↓↓↓↓↓↓↓↓ #############################"
    echo
    echo
    echo "RUN AS ROOT...Usage without creating users: $SCRIPTNAME"
    echo
    sleep 10

fi

echo "Here starts the party!"
echo "Setting up server..........please wait!!!!!"
sleep 3

### ↓↓↓↓ Initialization of VARIABLES............NEXT TIME USE "declare VARIABLE" ↓↓↓↓↓↓↓↓↓↓ #####
OAUTH_TOKEN=d6637f7ccf109a0171a2f55d21b6ca43ff053616
WORK_DIR=/tmp/svaka
BASHRC=.bashrc
NANORC=.nanorc
BASHRCROOT=.bashrcroot
SOURCE=sources.list
PORT=""

########### Commands
PWD=$(pwd)

#-----------------------------------------------------------------------↓↓
export DEBIAN_FRONTEND=noninteractive
#-----------------------------------------------------------------------↑↑

################ Enter the working directory where all work happens ##########################################
cd "$WORK_DIR" || { echo "cd $WORK_DIR failed"; exit 127; }

############################### make all files writable, executable and readable in the working directory#########
if ! chown -R root:root "$WORK_DIR"
then
    echo "chown WORK_DIR failed"
    exit 127
fi

if ! chmod -R 750 "$WORK_DIR"
then
    echo "chmod WORK_DIR failed"
    exit 127
fi

############################################################## Check if files exist and are writable #########################################

if [[ ! -f "$WORK_DIR"/.bashrc && ! -w "$WORK_DIR"/.bashrc ]]
then
    echo "missing .bashrc file or is not writable.. exiting now....." && { exit 127; }
fi
if [[ ! -f "$WORK_DIR"/.nanorc && ! -w "$WORK_DIR"/.nanorc ]]
then
    echo "missing .nanorc file or is not writable.. exiting now....." && { exit 127; }
fi
    if [[ ! -f "$WORK_DIR"/.bashrcroot && ! -w "$WORK_DIR"/.bashrcroot ]]
then
    echo "missing .bashrcroot file or is not writable..exiting now....." && { exit 127; }
fi
if [[ ! -f "$WORK_DIR"/sources.list && ! -w "$WORK_DIR"/sources.list ]]
then
    echo "missing sources.list file or is not writable..exiting now....." && { exit 127; }
fi

########################################### Check if PORT is set and if sshd_config is set and if PORT is set in iptables ####################
if [[ $PORT == "" ]] && ! grep -q "#HISTAMIN98" /etc/ssh/sshd_config && ! grep -q $PORT /etc/iptables.up.rules 
then
    echo -n "Please select/provide the port-number for ssh in iptables setup or sshd_config file:"
    read -r port ### when using the "-p" option then the value is stored in $REPLY
    PORT=$port
fi

############################ Check internet connection ##############################
checkInternet()
{
    ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && return 0 || return 1
}

################ Creating new users #####################1

creatingNewUsers()
{
    for name in "$@"
    do
        if id -u "$name" #>/dev/null 2>&1
        then
            echo "User: $name exists....setting up now!"
            sleep 2
        else
            echo "User: $name does not exists....creating now!"            
            useradd -m -s /bin/bash "$name" #>/dev/null 2>&1
            sleep 2
        fi
    done
}

###########################################################################3
################# GET USERS ON THE SYSTEM ###################################

prepare_USERS.txt()
{
	awk -F: '$3 >= 1000 { print $1 }' /etc/passwd > "$WORK_DIR"/USERS.txt

	chmod 750 "$WORK_DIR"/USERS.txt
	if [[ ! -f "$WORK_DIR"/USERS.txt && ! -w "$WORK_DIR"/USERS.txt ]]
	then
		echo "USERS.txt doesn't exist or is not writable..exiting!"
		sleep 3
		exit 127
	fi
#	if [[ ! "$@" == "" ]]
#	then
#        for user in "$@"
#        do
#            echo "$user" >> /tmp/svaka/USERS.txt || { echo "writing to USERS.txt failed"; exit 127; }
#        done
#    fi
}
###########################################################################33
################33 user passwords2
userPasswords()
{
	if [[ ! -f "$WORK_DIR"/USERS.txt && ! -w "$WORK_DIR"/USERS.txt ]]
	then
		echo "USERS.txt doesn't exist or is not writable..exiting!"
		sleep 3
		exit 127
	fi
    while read -r user
    do
        if [ "$user" = root ]
        then
            continue
        fi
        if [[ $(passwd --status "$user" | awk '{print $2}') = NP ]] || [[ $(passwd --status "$user" | awk '{print $2}') = L ]] 
        then
            echo "$user doesn't have a password."
            echo "Changing password for $user:"
            sleep 3
            echo "$user":"$user""YOURSTRONGPASSWORDHERE12345Áá" | /usr/sbin/chpasswd
            if [ "$?" = 0 ]
                then
                echo "Password for user $user changed successfully"
                sleep 3
            fi
        fi
	done < "$WORK_DIR"/USERS.txt
}

################################################ setting up iptables ####################3
setUPiptables()
{
	#if ! grep -e '-A INPUT -p tcp --dport 80 -j ACCEPT' /etc/iptables.test.rules
    if [[ $(/sbin/iptables-save | grep -c '^\-') -gt 0 ]]
	then
        echo "Iptables already set, skipping..........!"
        sleep 2
    else
    	if [ "$PORT" = "" ]
    	then
        	echo "Port not set for iptables, setting now......."
        	echo -n "Setting port now, insert portnumber: "
        	read -r port
        	PORT=$port
    	fi
    	if [ ! -f /etc/iptables.test.rules ]
    	then
        	touch /etc/iptables.test.rules
    	else
        	cat /dev/null > /etc/iptables.test.rules
    	fi

        cat << EOT >> /etc/iptables.test.rules
        *filter

        # Allows all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
        -A INPUT -i lo -j ACCEPT
        -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT

        # Accepts all established inbound connections
        -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

        # Allows all outbound traffic
        # You could modify this to only allow certain traffic
        -A OUTPUT -j ACCEPT

        # Allows HTTP and HTTPS connections from anywhere (the normal ports for websites)
        -A INPUT -p tcp --dport 80 -j ACCEPT
        -A INPUT -p tcp --dport 443 -j ACCEPT

        # Allows SSH connections
        # The --dport number is the same as in /etc/ssh/sshd_config
        -A INPUT -p tcp -m state --state NEW --dport $PORT -j ACCEPT

        # Now you should read up on iptables rules and consider whether ssh access
        # for everyone is really desired. Most likely you will only allow access from certain IPs.

        # Allow ping
        #  note that blocking other types of icmp packets is considered a bad idea by some
        #  remove -m icmp --icmp-type 8 from this line to allow all kinds of icmp:
        #  https://security.stackexchange.com/questions/22711
        -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

        # log iptables denied calls (access via dmesg command)
        -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

        # Reject all other inbound - default deny unless explicitly allowed policy:
        -A INPUT -j REJECT
        -A FORWARD -j REJECT

        COMMIT
EOT
        sed "s/^[ \t]*//" -i /etc/iptables.test.rules ## remove tabs and spaces
        /sbin/iptables-restore < /etc/iptables.test.rules || { echo "iptables-restore failed"; exit 127; }
        /sbin/iptables-save > /etc/iptables.up.rules || { echo "iptables-save failed"; exit 127; }
        printf "#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules" > /etc/network/if-pre-up.d/iptables ## create a script to run iptables on startup
        chmod +x /etc/network/if-pre-up.d/iptables || { echo "chmod +x failed"; exit 127; }
    fi
}

###################################################33 sshd_config4
setUPsshd()
{
    if grep "Port $PORT" /etc/ssh/sshd_config
    then
        echo "sshd already set, skipping!"
        sleep 3
    else

        if [ "$PORT" = "" ]
        then
            echo "Port not set"
            sleep 3
            exit 12
        fi
        users=""
        /bin/cp -f "$WORK_DIR"/sshd_config /etc/ssh/sshd_config
        sed -i "s/Port 22300/Port $PORT/" /etc/ssh/sshd_config
        for user in $(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd)
        do
            users+="${user} "
        done
        if grep "AllowUsers" /etc/ssh/sshd_config
        then
            sed -i "/AllowUsers/c\AllowUsers $users" /etc/ssh/sshd_config
        else
            sed -i "6 a \
            AllowUsers $users" /etc/ssh/sshd_config
        fi

        chmod 644 /etc/ssh/sshd_config
        /etc/init.d/ssh restart
    fi
}

#################################################3333 Remove or comment out DVD/cd line from sources.list5
editSources()
{
    if grep '^# *deb cdrom:\[Debian' /etc/apt/sources.list
    then
        echo "cd already commented out, skipping!"
    else
        sed -i '/deb cdrom:\[Debian GNU\/Linux/s/^/#/' /etc/apt/sources.list
    fi
}

####################################################33 update system6

updateSystem()
{
    apt update && apt upgrade -y
}


###############################################################7
############################# check if programs installed and/or install
checkPrograms()
{
    if [ ! -x /usr/bin/git ] && [ ! -x /usr/bin/wget ] && [ ! -x /usr/bin/curl ] && [ ! -x /usr/bin/gcc ] && [ ! -x /usr/bin/make ]
    then
        echo "Some tools with which to work with data not found installing now......................"
        sleep 2
        apt install -y git wget curl gcc make
    fi
}

#####################################################3 update sources.list and install software ############################################################
updateSources_installSoftware()
{
    if grep "deb http://www.deb-multimedia.org" /etc/apt/sources.list
    then
        echo "Sources are setup already, skipping!"
    else
        /bin/cp -f "$WORK_DIR"/"$SOURCE" /etc/apt/sources.list || { echo "cp failed"; exit 127; }
        chmod 644 /etc/apt/sources.list
        wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb || { echo "wget failed"; exit 127; }
        dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
        wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
        updateSystem || { echo "update system failed"; exit 127; }
        apt install -y vlc vlc-data browser-plugin-vlc mplayer youtube-dl libdvdcss2 libdvdnav4 libdvdread4 smplayer mencoder build-essential \
        gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-vaapi lame libfaac0 aacskeys libbdplus0 libbluray1 audacious audacious-plugins \
        deadbeef kodi audacity cinelerra handbrake-gtk ffmpeg amarok k3b || { echo "some software failed to install!!!!!"; echo "some software failed to install"; \
        sleep 10; }
        ########################## Install flash in Mozilla Firefox ############################################
        wget https://raw.githubusercontent.com/cybernova/fireflashupdate/master/fireflashupdate.sh || { echo "wget flash failed"; sleep 4; exit 127; }
        chmod +x fireflashupdate.sh || { echo "chmod flash failed"; sleep 4; exit 127; }
        ./fireflashupdate.sh
        ######################### Setup the update tool to update flash weekly ###################################3
        chown root:root fireflashupdate.sh || { echo "chown flash failed"; sleep 4; exit 127; }
        /bin/mv fireflashupdate.sh /etc/cron.weekly/fireflashupdate || { echo "mv flash script failed"; sleep 4; exit 127; }
        
    fi
}

###############################################33  SETUP PORTSENTRY ############################################################
##############################################3                     ############################################################33

setup_portsentry()
{
    if  ! grep -q '^TCP_PORTS="1,7,9,11,15,70,79' /etc/portsentry/portsentry.conf
    then
        if [[ -f /etc/portsentry/portsentry.conf ]]
        then
            /bin/mv /etc/portsentry/portsentry.conf /etc/portsentry/portsentry.old
        fi
        if [[ ! -x /usr/sbin/portsentry ]]
        then
            apt install -y portsentry logcheck
            /bin/cp -f "$WORK_DIR"/portsentry.conf /etc/portsentry/portsentry.conf || { echo "cp portsentry failed"; exit 127; }
            /usr/sbin/service portsentry restart || { echo "service portsentry restart failed"; exit 127; }
        fi
    fi
}

#####################################################3 run methods here↓   ###################################################3
#####################################################                      ###################################################
checkInternet || (echo "no network, bye" && exit 199)
if [[ ! "$*" == "" ]]
then
    creatingNewUsers "$@"
fi
prepare_USERS.txt
userPasswords
setUPiptables
setUPsshd
editSources
updateSystem
#setup_portsentry    ######3 NEEDS WORK ##################################
checkPrograms
updateSources_installSoftware
###########################################################################################################            #####3##
##############################################################################################################3Methods
##########################################3 Disable login for www-data #########
passwd -l www-data
#################################### firmware
apt install -y firmware-linux-nonfree firmware-linux
apt install -y firmware-linux-free intel-microcode
sleep 3
################ NANO SYNTAX-HIGHLIGHTING #####################3
if [ ! -d "$WORK_DIR"/nanorc  ]
then
    if [ "$UID" != 0 ]
    then
        echo "This program should be run as root, goodbye!"
        exit 127

    else
        echo "Setting up Nanorc file for all users....please, wait!"
        if [[ $PWD == "$WORK_DIR" ]]
        then
            echo "Program is in WORK_DIR...success!......."
        else
            echo "not in WORK_DIR...TRYING 'cd WORK_DIR'"
            cd "$WORK_DIR" || { echo "cd failed"; exit 127; }
        fi
        git clone https://$OAUTH_TOKEN:x-auth-basic@github.com/gnihtemoSgnihtemos/nanorc || { echo "git in Nano SYNTAX-HIGHLIGHTING failed"; exit 127; }
        chmod 755 "$WORK_DIR"/nanorc || { echo "chmod in Nano SYNTAX-HIGHLIGHTING failed"; exit 127; }
        cd "$WORK_DIR"/nanorc || { echo "cd in Nano SYNTAX-HIGHLIGHTING failed"; exit 127; }
        make install-global || { echo "make in Nano SYNTAX-HIGHLIGHTING failed"; exit 127; }
        /bin/cp -f "$WORK_DIR/$NANORC" /etc/nanorc || { echo "cp in Nano SYNTAX-HIGHLIGHTING failed"; exit 127; }
        chown root:root /etc/nanorc || { echo "chown in Nano SYNTAX-HIGHLIGHTING failed"; exit 127; }
        chmod 644 /etc/nanorc || { echo "chmod in Nano SYNTAX-HIGHLIGHTING failed"; exit 127; }
        if [ "$?" = 0 ]
        then
            echo "Implementing a custom nanorc file succeeded!"
        else
            echo "Nano setup DID NOT SUCCEED!"
            exit 127
        fi
        echo "Finished setting up nano!"
    fi
fi

################ LS_COLORS SETTINGS and bashrc file for all users #############################
if ! grep 'eval $(dircolors -b $HOME/.dircolors)' /root/.bashrc
then
	echo "Setting root bashrc file....please wait!!!!"
    if /bin/cp -f "$WORK_DIR/$BASHRCROOT" "$HOME"/.bashrc
    then
    	echo "Root bashrc copy succeeded!"
    	sleep 2
    else
        echo "Root bashrc cp failed, exiting now!"
        exit 127
    fi
    chown root:root "$HOME/.bashrc" || { echo "chown failed"; exit 127; }
	chmod 644 "$HOME/.bashrc" || { echo "failed to chmod"; exit 127; }
    wget https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS -O "$HOME"/.dircolors || { echo "wget failed"; exit 127; }
    echo 'eval $(dircolors -b $HOME/.dircolors)' >> "$HOME"/.bashrc || { echo "echo 'eval...dircolors -b'....to bashrc failed"; exit 127; }
fi
while read -r user
do
  	if [ "$user" = root ]
   	then
       	continue
   	fi
 
   	sudo -i -u "$user" user="$user" WORK_DIR="$WORK_DIR" BASHRC="$BASHRC" bash <<'EOF'
	if grep 'eval $(dircolors -b $HOME/.dircolors)' "$HOME"/.bashrc
	then
		:
	else
		echo "Setting users=Bashrc files!"
    	if /bin/cp -f "$WORK_DIR"/"$BASHRC" "$HOME/.bashrc"
    	then
        	echo "Copy for $user (bashrc) succeeded!"
        	sleep 2
    	else
        	echo "Couldn't cp .bashrc for user $user"
        	exit 127
    	fi
    	chown $user:$user "$HOME/.bashrc" || { echo "chown failed"; exit 127; }
    	chmod 644 "$HOME/.bashrc" || { echo "chmod failed"; exit 127; }
    	wget https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS -O "$HOME"/.dircolors || { echo "wget failed"; exit 127; }
    	echo 'eval $(dircolors -b $HOME/.dircolors)' >> "$HOME"/.bashrc
	fi
EOF
done < "$WORK_DIR"/USERS.txt

echo "Finished setting up your system!"
sleep 2
############ Give control back to these signals
trap SIGINT SIGQUIT SIGTERM
############################

exit 0
