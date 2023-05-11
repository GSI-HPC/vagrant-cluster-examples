# MPI VM Cluster with SLURM 21.08

VM Cluster for openMPI Slurm feature test. 
Only works with the VirtualBox provider.

# Getting started

To start the VM cluster:

```
 vagrant up
```
Using the default Vagranfile file from this repository the cluster
is make of 3 VMs

- Controller

- Server[1-2]

To add more servers just edit the Vagrantfile and add in the header additional
server by simple cut and paste i.e for adding a third server:

```
#Define the list of machines
slurm_cluster = {
    ...   

    :server3 => {
        :hostname => "server3",
        :ipaddress => "192.168.0.103"
    },
    
}


```



# Notes
Based on https://github.com/jandom/gromacs-slurm-openmpi-vagrant.
