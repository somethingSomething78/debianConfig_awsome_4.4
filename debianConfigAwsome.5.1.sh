#!/bin/bash -x

shopt -s -o nounset
####### Catch signals that could stop the script
trap : SIGINT SIGQUIT SIGTERM
#################################

# redirect all errors to a file                                                                    #### MUNA setja þetta í sshd_config="#HISTAMIN98"
if [ -w /tmp/svaka ]
then
	exec 2>debianConfigVersion4.9__ERRORS__.txt
else
	echo "can't write error file!"
	exit 127
fi
##################################################################################################### exec 3>cpSuccessCodes.txt ## 

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

### ↓↓↓↓ NEXT TIME USE "declare VARIABLE" ↓↓↓↓↓↓↓↓↓↓ #####
OAUTH_TOKEN=d6637f7ccf109a0171a2f55d21b6ca43ff053616
WORK_DIR=/tmp/svaka
BASHRC=.bashrc
NANORC=.nanorc
BASHRCROOT=.bashrcroot
SOURCE=sources.list
PORT=""
#-----------------------------------------------------------------------↓↓
export DEBIAN_FRONTEND=noninteractive
#-----------------------------------------------------------------------↑↑

############################### make all files writable, executable and readable in the working directory#########
if ! chown -R root:root "$WORK_DIR"
then
    echo "chown WORK_DIR failed"
    sleep 3
    exit 127
fi

if ! chmod -R 750 "$WORK_DIR"
then
    echo "chmod WORK_DIR failed"
    sleep 3
    exit 127
fi

############################################################## Check if files exist and are writable ########################################################

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

########################################### Check if PORT is set and if sshd_config is set and if PORT is set in iptables ###############################################3
if [[ $PORT == "" ]] || [[ ! `grep "#HISTAMIN98" /etc/ssh/sshd_config` ]] || [[ ! `grep $PORT /etc/iptables.up.rules` ]]  ##[[ ! `/sbin/iptables-save | grep '^\-' | wc -l` > 0 ]]
then
    echo -n "Please select/provide the port-number for ssh in iptables setup or sshd_config file:"
    read port ### when using the "-p" option then the value is stored in $REPLY
    PORT=$port
fi


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
    while read user
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
            echo $user:$user"YOURSTRONGPASSWORDHERE12345Áá" | /usr/sbin/chpasswd
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
    if [[ `/sbin/iptables-save | grep '^\-' | wc -l` > 0 ]]
	then
        echo "Iptables already set, skipping..........!"
        sleep 2
    else
    	if [ "$PORT" = "" ]
    	then
        	echo "Port not set for iptables, setting now......."
        	echo -n "Setting port now, insert portnumber: "
        	read port
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
        sed -i "s/Port 34504/Port $PORT/" /etc/ssh/sshd_config
        for user in `awk -F: '$3 >= 1000 { print $1 }' /etc/passwd`
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
    if [ ! -x /usr/bin/git ] || [ ! -x /usr/bin/wget ] || [ ! -x /usr/bin/curl ] || [ ! -x /usr/bin/gcc ] || [ ! -x /usr/bin/make ]
    then
        echo "Some tools with which to work with data not found installing now......................"
        sleep 2
        apt install -y git wget curl gcc make
    fi
}

#####################################################3 update sources.list8
updateSources()
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
        apt install -y vlc vlc-data browser-plugin-vlc mplayer youtube-dl libdvdcss2 libdvdnav4 libdvdread4 smplayer mencoder build-essential
        sleep 2
    fi
}

###############################################33  SETUP PORTSENTRY ############################################################
##############################################3                     ############################################################33

setup_portsentry()
{
    if  ! grep -q '^TCP_PORTS="1,7,9,11,15,70,79' /etc/portsentry/portsentry.conf || [[ ! -f /etc/portsentry/portsentry.conf ]]
    then
        apt install -y portsentry logcheck
        /bin/cp -f "$WORK_DIR"/portsentry.conf /etc/portsentry/portsentry.conf || { echo "cp portsentry failed"; exit 127; }
        /usr/sbin/service portsentry restart || { echo "service portsentry restart failed"; exit 127; }
    fi
}

###############################################################################################################################33
#####################################################3 run methods here↓   ###################################################3
#####################################################                      ###################################################
if [[ ! "$@" == "" ]]
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
updateSources
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
        cd "$WORK_DIR"
        git clone https://$OAUTH_TOKEN:x-auth-basic@github.com/gnihtemoSgnihtemos/nanorc || { echo "git failed"; exit 127; }
        chmod 755 "$WORK_DIR"/nanorc || { echo "chmod nanorc failed"; exit 127; }
        cd "$WORK_DIR"/nanorc || { echo "cd failed"; exit 127; }
        make install-global || { echo "make failed"; exit 127; }
        /bin/cp -f "$WORK_DIR/$NANORC" /etc/nanorc >&3 || { echo "cp failed"; exit 127; }
        chown root:root /etc/nanorc || { echo "chown failed"; exit 127; }
        chmod 644 /etc/nanorc || { echo "chmod failed"; exit 127; }
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
    else
        echo "Root bashrc cp failed, exiting now!"
        exit 127
    fi
    chown root:root "$HOME/.bashrc" || { echo "chown failed"; exit 127; }
	chmod 644 "$HOME/.bashrc" || { echo "failed to chmod"; exit 127; }
    wget https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS -O "$HOME"/.dircolors || { echo "wget failed"; exit 127; }
    echo 'eval $(dircolors -b $HOME/.dircolors)' >> "$HOME"/.bashrc
fi
while read user
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
        	sleep 3
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
cd $HOME || { echo "cd $HOME failed"; exit 155; }
######### REmember to uncomment below echo to remove the install files after installation/configuration.......↓↓↓
echo rm -rf /tmp/svaka || { echo "Failed to remove the install directory!!!!!!!!"; exit 155; }
exit 0
