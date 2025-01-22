import pandas as pd
import matplotlib.pyplot as plt

# Load merged Parquet files
source_positions_combined = pd.read_parquet("/vscratch/grp-rutaoyao/Tridev/"+"merged_source_positions.parquet")
detector_positions_combined = pd.read_parquet("/vscratch/grp-rutaoyao/Tridev/"+"merged_detector_positions.parquet")
ppdf_combined = pd.read_parquet("merged_ppdf.parquet")
highlighted_detector_combined = pd.read_parquet("merged_highlighted_detector.parquet")

selected_volumeID_6 = 0

# Select the first highlighted detector as the primary for plotting (adjust as needed)
highlighted_detector = highlighted_detector_combined[
    highlighted_detector_combined["selected_volumeID_6"] == selected_volumeID_6
]

# Plotting
plt.figure(figsize=(10, 8))

# Plot all source positions
plt.scatter(source_positions_combined["sourcePosX"], source_positions_combined["sourcePosY"], 
            c='green', s=10, alpha=0.2, label="Source Positions")

# Plot all detector positions
plt.scatter(detector_positions_combined["posX"], detector_positions_combined["posY"], 
            c='blue', s=2, alpha=1, label="Detector Positions")

# Highlight the selected detector (if available)
if not highlighted_detector.empty:
    plt.scatter(highlighted_detector["posX"], highlighted_detector["posY"], 
                c='red', s=10, label="Selected Detector", edgecolors='black')

# Plot grouped source positions that reach the selected detector, with count size
plt.scatter(ppdf_combined["sourcePosX"], ppdf_combined["sourcePosY"], 
            c='purple', s=2, alpha=0.7, label="Grouped Sources Reaching Detector")

# Labeling axes
plt.xlabel("X Position")
plt.ylabel("Y Position")
plt.title("Combined Source and Detector Positions with Highlighted Detector")
plt.legend()

# Save and show the plot
combined_plot_path = "combined_source_and_detector_positions.png"
plt.savefig(combined_plot_path)
