#!/bin/bash
#SBATCH -p debug
#SBATCH --nodes 2
#SBATCH --tasks-per-node 1
#SBATCH -t 12:00:00
#SBATCH -J mpi_job
#SBATCH -o mpi_job.out


echo "Simple Submit script for trivial MPI job"
echo "Running hostname with $SLURM_NTASKS MPI tasks"
echo "Nodelist: $SLURM_NODELIST"

mpirun -np $SLURM_NTASKS --mca oob_tcp_if_include eth1 \
    hostname
