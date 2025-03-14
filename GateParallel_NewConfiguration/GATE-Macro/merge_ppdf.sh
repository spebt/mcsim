#!/bin/bash
#SBATCH --job-name=merge_ppdf
#SBATCH --output=merge_ppdf.out
#SBATCH --error=merge_ppdf.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128000
#SBATCH --time=01:00:00
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load matplotlib/3.5.2

# Run the PPDF merging script
python merge_ppdf.py
