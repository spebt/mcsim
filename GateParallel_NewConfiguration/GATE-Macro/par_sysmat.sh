#!/bin/bash
#SBATCH --job-name=sysmat      # Job name
#SBATCH --output="/vscratch/grp-rutaoyao/Tridev/"+sysmat_output_%A_%a.log  # Output log file
#SBATCH --array=1-100             # Job array index (1 to 100)
#SBATCH --ntasks=1                # Number of tasks
#SBATCH --cpus-per-task=4         # CPUs per task
#SBATCH --mem=256000                   # Memory per task
#SBATCH --time=10:00:00              # Time limit hrs:min:sec
#SBATCH --partition=general-compute  # Specify partition
#SBATCH --qos=general-compute        # Specify QoS

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2
module load matplotlib/3.5.2

# Set LD_LIBRARY_PATH to use the new GCC libraries first
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

# Run the SLURM job script with the array task ID as argument
bash sysmat.sh
