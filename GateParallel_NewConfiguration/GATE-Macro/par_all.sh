#!/bin/bash

# Submit the first job
vscratch_job=$(sbatch --parsable par_vscratch.sh)

# Submit hadd job dependent on vscratch_job completion
hadd_job=$(sbatch --parsable --dependency=afterok:$vscratch_job par_hadd.sh)

# Submit ppdf job dependent on hadd_job completion
ppdf_job=$(sbatch --parsable --dependency=afterok:$hadd_job par_ppdf.sh)

# Set LD_LIBRARY_PATH to use the new GCC libraries first
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

# Submit all merging jobs in parallel
source_job=$(sbatch --parsable --dependency=afterok:$ppdf_job merge_source_positions.sh)
detector_job=$(sbatch --parsable --dependency=afterok:$ppdf_job merge_detector_positions.sh)
ppdf_job=$(sbatch --parsable --dependency=afterok:$ppdf_job merge_ppdf.sh)
highlighted_job=$(sbatch --parsable --dependency=afterok:$ppdf_job merge_highlighted_detector.sh)

# Wait for ppdf_job to complete before running the merge plot bash script
mergeplot_status=$(sbatch --parsable --dependency=afterok:$source_job:$detector_job:$ppdf_job:$highlighted_job plot_positions.sh)

# Submit the final set of jobs sequentially with dependencies
sysmat_job=$(sbatch --parsable --dependency=afterok:$mergeplot_status par_sysmat.sh)
mergesysmat_job=$(sbatch --parsable --dependency=afterok:$sysmat_job par_mergesysmat.sh)
sysmatplot_job=$(sbatch --parsable --dependency=afterok:$mergesysmat_job par_sysmatplot.sh)

echo "All jobs submitted successfully with dependencies."
