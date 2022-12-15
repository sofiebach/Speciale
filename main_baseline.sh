#!/bin/sh
### General options
### -- specify queue --
#BSUB -q hpc
### -- set the job Name --
#BSUB -J tester
### -- set the job Name AND the job array --
#BSUB -J My_array[1-6]
### -- ask for number of cores (default: 1) --
#BSUB -n 4
### -- specify that the cores must be on the same host --
#BSUB -R "span[hosts=1]"
### -- specify that we need 2GB of memory per core/slot --
#BSUB -R "rusage[mem=2GB]"
### -- specify that we want the job to get killed if it exceeds 3 GB per core/slot --
#BSUB -M 3GB
### -- set walltime limit: hh:mm --
#BSUB -W 24:00
### -- set the email address --
##BSUB -u s161996student.dtu.dk
### -- send notification at start --
#BSUB -B
### -- send notification at completion --
#BSUB -N
### -- Specify the output and error file. %J is the job-id --
### -- -o and -e mean append, -oo and -eo mean overwrite --
#BSUB -oo Output.out
#BSUB -eo Error.err

module load gurobi/9.5.2
module load julia/1.7.0

# here follow the commands you want to execute
julia-current main_baseline_test.jl &> results_test_baseline.txt
