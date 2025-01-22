#!/bin/bash
#SBATCH --job-name=merge_csvs
#SBATCH --output=merge_csvs.out
#SBATCH --error=merge_csvs.err
#SBATCH --ntasks=1                  # Run one task per array job
#SBATCH --cpus-per-task=16          # Number of CPU cores per task
#SBATCH --mem=256000                    # Memory per task
#SBATCH --time=05:00:00             # Time limit hrs:min:sec
#SBATCH --partition=general-compute # Specify partition
#SBATCH --qos=general-compute       # Specify QoS

#SBATCH --mail-type=END,FAIL

#SBATCH --mail-user=tridevme@buffalo.edu



#module load python/3.8  # Load the required Python module
module load matplotlib/3.5.2
# Activate your Python virtual environment if needed
# source /path/to/your/venv/bin/activate

# Run the merging and plotting script
python merge_and_plot.py
