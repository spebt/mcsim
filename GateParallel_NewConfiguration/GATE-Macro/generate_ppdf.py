import sys
import uproot
import pandas as pd

# Get input file names from command line arguments
hits_file = sys.argv[1]
singles_file = sys.argv[2]

# Open the ROOT files
hits_data = uproot.open("/vscratch/grp-rutaoyao/Tridev/"+hits_file)["tree;1"].arrays(["posX", "posY", "volumeID[2]", "volumeID[6]", "eventID"], library="pd")
source_data = uproot.open("/vscratch/grp-rutaoyao/Tridev/"+singles_file)["tree;1"].arrays(["sourcePosX", "sourcePosY", "sourcePosZ", "eventID"], library="pd")

# Extract relevant positions
source_positions = source_data[["sourcePosX", "sourcePosY", "eventID"]]
detector_positions = hits_data[["posX", "posY"]]

# Define the selected detector's volume IDs (update these as needed)
selected_volumeID_2 = 3
selected_volumeID_6 = 115

# Extract positions of the selected detector
selected_detector_positions = hits_data[
    (hits_data["volumeID[2]"] == selected_volumeID_2) &
    (hits_data["volumeID[6]"] == selected_volumeID_6)
][["posX", "posY", "eventID"]]

# Find matching source events that hit the selected detector
matched_events = source_positions[source_positions["eventID"].isin(selected_detector_positions["eventID"])]

# Group by source position and count occurrences
source_counts = matched_events.groupby(["sourcePosX", "sourcePosY"]).size().reset_index(name="count")

# Normalize the counts to get a probability density
source_counts["normalized_count"] = source_counts["count"] / source_counts["count"].sum()

# Save the results as a CSV (or any other format you prefer)
output_file = f"ppdf_{hits_file.split('/')[-1].split('.')[0]}.csv"
source_counts.to_csv(output_file, index=False)
