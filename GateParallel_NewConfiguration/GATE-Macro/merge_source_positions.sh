#!/bin/bash
#SBATCH --job-name=merge_source
#SBATCH --output=merge_source.out
#SBATCH --error=merge_source.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=512000
#SBATCH --time=01:00:00
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load matplotlib/3.5.2

# Run the source positions merging script
python merge_source_positions.py
