# MPI Installation/Configuration Steps for JCC
In this document, we will go over how to set up MPI on the JCC.

To set up a cluster in the local environment, the same versions of the **OpenMPI** should be pre-installed in every system.
## Prerequisites
-   **Operating System:**  The Operating System is Ubuntu 18.04.
-   **MPI:** We could either use OpenMPI or MPICH. The JCC currently uses OpenMPI (version 2.1.1).
```
sudo apt-get install openmpi-bin	//OpenMPI Binaries (mpirun, mpiexec, etc.)

sudo apt-get install libopenmpi-dev	//OpenMPI Library + Compilers (mpicc, 
					//mpic++, mpifort, etc.)
```
Install the binaries on the master node and every slave node. Install the library and compilers on only the master node.
## Setting Up MPI for the JCC
The following steps will guide you through configuring your MPI installation for use on the JCC. Note that the JCC's hardware setup and proprietary software tools make this process slightly different (and simpler, we hope) from how you would set up most other clusters.
### Step 1: Creating a user for MPI
In order to pass executables from the master node to every slave node, we need every node to have a Linux user with the same name. The JCC currently uses *jcccluster* as its shared user for MPI. Note that this step requires physical access to each node.
**To add a new user:**
``
sudo adduser jcccluster
``
**Making mpiuser a sudoer :**
``
sudo usermod -aG sudo jcccluster
``
### Step 2: Setting up SSH

First, we must install SSH onto the system, as this is how machines are going to be talking over the network. Do this for all nodes, master and slave. Note that this step requires physical access to each node.

To install SSH in the system.
``
sudo apt­-get install openssh-server
``

Beyond this point, we can access each node via SSH rather than plugging into them physically. The SSH setup needs to be done through the MPI user we just created. If you are on the MPI user on the master node, you can SSH into the same user on all the slave nodes without specifying a username.

Log in to the MPI user by
``
su - jcccluster
``

Next, we must determine the node IDs of each slave connected to the network, as the DHCP server allocates IP addresses to slave nodes dynamically on startup. Fortunately, JCC developer Satyo Wasistho has developed a software package specifically for node setup on the JCC to help automate this process.

The node setup package located in **/home/jcccluster/JCCdev/node_setup/** on the head node. You can copy this directory into any slave node using **scp** like so:
``
scp -r /home/jcccluster/JCCdev/node_setup <slave node id>:<desired directory>
``

The node setup tools can be used in any directory. Before proceeding onto the next part of the SSH setup, perform the following on each node.

Run the **gen_hosts.sh** script. This gives the node a record of all nodes that *could* exist on the cluster network.
``
sudo bash gen_hosts.sh
``

Next, run the **connect_to_hosts.sh** script. This tells the node which of the possible hosts are *actually* connected to the cluster network.

``
sudo bash connect_to_hosts.sh
``

For MPI to function across all nodes, the SSH connection must be password-less. We can use RSA encryption to set up a password-less SSH connection between the master node and each slave node. Do this on all nodes.

In the home directory:
```
ssh-keygen -t rsa
cd .ssh/
cat id_rsa.pub >> authorized_keys
```
If you are on the master node, run the **mass-copy-id.sh** script.
``
bash mass-copy-id.sh
``
If you are on a slave node, simply ssh copy the master node's ID.
``
ssh-copy-id master
``

With that, you should now have MPI properly set up for use on the JCC.
## Running MPI Programs on the JCC
As stated previously, the JCC developer Satyo Wasistho has developed a number of software tools in order to simplify the development, maintenance, and use of the JCC. One of these tools is **KarSlurm**, the JCC's proprietary UI wrapper for MPI. **KarSlurm** is designed to be an easy-to-use, intuitive platform for running parallel programs on the JCC, offering users fine control over process allocation across the network of nodes while automating away the more repetitive parts of setting up MPI programs to run across a distributed memory system.

Running an MPI program using **KarSlurm** is quick and easy. Just pass your executable through the *karun* command, and the UI will guide you through configuring your parallel program for execution on the JCC. This works from any directory.

``
karun <mpi_executable>
``
