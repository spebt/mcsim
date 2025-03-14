#!/bin/bash
#SBATCH --job-name=plot_positions
#SBATCH --output=plot_positions.out
#SBATCH --error=plot_positions.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=256000
#SBATCH --time=01:00:00
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2
module load matplotlib/3.5.2

# Set LD_LIBRARY_PATH to use the new GCC libraries first
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

# Run the plotting script
python plot_positions.py
