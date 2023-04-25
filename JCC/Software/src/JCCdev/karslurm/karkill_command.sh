#!/bin/bash

# Author: Satyo Wasistho
# Date: 04-24-2023
# This is the command used to kill any parallel jobs run through karslurm.
# This can be run by any user.

# Yes, we do have the password to the shared mpi user as plaintext.
# Yes, it is a security concern, but don't worry about it. I compiled
# all the command scripts into binaries so that the source code can't
# be seen. Now, if the command scripts ever get decompiled, that's a 
# problem, but I'm just gonna pray that no one thinks to decompile them.
password=<mpi user password>

if [[ $# == 1 ]]; then
	# check if the job ID is of an active job
	if [[ -z "$(karqueue | grep $1)" ]]; then
		echo "ID $1 is not associated with any active Karslurm job."
		exit 1
	fi

	# The jobs are ID'd by the PID of their karun call, but they get killed
	# by killing their mpirun call process. This code finds the corresponding
	# mpirun call PID to the given job ID.
	proc=$1
	proctokill=0
	procdist=1000000
	for mpiproc in $(pidof mpirun); do
		echo $mpiproc
		curprocdist=$((mpiproc-proc))
		
		if [ $curprocdist -lt $procdist ]; then
			echo "fuck karson"
			prodist=$((mpiproc-proc))
			proctokill=$mpiproc
			echo $mpiproc
		fi
	done
	echo $proctokill

	# Standard users don't have the privileges to kill processes.
	sshpass -p $password ssh jcccluster@localhost "kill -2 $proctokill;exit"

# Parameter checking/Usage guide
else
	echo "Usage:"
	echo "	karkill <job ID>"
	exit 1
fi
