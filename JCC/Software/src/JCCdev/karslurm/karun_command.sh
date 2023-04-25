#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-24-2023
# This is the command wrapper for the karun script.

# ID the job being run by its karun call PID
exename=$1$$
jobname=$1

# Yes, we do have the password to the shared mpi user as plaintext.
# Yes, it is a security concern, but don't worry about it. I compiled
# all the command scripts into binaries so that the source code can't
# be seen. Now, if the command scripts ever get decompiled, that's a 
# problem, but I'm just gonna pray that no one thinks to decompile them.
password=<mpi user password>

# send the executable to the shared mpi user
sshpass -p $password scp $1 jcccluster@localhost:$exename
shift 1

# configure the job execution
sshpass -p $password ssh jcccluster@localhost "./JCCdev/karslurm/karun.sh $exename $@; exit"
if true; then
	# update the job log. execute the job. remove any generated files.
	sshpass -p $password ssh jcccluster@localhost "echo \"$$;$jobname;$(date +%s);$(whoami)\" >> JCCdev/karslurm/karqueue;./karexec.sh; rm $exename; rm karexec.sh; mv $exename\_kout.txt koutputs; exit" 
	# put the output file in the user's current directory.
	cp /home/jcccluster/koutputs/$exename\_kout.txt $exename.kout
	# more file cleanup
	sshpass -p $password ssh jcccluster@localhost "sed -i /$$/d JCCdev/karslurm/karqueue; rm /home/jcccluster/koutputs/$exename\_kout.txt; exit"
fi &
exit 0
