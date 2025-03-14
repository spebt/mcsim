#!/bin/bash
#SBATCH --job-name=merge_sysmat        # Job name
#SBATCH --output=logs/merge_sysmat_%j.out # Standard output and error log
#SBATCH --error=logs/merge_sysmat_%j.err
#SBATCH --ntasks=1                     # Run a single task
#SBATCH --cpus-per-task=4              # Number of CPU cores per task
#SBATCH --mem=512000                    # Memory allocation (64GB)
#SBATCH --time=10:00:00                 # Time limit hrs:min:sec
#SBATCH --partition=general-compute    # Specify partition
#SBATCH --qos=general-compute          # Specify QoS

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2
module load matplotlib/3.5.2

# Set LD_LIBRARY_PATH to use the new GCC libraries first
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

# Load required modules
#module load python/3.9.7

# Navigate to the working directory
cd /vscratch/grp-rutaoyao/Tridev

# Run the Python script
python - <<EOF
import pandas as pd
import glob

# Path to the directory containing system matrix files
directory = "/vscratch/grp-rutaoyao/Tridev/"

# Find all system matrix Parquet files
system_matrix_files = glob.glob(directory + "system_matrix_*.parquet")

# Initialize an empty list to hold dataframes
dataframes = []

# Loop through each file and append it to the list
for file in system_matrix_files:
    df = pd.read_parquet(file)
    dataframes.append(df)

# Combine all dataframes into one
combined_system_matrix = pd.concat(dataframes, ignore_index=True)

# Save the combined matrix as a Parquet file
output_file = directory + "combined_system_matrix.parquet"
combined_system_matrix.to_parquet(output_file, index=False)

print(f"Combined system matrix saved to {output_file}")
EOF
