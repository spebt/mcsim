#!/bin/bash
#SBATCH --job-name=gate_parallel     # Job name
#SBATCH --output=logs/job_%A_%a.out # Standard output and error log
#SBATCH --error=logs/job_%A_%a.err
#SBATCH --array=0-100                # Array of tasks (modify as needed)
#SBATCH --ntasks=1                   # Run one task per array job
#SBATCH --cpus-per-task=4            # Number of CPU cores per task
#SBATCH --mem=25000                   # Memory per task
#SBATCH --time=10:00:00              # Time limit hrs:min:sec
#SBATCH --partition=general-compute  # Specify partition
#SBATCH --qos=general-compute        # Specify QoS

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

# Load required modules
module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2

# Define the working directory and output directory
WORKDIR="/user/tridevme/Tridev_SPEBT/GateParallel_NewConfiguration/GATE-Macro"
OUTPUTDIR="/vscratch/grp-rutaoyao/Tridev"

cd $WORKDIR

# Task-specific output suffix
OUTPUT_SUFFIX="run_${SLURM_ARRAY_TASK_ID}"

# Preprocess output.mac to replace ${SLURM_ARRAY_TASK_ID} with the actual task ID
cp output.mac "${OUTPUTDIR}/output_${OUTPUT_SUFFIX}.mac"
sed -i "s|\${SLURM_ARRAY_TASK_ID}|${SLURM_ARRAY_TASK_ID}|g" "${OUTPUTDIR}/output_${OUTPUT_SUFFIX}.mac"

# Modify the main macro file to reference the task-specific output.mac
cp SPEBT.mac "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"
sed -i "s|/control/execute output.mac|/control/execute ${OUTPUTDIR}/output_${OUTPUT_SUFFIX}.mac|g" "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"

# Run the simulation with the modified macro file
Gate "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"

