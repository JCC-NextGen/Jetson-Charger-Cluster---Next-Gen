#!/bin/bash

# Author: Satyo Wasistho
# Date: 04-24-2023
# Command wrapper for the karqueue script.

# Standard option
if [[ $# == 0 ]]; then
	bash /home/jcccluster/JCCdev/karslurm/karqueue.sh
# Realtime option
elif [[ $1 == -rt ]]; then
	watch -n 1 bash /home/jcccluster/JCCdev/karslurm/karqueue.sh
# Usage guide
else
	echo "Usage: "
	echo "	karqueue"
	echo "		- for instantaneous monitoring"
	echo "		  of karslurm's job queue."
	echo "	karqueue -rt"
	echo "		- for continuous monitoring of"
	echo "		  karslurm's job queue."
fi
