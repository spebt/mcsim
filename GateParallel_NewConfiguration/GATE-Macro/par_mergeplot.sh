#!/bin/bash

# Set LD_LIBRARY_PATH to use the new GCC libraries first
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

# Submit all merging jobs in parallel
source_job=$(sbatch --parsable merge_source_positions.sh)
detector_job=$(sbatch --parsable merge_detector_positions.sh)
ppdf_job=$(sbatch --parsable merge_ppdf.sh)
highlighted_job=$(sbatch --parsable merge_highlighted_detector.sh)

# Wait for all merging jobs to complete before plotting
sbatch --dependency=afterok:$source_job:$detector_job:$ppdf_job:$highlighted_job plot_positions.sh
