#!/bin/bash
#SBATCH --job-name=gate_parallel     # Job name
#SBATCH --output=logs/job_%A_%a.out # Standard output and error log
#SBATCH --error=logs/job_%A_%a.err
#SBATCH --array=0-100%20             # Array of tasks (modify as needed; %20 throttles concurrent submissions)
#SBATCH --ntasks=1                   # Run one task per array job
#SBATCH --cpus-per-task=4            # Number of CPU cores per task
#SBATCH --mem=25000                   # Memory per task
#SBATCH --time=10:00:00              # Time limit hrs:min:sec
#SBATCH --partition=general-compute  # Specify partition
#SBATCH --qos=general-compute        # Specify QoS

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOURNAME@buffalo.edu

# Load required modules
module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2

# Define the working directory
WORKDIR="/user/YOURNAME/mcsim/GateParallel_MOBY/GATE-Macro"
cd $WORKDIR

# RUN_TAG selects which campaign this is -- set via sbatch --export=ALL,RUN_TAG=box|fov
# (see par_full_pipeline.sh). Determines both which source macro is used and
# which /vscratch subdirectory this campaign's output goes into, so the box
# and FOV campaigns never collide with each other's files.
if [ -z "$RUN_TAG" ]; then
  echo "ERROR: RUN_TAG not set (expected 'box' or 'fov'). Submit via par_full_pipeline.sh, or e.g.:"
  echo "  sbatch --export=ALL,RUN_TAG=box par_vscratch.sh"
  exit 1
fi


case "$RUN_TAG" in
  box)      SOURCE_MACRO="source_box.mac" ;;
  fov)      SOURCE_MACRO="source_fov.mac" ;;
  derenzo)  SOURCE_MACRO="source_derenzo.mac" ;;
  contrast) SOURCE_MACRO="source_contrast.mac" ;;
  *) echo "ERROR: unknown RUN_TAG '$RUN_TAG'"; exit 1 ;;
esac

OUTPUTDIR="/vscratch/grp-rutaoyao/YOURNAME/${RUN_TAG}"
mkdir -p "$OUTPUTDIR"

# Task-specific output suffix
OUTPUT_SUFFIX="run_${SLURM_ARRAY_TASK_ID}"

# Preprocess output.mac to replace ${SLURM_ARRAY_TASK_ID} and the output directory
cp output.mac "${OUTPUTDIR}/output_${OUTPUT_SUFFIX}.mac"
sed -i "s|\${SLURM_ARRAY_TASK_ID}|${SLURM_ARRAY_TASK_ID}|g" "${OUTPUTDIR}/output_${OUTPUT_SUFFIX}.mac"
sed -i "s|OUTPUT_DIR_PLACEHOLDER|${OUTPUTDIR}|g" "${OUTPUTDIR}/output_${OUTPUT_SUFFIX}.mac"

# Modify the main macro file to reference the task-specific output.mac and the
# correct source macro for this campaign
cp SPEBT.mac "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"
sed -i "s|/control/execute output.mac|/control/execute ${OUTPUTDIR}/output_${OUTPUT_SUFFIX}.mac|g" "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"
sed -i "s|SOURCE_MACRO_PLACEHOLDER|${SOURCE_MACRO}|g" "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"

# Give this array task its own random seed (SPEBT.mac previously had no
# /gate/random/setEngineSeed at all, so every task reused Geant4's default seed)
SEED=$(( $(date +%s) + SLURM_ARRAY_TASK_ID ))
sed -i "s|SEED_PLACEHOLDER|${SEED}|g" "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"

# Run the simulation with the modified macro file
Gate "${OUTPUTDIR}/SPEBT_${OUTPUT_SUFFIX}.mac"