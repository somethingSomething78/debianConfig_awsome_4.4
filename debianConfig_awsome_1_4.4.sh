#!/bin/bash -x

# redirect all errors to a file
exec 2>debianConfigVersion3.1ERRORS.txt
##################################################################################################### exec 3>cpSuccessCodes.txt ## 

SCRIPTNAME=$(basename "$0")

if [ "$UID" != 0 ]
    then
    echo "This program should be run as root, exiting! now....."
    exit 1
fi

if [ "$#" -eq 0 ]
then
    echo "RUN AS ROOT...Usage if you want to create users:...$SCRIPTNAME USER_1 USER_2 USER_3 etc."
    echo "If you create users they will be set with a semi strong password which you need to change later as root with passwd"
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
CURRENTDIR=/tmp/svaka
BASHRC=.bashrc
NANORC=.nanorc
BASHRCROOT=.bashrcroot
SOURCE=sources.list
#-----------------------------------------------------------------------↓↓
export DEBIAN_FRONTEND=noninteractive
#-----------------------------------------------------------------------↑↑

if grep "Port 22" /etc/ssh/sshd_config
then
    echo -n "Please select/provide the port-number for ssh in iptables and sshd_config:"
    read port ### when using the "-p" option then the value is stored in $REPLY
    PORT=$port
fi
############################### make all files writable, executable and readable in the working directory#########
if /bin/chmod -R 777 "$CURRENTDIR"
then
    :
else
    echo "chmod CURRENTDIR failed"
    sleep 3
    exit 127
fi

################ Creating new users #####################1

checkIfUser()
{
    for name in "$@"
    do
        if /usr/bin/id -u "$name" #>/dev/null 2>&1
        then
            echo "User: $name exists....setting up now!"
        else
            echo "User: $name does not exists....creating now!"
            /usr/sbin/useradd -m -s /bin/bash "$name" #>/dev/null 2>&1
        fi
    done
}

###########################################################################3
################# GET USERS ON THE SYSTEM ###################################

prepare_USERS()
{
	checkIfUser "$@"
	/usr/bin/awk -F: '$3 >= 1000 { print $1 }' /etc/passwd > "$CURRENTDIR"/USERS.txt

	/bin/chmod 777 "$CURRENTDIR"/USERS.txt
	if [[ ! -f "$CURRENTDIR"/USERS.txt && ! -w "$CURRENTDIR"/USERS.txt ]]
	then
		echo "USERS.txt doesn't exist or is not writable..exiting!"
		exit 127
	fi
	for user in "$@"
	do
		echo "$user" >> /tmp/svaka/USERS.txt || { echo "writing to USERS.txt failed"; exit 127; }
	done
}
###########################################################################33
################33 user passwords2
userPass()
{
	if [[ ! -f "$CURRENTDIR"/USERS.txt && ! -w "$CURRENTDIR"/USERS.txt ]]
	then
		echo "USERS.txt doesn't exist or is not writable..exiting!"
		exit 127
	fi
    while read i
    do
        if [ "$i" = root ]
        then
            continue
        fi
        if [[ $(/usr/bin/passwd --status "$i" | /usr/bin/awk '{print $2}') = NP ]] || [[ $(/usr/bin/passwd --status "$i" | /usr/bin/awk '{print $2}') = L ]] 
        then
            echo "$i doesn't have a password."
            echo "Changing password for $i:"
            echo $i:$i"YOURSTRONGPASSWORDHERE12345Áá" | /usr/sbin/chpasswd
            if [ "$?" = 0 ]
                then
                echo "Password for user $i changed successfully"
                sleep 5
            fi
        fi
	done < "$CURRENTDIR"/USERS.txt
}

################################################ setting up iptables ####################3
setUPiptables()
{
	#if ! grep -e '-A INPUT -p tcp --dport 80 -j ACCEPT' /etc/iptables.test.rules
    if [[ `/sbin/iptables-save | grep '^\-' | wc -l` > 0 ]]
	then
        echo "Iptables already set, skipping..........!"
    else
    	if [ "$PORT" = "" ]
    	then
        	echo "Port not set for iptables exiting"
        	echo -n "Setting port now, insert portnumber: "
        	read port
        	PORT=$port
    	fi
    	if [ ! -f /etc/iptables.test.rules ]
    	then
        	/usr/bin/touch /etc/iptables.test.rules
    	else
        	/bin/cat /dev/null > /etc/iptables.test.rules
    	fi

        /bin/cat << EOT >> /etc/iptables.test.rules
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
        /usr/bin/printf "#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules" > /etc/network/if-pre-up.d/iptables ## create a script to run iptables on startup
        /bin/chmod +x /etc/network/if-pre-up.d/iptables || { echo "chmod +x failed"; exit 127; }
    fi
}

###################################################33 sshd_config4
setUPsshd()
{
    if grep "Port $PORT" /etc/ssh/sshd_config
    then
        echo "sshd already set, skipping!"
    else

        if [ "$PORT" = "" ]
        then
            echo "Port not set"
            exit 12
        fi
        users=""
        /bin/cp -f "$CURRENTDIR"/sshd_config /etc/ssh/sshd_config
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

        /bin/chmod 644 /etc/ssh/sshd_config
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
    /usr/bin/apt update && /usr/bin/apt upgrade -y
}


###############################################################7
############################# check if programs installed and/or install
checkPrograms()
{
    if [ ! -x /usr/bin/git ] || [ ! -x /usr/bin/wget ] || [ ! -x /usr/bin/curl ] || [ ! -x /usr/bin/gcc ] || [ ! -x /usr/bin/make ]
    then
        echo "Some tools with which to work with data not found installing now......................"
        /usr/bin/apt install -y git wget curl gcc make
    fi
}

#####################################################3 update sources.list8
updateSources()
{
    if grep "deb http://www.deb-multimedia.org" /etc/apt/sources.list
    then
        echo "Sources are setup already, skipping!"
    else
        sudo /bin/cp -f "$CURRENTDIR"/"$SOURCE" /etc/apt/sources.list || { echo "sudo cp failed"; exit 127; }
        /bin/chmod 644 /etc/apt/sources.list
        /usr/bin/wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb || { echo "wget failed"; exit 127; }
        /usr/bin/dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
        /usr/bin/wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
        updateSystem || { echo "update system failed"; exit 127; }
        /usr/bin/apt install -y vlc vlc-data browser-plugin-vlc mplayer youtube-dl libdvdcss2 libdvdnav4 libdvdread4 smplayer mencoder build-essential
        sleep 3
        updateSystem || { echo "update system failed"; exit 127; }
        sleep 3
    fi
}

###############################################33  SETUP PORTSENTRY ############################################################
##############################################3                     ############################################################33

setup_portsentry()
{
    if  grep ! '^TCP_PORTS="1,7,9,11,15,70,79' /etc/portsentry/portsentry.conf
    then
        /usr/bin/apt install -y portsentry logcheck
        /bin/cp -f "$CURRENTDIR"/portsentry.conf /etc/portsentry/portsentry.conf || { echo "cp portsentry failed"; exit 127; }
        /usr/sbin/service portsentry restart || { echo "service portsentry restart failed"; exit 127; }
    fi
}

###############################################################################################################################33
#####################################################3 run methods here↓   ###################################################3
#####################################################                      ###################################################
prepare_USERS "$@"
userPass "$@"
setUPiptables
setUPsshd
editSources
updateSystem
setup_portsentry
checkPrograms
updateSources
###########################################################################################################            #####3##
##############################################################################################################3Methods
##########################################3 Disable login www #########
passwd -l www-data
#################################### firmware
apt install -y firmware-linux-nonfree firmware-linux
sleep 5
################ NANO SYNTAX-HIGHLIGHTING #####################3
if [ ! -d "$CURRENTDIR"/nanorc  ]
then
    if [ "$UID" != 0 ]
    then
        echo "This program should be run as root, goodbye!"
        exit 127

    else
        echo "Doing user: $USER....please, wait\!"
        /usr/bin/git clone https://$OAUTH_TOKEN:x-auth-basic@github.com/gnihtemoSgnihtemos/nanorc || { echo "git failed"; exit 127; }
        cd "$CURRENTDIR"/nanorc || { echo "cd failed"; exit 127; }
        /usr/bin/make install-global || { echo "make failed"; exit 127; }
        /bin/cp -f "$CURRENTDIR/$NANORC" /etc/nanorc >&3 || { echo "cp failed"; exit 127; }
        /bin/chown root:root /etc/nanorc || { echo "chown failed"; exit 127; }
        /bin/chmod 644 /etc/nanorc || { echo "chmod failed"; exit 127; }
        if [ "$?" = 0 ]
        then
            echo "Implementing a custom nanorc file succeeded!"
        else
            echo "Nano setup DID NOT SUCCEED\!"
            exit 127
        fi
        echo "Finished setting up nano!"
    fi
fi

################ LS_COLORS SETTINGS #############################
if ! grep 'eval $(dircolors -b $HOME/.dircolors)' /root/.bashrc
then
	echo "Setting root bashrc file....please wait!!!!"
    if /bin/cp -f "$CURRENTDIR/$BASHRCROOT" "$HOME"/.bashrc
    then
    	echo "Root bashrc copy succeeded!"
    else
        echo "Root bashrc cp failed, exiting now!"
        exit 127
    fi
    /bin/chown root:root "$HOME/.bashrc" || { echo "chown failed"; exit 127; }
	/bin/chmod 644 "$HOME/.bashrc" || { echo "failed to chmod"; exit 127; }
    /usr/bin/wget https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS -O "$HOME"/.dircolors || { echo "wget failed"; exit 127; }
    echo 'eval $(dircolors -b $HOME/.dircolors)' >> "$HOME"/.bashrc
fi
while read user
do
  	if [ "$user" = root ]
   	then
       	continue
   	fi
 
   	sudo -i -u "$user" user="$user" CURRENTDIR="$CURRENTDIR" BASHRC="$BASHRC" bash <<'EOF'
	if grep 'eval $(dircolors -b $HOME/.dircolors)' "$HOME"/.bashrc
	then
		:
	else
		echo "Setting users=Bashrc files!"
    	if /bin/cp -f "$CURRENTDIR"/"$BASHRC" "$HOME/.bashrc"
    	then
        	echo "Copy for $user (bashrc) succeeded!"
        	sleep 3
    	else
        	echo "Couldn't cp .bashrc for user $user"
        	exit 127
    	fi
    	/bin/chown $user:$user "$HOME/.bashrc" || { echo "chown failed"; exit 127; }
    	/bin/chmod 644 "$HOME/.bashrc" || { echo "chmod failed"; exit 127; }
    	/usr/bin/wget https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS -O "$HOME"/.dircolors || { echo "wget failed"; exit 127; }
    	echo 'eval $(dircolors -b $HOME/.dircolors)' >> "$HOME"/.bashrc
	fi
EOF
done < "$CURRENTDIR"/USERS.txt

echo "Finished setting up your system!"
cd ~/ || { echo "cd ~/ failed"; exit 155; }
rm -rf /tmp/svaka || { echo "Failed to remove the install directory!!!!!!!!"; exit 155; }

