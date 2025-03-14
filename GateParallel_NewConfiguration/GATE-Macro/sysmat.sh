#!/bin/bash
#SBATCH --job-name=ppdf_job       # Job name
#SBATCH --output="/vscratch/grp-rutaoyao/Tridev/sysmat_output_%A.log"  # Output log file
#SBATCH --ntasks=1                # Number of tasks (processes)
#SBATCH --cpus-per-task=4         # Number of CPUs per task
#SBATCH --mem=32000                # Memory per task
#SBATCH --time=10:00:00           # Time limit hrs:min:sec
#SBATCH --partition=general-compute  # Specify partition
#SBATCH --qos=general-compute

# Load required modules (if needed)
# module load python/3.8

# Activate your virtual environment if needed
# source /path/to/your/venv/bin/activate

# Set paths to your ROOT files
hits_file="hits${SLURM_ARRAY_TASK_ID}.root"
singles_file="singles${SLURM_ARRAY_TASK_ID}.root"

# Run your Python script that generates the system matrix
python generate_sysmat.py $hits_file $singles_file
