#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-22-2023
# This script finds every connected node and generates a file that lists 
# each of their hostnames. The generated file gets used in other scripts,
# so don't mess with it outside of this script. Run this every time the
# JCC gets restarted.

# prompt the user for the number of nodes to find. Without this, the
# script polls all 100 possible IPs which takes like 2 minutes.
echo -n "How many worker nodes are on the network (default 100)? "
read nodecount
nodecount=${nodecount:-100}

# get list of previously detected nodes
nodes=()
while read -r node; do
	nodes+=($node)
done < nodelist

# poll every possible IP; stop when <nodecount> number of connected nodes
# are found.
count=0
>| nodelist
for i in {1..100}; do
	ping -c 1 -w 1 slave$i > /dev/null 2>&1 && ((count=count+1)) && echo "slave$i" >> nodelist
	if [[ $count == $nodecount ]]; then
		break
	fi
done

# show which connected nodes weren't previously detected
echo ""
while read -r node; do
	new=1
        for n in ${nodes[@]}; do
		if [[ $node == $n ]]; then
			new=0
		fi
	done
	if [[ $new == 1 ]]; then
		echo "node found: $node (new)"
	else
		echo "node found: $node"
	fi
done < nodelist

