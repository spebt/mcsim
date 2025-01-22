import pandas as pd
import matplotlib.pyplot as plt
import glob

def merge_csv_files(pattern):
    """
    Efficiently merge CSV files matching a pattern.
    """
    files = glob.glob(pattern)
    if not files:
        return pd.DataFrame()  # Return empty DataFrame if no files found
    return pd.concat((pd.read_csv(f) for f in files), ignore_index=True)

# Paths to the generated CSV files
source_positions_pattern = "/vscratch/grp-rutaoyao/Tridev/source_positions_*.csv"
detector_positions_pattern = "/vscratch/grp-rutaoyao/Tridev/detector_positions_*.csv"
ppdf_pattern = "/vscratch/grp-rutaoyao/Tridev/ppdf_*.csv"
highlighted_detector_pattern = "/vscratch/grp-rutaoyao/Tridev/highlighted_detector_*.csv"

# Merge files
source_positions_combined = merge_csv_files(source_positions_pattern)
detector_positions_combined = merge_csv_files(detector_positions_pattern)
ppdf_combined = merge_csv_files(ppdf_pattern)
highlighted_detector_combined = merge_csv_files(highlighted_detector_pattern)

# Select the first highlighted detector as the primary for plotting (adjust as needed)
highlighted_detector = highlighted_detector_combined.iloc[0] if not highlighted_detector_combined.empty else None

# Plotting
plt.figure(figsize=(10, 8))

# Plot all source positions
plt.scatter(source_positions_combined["sourcePosX"], source_positions_combined["sourcePosY"], 
            c='green', s=10, alpha=0.2, label="Source Positions")

# Plot all detector positions
plt.scatter(detector_positions_combined["posX"], detector_positions_combined["posY"], 
            c='blue', s=2, alpha=1, label="Detector Positions")

# Highlight the selected detector (if available)
if highlighted_detector is not None:
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

