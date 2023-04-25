# How to Run MPI Programs on the JCC using Karslurm
In this guide, you will learn how to use **Karslurm**, the JCC's proprietary job scheduling software (courtesy of Satyo Wasistho). **Karslurm** provides an accessible and intuitive mechanism for executing and monitoring parallel jobs on the JCC. Currently, **Karslurm** is comprised of three main tools, **karun**, **karqueue**, and **karkill**. This guide will explain each of these tools from the viewpoint of a standard user.
## Karun
Users can execute their parallel jobs on the JCC using the **karun** command. To do so, simply compile your parallel code and pass the executable through **karun** as shown below.
```
<mpi compiler> <source file name> -o <executable name>
karun <executable name>
```

**mpi compiler:** the name of the mpi compiler for the language of your choice. (mpicc, mpic++, mpif77, etc.)
**source file name:** the name of the file containing your source code (the code that you want to compile and run)
**executable name:** the name of the executable file you want to generate

Here is an example using a simple *n*-process "hello world" MPI program.

```
mpicc mpi_hello_world.c -o mpi_hello_world
karun mpi_hello_world
```
If your parallel code makes use of command line arguments, you can pass those into **karun** as well.

``
karun <executable name> <arg1 arg2 ... argX>
``

From here, you will customize your parallel job through the **Karslurm UI** that appears on your terminal. First, it will ask you the number of processes you would like to run. Without an input, the job configuration defaults to one process.

![enter image description here](https://github.com/JCC-NextGen/Jetson-Charger-Cluster---Next-Gen/blob/main/JCC/Software/assets/select_numprocs.png?raw=true)

Next, you will be prompted for how many nodes you would like to run your job on. Without an input, the job configuration defaults to either the number of processes ran or the total number of nodes connected to the network (whichever is lower).

In cases where it is meaningful, the **Karslurm UI** will ask whether you want to select which nodes are used or have them be autoselected by **Karslurm**.

![](https://github.com/JCC-NextGen/Jetson-Charger-Cluster---Next-Gen/blob/main/JCC/Software/assets/select_nodes.png?raw=true)

After this, you will get to select the mapping option for your parallel job. This affects how processes assigned to nodes (which nodes run which processes). 

![](https://github.com/JCC-NextGen/Jetson-Charger-Cluster---Next-Gen/blob/main/JCC/Software/assets/select_mapping.png?raw=true)

This completes the job customization. Now, **Karslurm** will send out the executable to all nodes set to run the job and execute the job on the set nodes and processes.

![](https://github.com/JCC-NextGen/Jetson-Charger-Cluster---Next-Gen/blob/main/JCC/Software/assets/execution.png?raw=true)

Upon completion of your parallel job, **Karslurm** will send the output to your working directory. View the generated output file to see the node-process mapping and the job output.

![](https://github.com/JCC-NextGen/Jetson-Charger-Cluster---Next-Gen/blob/main/JCC/Software/assets/job_output.png?raw=true)
## Karqueue
For longer jobs, you may want to monitor the progress of your job. You can do this using the **karqueue** command. This command shows every active karslurm job running on the JCC, detailing its job ID, executable name, and current execution time.

![](https://github.com/JCC-NextGen/Jetson-Charger-Cluster---Next-Gen/blob/main/JCC/Software/assets/job_queue.png?raw=true)

Additionally, running **karqueue** with the **real-time monitoring** flag (-rt) shows the job queue in real time, allowing you to see the exact moment your job starts and ends without having to rerun the command multiple times.
## Karkill
There may be times when your parallel job takes longer to execute than you expect, and you would like to terminate the job. This can be done using the **karkill** command. 

As shown previously, **Karslurm** jobs are assigned a job ID when they are run. You can view the ID of your job through **karqueue**. To kill a job, simply pass the job ID through the **karkill** command as shown below.

``
karkill <job ID>
``
