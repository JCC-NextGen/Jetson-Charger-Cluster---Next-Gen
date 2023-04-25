# Adding a Slave Node to the JCC
One of the greatest appeals of any cluster computer is its modularity. The ability to upscale the capabilities of a system over the course of its lifetime with relative ease is an invaluable resource and one that the JCC development team has placed at the core of our design philosophy. 

As such, we have taken measures to greatly simplify the process of integrating additional nodes to the JCC's network. This guide will explain all the necessary steps to add a slave node to the JCC and set up its software environment for executing parallel code alongside the other nodes on the network. This is assuming you have already flashed the node with Ubuntu and physically connected it to the JCC node network (as described in the hardware manual).
## Software Setup
For this process, if you are adding multiple nodes in one sitting, it is best to fully complete these steps for one node before moving on to the next.
### Step 1: MPI Setup
The following steps will guide you through installing and configuring MPI on the new node to match the existing MPI setup on the JCC. 

Install the binaries for OpenMPI (version 2.1.1) using the following command in your terminal.
``
sudo apt-get install openmpi-bin
``

In order to pass executables from the master node to every slave node, we need every node to have a Linux user with the same name. The JCC currently uses *jcccluster* as its shared user for MPI. Note that this step requires physical access to the new node.
**To add a new user:**
``
sudo adduser jcccluster
``
**Making mpiuser a sudoer :**
``
sudo usermod -aG sudo jcccluster
``
### Step 2: SSH Setup
We now have MPI installed and usable on the new node. However, the node is still unable to communicate with the rest of the JCC through MPI. On distributed memory systems like the JCC, MPI transfers data between nodes through **SSH**.

First, we must install SSH onto the new node.

**To install SSH in the system:**
``
sudo apt­-get install openssh-server
``
Beyond this point, we can access the new node via SSH rather than plugging into it physically. From this point forward, the SSH setup needs to be done through the MPI user we just created. If you are on the MPI user on the master node, you can SSH into the same user on all the slave nodes without specifying a username.

Log in to the MPI user by
``
su - jcccluster
``

Next, we must determine the node ID of the new slave that has been connected to the network, as the DHCP server allocates IP addresses to slave nodes dynamically on startup. Fortunately, JCC developer Satyo Wasistho has developed a software package specifically for node setup on the JCC to help automate this process.

The node setup package located in **/home/jcccluster/JCCdev/node_setup/** on the master node.

First, **cd** into the node setup directory and run the **connect_to_hosts.sh** script on the master node. This script gives the master node a record of all the slave nodes currently connected to the network and specifies the node ID of any newly detected nodes that have not been previously recorded to exist on the network. 
``
bash connect_to_hosts.sh
``
**connect_to_hosts.sh output**
```
How many worker nodes are on the network (default 100)? 4
node found: slave5
node found: slave6
node found: slave7
node found: slave8 (new)
```
The hostname that is tagged as 'new' in the script output is the node ID of the new node. Use this node ID to copy the node setup package into the new node. You can do this using **scp** like so:
``
scp -r /home/jcccluster/JCCdev/node_setup <slave node id>:<desired directory>
``

The node setup tools can be used in any directory, so long as the scripts have been copied to those directories. Perform these next steps on the new slave node.

Run the **gen_hosts.sh** script. This gives the node a record of every possible node ID it can ever have (as the DHCP server dynamically allocates IP addresses to each slave node upon a system startup).
``
sudo bash gen_hosts.sh
``

For MPI to function across all nodes, the SSH connection must be password-less. We can use RSA encryption to set up a password-less SSH connection between the master node and the new slave node. Do this on both nodes.

In the home directory:
```
ssh-keygen -t rsa
cd .ssh/
cat id_rsa.pub >> authorized_keys
```
If you are on the master node, ssh copy the slave node's ID.
``
ssh-copy-id <slave node id>
``
If you are on a slave node, ssh copy the master node's ID.
``
ssh-copy-id master
``

With that, your new slave node should be properly integrated into the JCC's network.
