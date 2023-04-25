#!/bin/bash
# Author: Satyo Wasistho
# Date: 04-22-2023
# This just generates a /etc/hosts file that recognizes every possible node
# on the JCC. I used this once during development. Post-release, you
# will most likely never have to run this.

# clears the existing file. This prevents the file from getting flooded
# in the event that this script gets ran several times
>| /etc/hosts

# rewrites the default hosts
echo "127.0.0.1	localhost" >> /etc/hosts
echo "127.0.1.1	ubuntuJCC" >> /etc/hosts
echo "
# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
echo "::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" >> /etc/hosts

# gives a hostname to every possible slave node IP (as DHCP 
# assigns IPs dynamically)
echo "#MPI CLUSTER NODES" >> /etc/hosts
echo "172.21.1.110 master" >> /etc/hosts #master node IP is static
count=1
for i in {100..200}; do
	if [ $i != 110 ]; then
		echo "172.21.1.$i slave$count" >> /etc/hosts
		((count=count+1))
	fi
done
