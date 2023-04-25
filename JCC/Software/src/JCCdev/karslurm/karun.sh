#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-24-2023
# This is the UI for running jobs on the JCC.

head_ip=110
ip_list=()

clear

# Title
echo "**************************************"
echo "*                                    *"
echo "*          K A R S L U R M           *"
echo "*  The intuitive UI for configuring  *"
echo "*    parallel execution on the JCC   *"
echo "*                                    *"
echo "*     Created by Satyo Wasistho      *"
echo "*                                    *"
echo "**************************************"
echo " "
echo "Selected Program: $@"

# Send the executable to the specified directory (mpirun only works
# from this directory)
dir=$(pwd)
if [[ $dir != /home/jcccluster/executables ]]; then
	cp $1 /home/jcccluster/executables
fi

# User input for the number of processes
echo -n "How many processes would you like to use (default 1)? "
read numprocs
numprocs=${numprocs:-1}

echo ""

# Find all connected nodes.
host_list=("master")
while read -r host; do
	host_list+=($host)
done < /home/jcccluster/JCCdev/node_setup/nodelist

echo "${#host_list[@]} node(s) available."
for host in ${host_list[@]}; do
	echo $host
done

# If the number of processes is fewer than the number of
# connected nodes, only send the executable to at most as
# many nodes as there are processes
hostcount=$numprocs
if [ ${#host_list[@]} -le $hostcount ]; then
	hostcount=${#host_list[@]}
fi

echo ""

# user input for the number of nodes the user wants to run their
# program on.
echo -n "How many nodes would you like to use (default $hostcount)? "
read nodecount
nodecount=${nodecount:-$hostcount}

#input parameter checking.
while ! [[ $nodecount =~ ^[0-9]+$ ]] || [ $nodecount -lt 1 ] || [ $nodecount -gt $hostcount ]; do
	echo "ERROR: invalid input"
	if ! [[ $nodecount =~ ^[0-9]+$ ]]; then
		echo "	Expected integer; Received non-numeric text"
	else
		echo "	Number of nodes used must be within range 1-$hostcount."
	fi
	echo -n "How many nodes would you like to use (default $hostcount)? "
	read nodecount

	nodecount=${nodecount:-$hostcount}
done

# user input to either autoselect or manual select the nodes.
# TODO: error check if the same node is referenced twice.
if [[ $nodecount != ${#host_list[@]} ]]; then
	echo -n "Do you want Karslurm to select which nodes to use automatically (y/n) (default y)?"
	read autoselect
	autoselect=${autoselect:-y}
	if [[ $autoselect == n ]]; then
		possible_host_list=${host_list[@]}
		host_list=()
		for (( i=1; i<=$nodecount; i++ )); do
			flag=0
			host=""
			while
				echo -n "enter host ID of host #$i: "
				read host
				flag=0
				for possible_host in ${possible_host_list[@]}; do
					if [[ $host == $possible_host ]]; then
						flag=1
					fi
				done
				# 
				if [[ $flag == 0 ]]; then
					echo "ERROR: invalid input"
					echo "	$host is not a valid host ID for any machine on the network"
				fi
				[[ $flag == 0 ]]
			do true; done
			host_list+=($host)
		done
	fi

fi
# user input for process mapping options. Defaults to by-socket.
map_option=socket
if [[ $numprocs > 1 ]]; then
	echo "Process mapping options: "
	echo "  1. by-socket"
	echo "  2. by-hwthread"
	echo "  3. by-core"
	echo "  4. by-L1cache"
	echo "  5. by-L2cache"
	echo "  6. by-L3cache"
	echo "  7. by-numa"
	echo "  8. by-board"
	echo "  9. by-node"
	echo -n "How would you like to map your $numprocs processes (1-9) (default 1)?"
	read map_in
		# Error checking
		while ! [[ $nodecount =~ ^[0-9]+$ ]] || [ $nodecount -lt 1 ] || [ $nodecount -gt $hostcount ]; do
        	echo "ERROR: invalid input"
        	if ! [[ $nodecount =~ ^[0-9]+$ ]]; then
        	        echo "  Expected integer; Received non-numeric text"
        	else
        	        echo "  Mapping option used must be within range 1-9."
        	fi
        	echo "Process mapping options: "
        	echo "	1. by-socket"
        	echo "  2. by-hwthread"
        	echo "  3. by-core"
        	echo "  4. by-L1cache"
        	echo "  5. by-L2cache"
        	echo "  6. by-L3cache"
        	echo "  7. by-numa"
        	echo "  8. by-board"
        	echo "  9. by-node"
        	echo -n "How would you like to map your $numprocs processes (1-9) (default 1)?"
		read map_in

        	map_in=${map_in:-1}
	done

	map_options=(socket hwthread core L1cache L2cache L3cache numa board node)
	map_option=${map_options[$((map_in-1))]}

fi

# send executable to slave nodes
>| hostfile.txt
echo "sending executable $1 to external nodes."
for host in ${host_list[@]::$nodecount}; do
	echo "$host slots=4" >> hostfile.txt
	scp $1 $host:executables/
	echo "	executable $1 sent to $host"
done

echo "executing '$@' with $numprocs process(es) on $nodecount node(s)..."

# generate execution and file cleanup script. We make a seperate script so 
# that we can run the execution in the background. This is all handled by the
# command wrapper.
echo "#!/bin/bash
$(which mpirun) -hostfile hostfile.txt -map-by $map_option -np $numprocs -mca btl_tcp_if_include eth0 -display-map /home/jcccluster/executables/$@ > $1_kout.txt

chmod 666 $1_kout.txt

rm hostfile.txt
#rm /home/jcccluster/executables/$1

for host in ${host_list[@]::$nodecount}; do
	#echo \"removing executable on \$host\" 
	ssh \$host \"rm /home/jcccluster/executables/$1;exit\"
done" >| karexec.sh

chmod +x karexec.sh 

exit 0
