#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-22-2023
# Runs ssh-copy-id on every connected slave node. This
# enables passless ssh on every node. Required for mpirun.
# Run this script every time the JCC restarts.
while read -r node; do
	ssh-copy-id $node
done < nodelist
