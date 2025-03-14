#!/bin/bash
#SBATCH --job-name=sysmat_plot          # Job name
#SBATCH --output=logs/sysmat_plot_%A_%a.out # Standard output log
#SBATCH --error=logs/sysmat_plot_%A_%a.err  # Standard error log
#SBATCH --array=0-143                  # Array of tasks (128 jobs, one per detector ID)
#SBATCH --ntasks=1                     # One task per job
#SBATCH --cpus-per-task=4              # Number of CPU cores per task
#SBATCH --mem=250000                   # Memory allocation (256GB to handle large data)
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

mkdir -p "System Matrix Plots Consist"

detector_id=${SLURM_ARRAY_TASK_ID}

python - <<EOF
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# File paths (updated for Parquet files)
file_path = "/vscratch/grp-rutaoyao/Tridev/combined_system_matrix.parquet"
detector_positions_path = "/user/tridevme/Tridev_SPEBT/GateParallel_NewConfiguration/GATE-Macro/merged_detector_positions.parquet"
highlighted_detector_path = "/user/tridevme/Tridev_SPEBT/GateParallel_NewConfiguration/GATE-Macro/merged_highlighted_detector.parquet"

# Detector ID
detector_id = ${detector_id}

# Load data into memory (single read)
print("Loading data into memory...")
data = pd.read_parquet(file_path, columns=["detector_id", "sourcePosX", "sourcePosY"])
detector_positions = pd.read_parquet(detector_positions_path)
highlighted_detector = pd.read_parquet(highlighted_detector_path)

# Filter data for the specified detector ID
print(f"Filtering data for detector ID {detector_id}...")
filtered_data = data[data["detector_id"] == detector_id]

# Plotting if data is found
if not filtered_data.empty:
    plt.figure(figsize=(10, 8))
    
    # Define plot boundaries for heatmap
    heatmap_x_min, heatmap_x_max = -90, 90
    heatmap_y_min, heatmap_y_max = -90, 90
    radius = 90  # Define the radius of the circular mask

    # Bin source data for heatmap
    print("Binning data for heatmap...")
    x_bins = 200  # Adjust for desired resolution
    y_bins = 200  # Adjust for desired resolution
    heatmap, xedges, yedges = np.histogram2d(
        filtered_data["sourcePosX"], filtered_data["sourcePosY"], bins=(x_bins, y_bins)
    )
    
    # Normalize the heatmap to create a PPDF
    heatmap = heatmap / heatmap.sum()  # PPDF normalization

    # Create a circular mask for the heatmap (mask values outside the radius)
    x_center, y_center = 0, 0  # Assuming the circle is centered at (0, 0)
    x, y = np.meshgrid(xedges[:-1] + np.diff(xedges)/2, yedges[:-1] + np.diff(yedges)/2)  # Get the coordinates of the bins
    distance_from_center = np.sqrt((x - x_center)**2 + (y - y_center)**2)

    # Mask the heatmap values outside the circular region (set to np.nan)
    heatmap_masked = np.where(distance_from_center <= radius, heatmap, np.nan)

    # Plot the heatmap with the circular mask applied
    plt.imshow(heatmap_masked.T, extent=[heatmap_x_min, heatmap_x_max, heatmap_y_min, heatmap_y_max], origin='lower', cmap='viridis', aspect='auto')

    # Plot all detector positions in blue (with different axis limits)
    scatter_x_min, scatter_x_max = -175, 175  # Set different limits for scatter plot
    scatter_y_min, scatter_y_max = -160, 160
    plt.scatter(detector_positions["posX"], detector_positions["posY"], 
                c='blue', s=1, alpha=1, label="Detector Positions")

    # Highlight the selected detector in red with a black edge
    selected_detector = highlighted_detector[highlighted_detector["selected_volumeID_6"] == detector_id]
    if not selected_detector.empty:
        plt.scatter(selected_detector["posX"], selected_detector["posY"], 
                    c='red', s=10, label="Selected Detector", edgecolors='black')

    # Set axis limits for scatter plot (different from the heatmap)
    plt.xlim(scatter_x_min, scatter_x_max)
    plt.ylim(scatter_y_min, scatter_y_max)

    # Add color bar, labels, title, and legend
    plt.colorbar(label="Normalized Probability (PPDF)")
    plt.xlabel("Source X Position")
    plt.ylabel("Source Y Position")
    plt.title(f"PPDF Heatmap for Detector ID {detector_id}")
    plt.legend()

    # Save the plot
    plot_dir = "System Matrix Plots Consist"
    os.makedirs(plot_dir, exist_ok=True)
    plot_path = os.path.join(plot_dir, f"PPDF_Detector_{detector_id}.png")
    plt.savefig(plot_path)
    print(f"Heatmap plot saved to {plot_path}")
else:
    print(f"No data found for detector ID {detector_id}")
EOF
