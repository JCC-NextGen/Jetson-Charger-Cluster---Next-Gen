#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-24-2023
# This shows all karslurm jobs currently running on the JCC along with their execution times.

# Jobs are logged with their start time. We use the current time to find the elapsed time
# between each job's start and now.
dt=$(date +%s) 

#Jobs are logged in a file. We just read the file to find the currently running ones.
echo "jobID	exe	time"
echo "----------------------"
while read -r job; do
	arr=(${job//;/ })
	sec=$(( $dt - ${arr[2]} ))
	printf "%d\t%s\t%02d:%02d:%02d\n" ${arr[0]} ${arr[1]} $(( sec / 3600 )) $(( sec / 60 )) $(( sec % 60))
done < /home/jcccluster/JCCdev/karslurm/karqueue
