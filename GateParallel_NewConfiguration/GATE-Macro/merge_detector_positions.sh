#!/bin/bash
#SBATCH --job-name=merge_detector
#SBATCH --output=merge_detector.out
#SBATCH --error=merge_detector.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=256000
#SBATCH --time=01:00:00
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load matplotlib/3.5.2

# Run the detector positions merging script
python merge_detector_positions.py
