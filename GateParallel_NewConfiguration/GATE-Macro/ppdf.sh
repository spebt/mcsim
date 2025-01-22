#!/bin/bash
#SBATCH --job-name=ppdf_job       # Job name
#SBATCH --output="/vscratch/grp-rutaoyao/Tridev/"+ppdf_output_%A.log  # Output log file
#SBATCH --ntasks=1                # Number of tasks (processes)
#SBATCH --cpus-per-task=1         # Number of CPUs per task
#SBATCH --mem=4000                   # Memory per task
#SBATCH --time=01:00:00              # Time limit hrs:min:sec
#SBATCH --partition=general-compute  # Specify partition
#SBATCH --qos=general-compute

# Set LD_LIBRARY_PATH to use the new GCC libraries first
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

# Load required modules (if needed)
# module load python/3.8

# Activate your virtual environment if needed
# source /path/to/your/venv/bin/activate

# Set paths to your ROOT files
hits_file="hits${SLURM_ARRAY_TASK_ID}.root"
singles_file="singles${SLURM_ARRAY_TASK_ID}.root"

# Run your Python script that generates the PPDF
python generate_ppdf_with_detectors.py $hits_file $singles_file
