#!/bin/bash
#SBATCH --job-name=hadd_parallel     # Job name
#SBATCH --output=logs/job_%A_%a.out # Standard output and error log
#SBATCH --error=logs/job_%A_%a.err
#SBATCH --array=1-100                # Array of tasks (1 to 100)
#SBATCH --ntasks=1                   # Run one task per array job
#SBATCH --cpus-per-task=4            # Number of CPU cores per task
#SBATCH --mem=16000                 # Memory per task
#SBATCH --time=1:00:00              # Time limit hrs:min:sec
#SBATCH --partition=general-compute  # Specify partition
#SBATCH --qos=general-compute        # Specify QoS

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

# Load required modules
module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2

# Navigate to the working directory
cd /vscratch/grp-rutaoyao/Tridev

# Perform operations for the current array index
i=${SLURM_ARRAY_TASK_ID}

# Run hadd for hits and singles
hadd hits${i}.root SPEBT_${i}.hits_*.root
hadd singles${i}.root SPEBT_${i}.Singles_*.root
