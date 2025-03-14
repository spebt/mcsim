#!/bin/bash
#SBATCH --job-name=gate_parallel     # Job name
#SBATCH --output=logs/job_%A_%a.out # Standard output and error log
#SBATCH --error=logs/job_%A_%a.err
#SBATCH --array=0-9                 # Array of tasks (modify as needed)
#SBATCH --ntasks=1                  # Run one task per array job
#SBATCH --cpus-per-task=4          # Number of CPU cores per task
#SBATCH --mem=40000                    # Memory per task
#SBATCH --time=01:00:00             # Time limit hrs:min:sec
#SBATCH --partition=general-compute # Specify partition
#SBATCH --qos=general-compute       # Specify QoS

# Load required modules
module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2

# Define the working directory and task-specific parameters
WORKDIR="/user/tridevme/parallel/SPEBT/GATE-Macro"
cd $WORKDIR

# Task-specific output suffix
OUTPUT_SUFFIX="run_${SLURM_ARRAY_TASK_ID}"

# Preprocess output.mac to replace ${SLURM_ARRAY_TASK_ID} with the actual task ID
cp output.mac output_${OUTPUT_SUFFIX}.mac
sed -i "s|\${SLURM_ARRAY_TASK_ID}|${SLURM_ARRAY_TASK_ID}|g" output_${OUTPUT_SUFFIX}.mac

# Modify the main macro file to reference the task-specific output.mac
cp SPEBT.mac SPEBT_${OUTPUT_SUFFIX}.mac
sed -i "s|/control/execute output.mac|/control/execute output_${OUTPUT_SUFFIX}.mac|g" SPEBT_${OUTPUT_SUFFIX}.mac

# Run the simulation with the modified macro file
Gate SPEBT_${OUTPUT_SUFFIX}.mac

# Add the batch file merging step below if needed
# First, check if the 'hits' and 'Singles' files exist
HITS_FILES=($(ls *hits*.root))
SINGLES_FILES=($(ls *Singles*.root))

# Function to merge files in batches and delete intermediate files
merge_in_batches() {
  local file_list=("$@")
  local output_file=$1
  local batch_size=10  # Adjust batch size as needed
  
  while [ ${#file_list[@]} -gt 0 ]; do
    # Get the next batch of files
    batch=("${file_list[@]:0:$batch_size}")
    file_list=("${file_list[@]:$batch_size}")
    
    # Run the hadd command
    hadd -f $output_file "${batch[@]}"
    
    # Delete the intermediate files in the batch after merging
    for file in "${batch[@]}"; do
      rm -f "$file"
      echo "Deleted: $file"
    done
  done
}

# Merging hits files if any exist
if [ ${#HITS_FILES[@]} -gt 0 ]; then
  merge_in_batches "${HITS_FILES[@]}" hits.root
fi

# Merging singles files if any exist
if [ ${#SINGLES_FILES[@]} -gt 0 ]; then
  merge_in_batches "${SINGLES_FILES[@]}" singles.root
fi
