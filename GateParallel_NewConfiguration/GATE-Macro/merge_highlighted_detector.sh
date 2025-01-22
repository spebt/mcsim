#!/bin/bash
#SBATCH --job-name=merge_highlighted
#SBATCH --output=merge_highlighted.out
#SBATCH --error=merge_highlighted.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128000
#SBATCH --time=01:00:00
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load matplotlib/3.5.2

# Run the highlighted detector merging script
python merge_highlighted_detector.py
