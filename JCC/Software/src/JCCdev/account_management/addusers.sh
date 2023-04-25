#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-22-2023
# Automates adding several users to the JCC and setting up
# environments for each of them. Use at the start of the 
# semester to set up user accounts to CPE 412/512 students.

# Parameter checking/Usage guide
if [[ $# == 1 ]]; then
	group=Users
	file=$1
elif [[ $# == 2 ]]; then
	group=$1
	file=$2
else
	echo "Usage: "
	echo "	addusers <group> <filename>"
	echo "	addusers <filename>"
	echo "--------------------------------------"
	echo "group: Group to add the new users to; can be any of the following:"
	echo "	Users"
	echo "	Staff"
	echo "	Admin"
	echo "	Research"
	echo "filename:	Name of the file containing usernames for all new users"
	
	exit 1
fi

if [[ $group != Users ]] && [[ $group != Staff ]] && [[ $group != Admin ]] && [[ $group != Research ]]; then
	echo "Usage: "
        echo "  addusers <group> <filename>"
        echo "  addusers_users.sh <filename>"
        echo "--------------------------------------"
        echo "group: Group to add the new users to; can be any of the following:"
        echo "  Users"
        echo "  Staff"
        echo "  Admin"
        echo "  Research"
        echo "filename: Name of the file containing usernames for all new users"
	
	exit 1
fi

# creates a user for every name in the given input file and adds them
# to the given group. Default password is 'WelcomeToJCC'.
while read -r username; do
	sudo useradd -s /bin/bash -m -d /home/$group/$username $username
	echo $username:WelcomeToJCC | sudo chpasswd
	sudo usermod -aG $group $username
	if [[ $group == Users ]]; then
		sudo chmod 707 /home/$group/$username
	else
		sudo chmod 700 /home/$group/$username
	fi
	sudo chown :$group /home/$group/$username
done < $file
