#!/bin/bash
#SBATCH --job-name=sysmat_bin           # Job name
#SBATCH --output=logs/sysmat_bin_%A_%a.out # Standard output log
#SBATCH --error=logs/sysmat_bin_%A_%a.err  # Standard error log
#SBATCH --ntasks=1                     # One task per job
#SBATCH --cpus-per-task=4              # Number of CPU cores per task
#SBATCH --mem=200000                   # Memory allocation (256GB to handle large data)
#SBATCH --time=3:00:00                 # Reduced time limit
#SBATCH --partition=general-compute    # Specify partition
#SBATCH --qos=general-compute          # Specify QoS

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tridevme@buffalo.edu

module load gcc/11.2.0 geant4/11.2.1 geant4-data/11.2
export GEANT4_DATA_DIR=${EBROOTGEANT4MINDATA}
module load gcc/11.2.0 openmpi/4.1.1 gate/9.4 geant4-data/11.2
module load matplotlib/3.5.2

# Set LD_LIBRARY_PATH to use the new GCC libraries first
export LD_LIBRARY_PATH=/cvmfs/soft.ccr.buffalo.edu/versions/2023.01/easybuild/software/Core/gcccore/11.2.0/lib64:$LD_LIBRARY_PATH

cd /vscratch/grp-rutaoyao/Tridev

python - <<EOF
import os
import numpy as np
import pandas as pd

# Load the parquet file
file_path = "/vscratch/grp-rutaoyao/Tridev/system_matrix_hits95.parquet"
data = pd.read_parquet(file_path)

# Drop unnecessary columns
data = data.drop(columns=['normalized_count', 'count'])

# Function to process the data
def process_system_matrix(data, xlimit, ylimit, num_bins, bin_size):
    """
    Process the system matrix based on given FOV limits, number of bins, and bin size.

    Parameters:
        data (pd.DataFrame): Input system matrix.
        xlimit (tuple): (xmin, xmax) for the field of view.
        ylimit (tuple): (ymin, ymax) for the field of view.
        num_bins (int): Number of bins for x and y.
        bin_size (float): Size of each bin.

    Returns:
        np.ndarray: Processed system matrix of shape (1, num_detectors, xbins * ybins).
    """
    # Filter data within the specified FOV
    xmin, xmax = xlimit
    ymin, ymax = ylimit
    data = data[(data['sourcePosX'] >= xmin) & (data['sourcePosX'] < xmax) & 
                (data['sourcePosY'] >= ymin) & (data['sourcePosY'] < ymax)]
    
    # Add bins
    data['xbin'] = ((data['sourcePosX'] - xmin) // bin_size).astype(int)
    data['ybin'] = ((data['sourcePosY'] - ymin) // bin_size).astype(int)
    
    # Group by detector_id and (xbin, ybin), then aggregate counts
    grouped = data.groupby(['detector_id', 'xbin', 'ybin']).size().reset_index(name='count')
    
    # Pivot the data into the required shape
    xbins = int(np.ceil((xmax - xmin) / bin_size))
    ybins = int(np.ceil((ymax - ymin) / bin_size))
    num_detectors = data['detector_id'].nunique()
    
    # Initialize the result matrix
    result_matrix = np.zeros((1, num_detectors, xbins * ybins))
    
    # Fill the matrix with counts
    for _, row in grouped.iterrows():
        detector_index = row['detector_id']  # No subtraction needed
        xbin = row['xbin']
        ybin = row['ybin']
        flat_bin_index = xbin * ybins + ybin
        
        # Add count to the corresponding bin
        if 0 <= detector_index < num_detectors and 0 <= flat_bin_index < (xbins * ybins):
            result_matrix[0, detector_index, flat_bin_index] += row['count']
    
    return result_matrix

# Example usage
xlimit = (-62.5, 62.5)  # User-defined FOV limits for X
ylimit = (-62.5, 62.5)  # User-defined FOV limits for Y
num_bins = 500     # User-defined number of bins
bin_size = (xlimit[1] - xlimit[0]) / num_bins  # Calculate bin size based on limits and number of bins

final_matrix = process_system_matrix(data, xlimit, ylimit, num_bins, bin_size)

# Output the resulting matrix shape and bin size
print("Processed System Matrix Shape:", final_matrix.shape, bin_size)

# Calculate the sum of all counts in the final matrix
matrix_sum = np.sum(final_matrix)

# Output the resulting matrix's sum
print("Sum of Counts in the Processed System Matrix:", matrix_sum)

# Normalize the final matrix
final_matrix_normalized = final_matrix / np.max(final_matrix)

# Output the resulting normalized matrix
output_path = "/vscratch/grp-rutaoyao/Tridev/final_matrix.npy"
np.save(output_path, final_matrix_normalized)
print(f"Final matrix saved to {output_path}")

# Optionally, print some values from the normalized matrix
print(final_matrix_normalized[0][1][0:100])


EOF
