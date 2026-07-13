#!/bin/bash
#SBATCH --job-name=projection_data
#SBATCH --output=logs/projection_data_%j.out
#SBATCH --error=logs/projection_data_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64000
#SBATCH --time=01:00:00
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=YOURNAME@buffalo.edu

module load matplotlib/3.5.2

# Set LD_LIBRARY_PATH to use the new GCC libraries first (without this, pandas
# fails to import: GLIBCXX_3.4.29 not found -- same fix already used in
# par_sysmat.sh / par_mergesysmat.sh / par_sysmatbin.sh / ppdf.sh)
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

if [ -z "$RUN_TAG" ]; then
  echo "ERROR: RUN_TAG not set (expected 'box')"
  exit 1
fi

cd /user/YOURNAME/mcsim/GateParallel_MOBY/GATE-Macro
python generate_projection_data.py