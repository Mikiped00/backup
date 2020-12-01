#!/bin/bash
# Created by Kaputt4 and Mikiped00
#

#
# Function checkCommands()
# Check all necessary commands are installed
#

function checkCommands(){
	for mandate in "tree" "tar" "cat" "cut" "grep" "date" "wc"
	do
		if ! $mandate --version &> /dev/null
		then
			ERROR=2
			echo -e "\n Command $mandate Not found. \n Execute sudo apt-get $mandate or update using sudo apt-get update && sudo apt-get upgrade"
		fi
	done
}
#
# Function copy()
# Receive an user like argument and checks if /home exits then compress it in /tmp
#

function copy(){
	# Checks if user has /home
	if test `cat /etc/passwd | cut -d: -f1,6 | grep -w -c ^$USERV:/home` -gt 0
	then
		if test `cat /etc/passwd | cut -d: -f1,7 | grep -c ^$USERV:.*/nologin` -eq 0
		then
			echo -e " \nCopying $USERV"
			echo -e " \tCompressing: $(tree --noreport /home/$USERV | wc -l) files and directories"
			tar --exclude=".*" -czf /tmp/$USERV"_"$(date +%Y_%m_%d).tar.gz -C /home/ $USERV 2> /dev/null #Compress /home
			# Checks compressing errors
			if test "${PIPESTATUS[0]}" -ne 2
			then
				((COUNT+=1))
				echo -e "\n\tFile $USERV"_"$(date +%Y_%m_%d).tar.gz was succesfully created with permissions: `ls -l /tmp/$USERV"_"$(date +%Y_%m_%d).tar.gz | cut -d' ' -f1` "
			else
				# Send error to stderr
				>&2 echo -e "\tError compressing files."
				ERROR=1
			fi
		else
			# Send error to stderr
			>&2 echo -e " \nUser $USERV can not be used to login. /home does not exist."
		fi
	else
		echo -e " \nUser $USERV does not have /home/$USERV"
	fi
}


# Print name
echo -e "\n\n ____                _                  \n|  _ \              | |                 \n| |_) |  __ _   ___ | | __ _   _  _ __  \n|  _ <  / _\` | / __|| |/ /| | | || '_ \ \n| |_) || (_| || (__ |   < | |_| || |_) |\n|____/  \__,_| \___||_|\_\ \__,_|| .__/ \n                                 | |    \n                                 |_|    \n"
echo "Created by Kaputt4 and Mikiped00"

echo -e "\nUser $USER is going to do a backup:"
echo -e "Date: `date`." 
echo -e "Bash version: $BASH_VERSION "
ERROR=0 # Saves error's value.
COUNT=0 #  Counts .tar.gz files generated.

# Checks that all necessary commands are installed
checkCommands
if test $ERROR -eq 0
then
	# Check argument's number
	if test $# -ne 0
	then 
		re="^[a-zA-Z][-A-Za-z0-9_]*\$" # Character's allowed
		# Check parameter. If a parameter has incorrect sintax then stop executing. 
		for PARAM in $@ 
		do
			if ! [[ $PARAM =~ $re ]]
			then
				ERROR=2
			fi
		done
		if  test $ERROR -ne 2 
		then
			# For each param, checks if it exists, then calls copy(). If it not exists, returns error code 1 but keeps executing. 
			for USERV in $@
			do
				EXIST=`cat /etc/passwd | cut -d: -f1,6 | grep -w -c $USERV` 
				if test $EXIST -eq 1 ## if test -z $EXIST 
				then	
					copy $USERV					
				else
					ERROR=1
					# Sent error to stderr
					>&2 echo -e "\nUser $USERV is not registered in the system."
				fi
			done
		else
			# Send error to stderr
			>&2 echo -e "\nArguments do not have the correct syntax."
		fi
	else
		# Execute copy() for each user in /etc/passwd
		for USERV in `cat /etc/passwd | cut -d: -f1`
		do 
			copy $USERV
		done 
	fi
fi
# If none files were generated, then return 2.
if test $COUNT -eq 0; then ERROR=2; fi
echo -e "\n$COUNT  compressed files were created."
exit $ERROR
