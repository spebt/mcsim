#!/bin/bash

#SBATCH --job-name=gate_sim
#SBATCH --output=gate_parallel_%j.out
#SBATCH --error=gate_parallel_%j.err
#SBATCH --nodes=4                 # Adjust based on available resources
#SBATCH --ntasks=128              # Total number of tasks (parallel jobs)
#SBATCH --cpus-per-task=1         # Number of CPUs per task
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=10:00:00           # Adjust based on expected runtime
#SBATCH --mem=32000               # Memory per node (adjust as needed)
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

# Load necessary modules
echo "Loading necessary modules..."
module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
module load openmpi/4.1.1 gate/9.4

# Set environment variables for GATE and GEANT4
export GEANT4_DATA_DIR=${EBROOTGEANT4DATA}

# Set the number of parallel jobs and working directory
N_JOBS=128  # Total number of jobs to run in parallel
WORK_DIR="/user/tridevme/parallel/SPEBT/GATE-Macro"
OUTPUT_DIR="$WORK_DIR/output"
TEMP_DIR="$WORK_DIR/temp_${SLURM_JOB_ID}"

# Create temporary and output directories if they don't exist
mkdir -p $TEMP_DIR
mkdir -p $OUTPUT_DIR

echo "TEMP_DIR is set to: $TEMP_DIR"
echo "OUTPUT_DIR is set to: $OUTPUT_DIR"

# Run GATE simulations in parallel
echo "Starting GATE simulations..."
for i in $(seq 1 $N_JOBS); do
    echo "Creating macro file for job $i..."
    # Replace placeholders in the macro file dynamically for each job
    sed "s|{id}|$i|g; s|\$TEMP_DIR|$TEMP_DIR|g" $WORK_DIR/SPEBT.mac > $TEMP_DIR/SPEBT_$i.mac
    
    if [ -f "$TEMP_DIR/SPEBT_$i.mac" ]; then
        echo "Macro file SPEBT_$i.mac created successfully."
    else
        echo "Error: Macro file SPEBT_$i.mac not created."
        continue
    fi
    
    # Run GATE with the generated macro file in the background
    srun --ntasks=1 --exclusive Gate $TEMP_DIR/SPEBT_$i.mac > $TEMP_DIR/gate_${i}.log 2>&1 &
done

# Wait for all jobs to complete
wait

echo "All GATE simulations have completed."

# Merge output ROOT files in batches to handle large data efficiently
echo "Merging output files..."
for i in $(seq 0 20 120); do
    echo "Merging files from index $i to $(($i + 19))..."
    hadd -n 20 $OUTPUT_DIR/merged_${i}.root $OUTPUT_DIR/SPEBT_{$i..$(($i + 19))}.root || { echo "Error merging files from index $i"; continue; }
done

# Merge all intermediate merged files into a final output file
echo "Merging all intermediate merged files into final_merged.root..."
hadd -f $OUTPUT_DIR/final_merged.root $OUTPUT_DIR/merged_*.root || { echo "Error merging final ROOT files"; exit 1; }

echo "Final merging completed successfully."

# Optional: Clean up temporary files if desired.
echo "Cleaning up temporary files..."
rm -rf $TEMP_DIR

echo "GATE parallel simulation and data processing completed."
