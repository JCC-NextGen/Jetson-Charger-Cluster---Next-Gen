#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-22-2023
# Automates removing several users. Use at the end of the
# semester to remove user accounts for outgoing CPE 412/512
# students.
if [[ $# != 1 ]]; then
	echo "usage: bash remove_users.sh filename"
	exit 1
fi

while read -r user; do
	sudo userdel -r $user
done < $1
