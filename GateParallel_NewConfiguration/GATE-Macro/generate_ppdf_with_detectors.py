import sys
import uproot
import pandas as pd

# Get input file names from command line arguments
hits_file = sys.argv[1]
singles_file = sys.argv[2]

# Open the ROOT files
hits_data = uproot.open("/vscratch/grp-rutaoyao/Tridev/" + hits_file)["tree;1"].arrays(
    ["posX", "posY", "volumeID[2]", "volumeID[6]", "eventID"], library="pd")
source_data = uproot.open("/vscratch/grp-rutaoyao/Tridev/" + singles_file)["tree;1"].arrays(
    ["sourcePosX", "sourcePosY", "sourcePosZ", "eventID"], library="pd")

# Extract relevant positions
source_positions = source_data[["sourcePosX", "sourcePosY", "eventID"]]
detector_positions = hits_data[["posX", "posY"]]

# Define the selected detector's volume IDs (update these as needed)
selected_volumeID_2 = 0

# Initialize a list to store results
highlighted_detectors = []

# Iterate over all volumeID[6] values
for selected_volumeID_6 in range(144):
    # Extract positions of the selected detector
    selected_detector_positions = hits_data[
        (hits_data["volumeID[2]"] == selected_volumeID_2) &
        (hits_data["volumeID[6]"] == selected_volumeID_6)
    ][["posX", "posY", "eventID"]]

    # Check if there are any positions for the current volumeID[6]
    if not selected_detector_positions.empty:
        selected_posX = selected_detector_positions["posX"].iloc[0]
        selected_posY = selected_detector_positions["posY"].iloc[0]
        highlighted = 1  # Highlight this detector
    else:
        selected_posX, selected_posY = None, None
        highlighted = 0  # No detector highlighted

    # Append the result for the current volumeID[6]
    highlighted_detectors.append({
        "posX": selected_posX,
        "posY": selected_posY,
        "highlighted": highlighted,
        "selected_volumeID_6": selected_volumeID_6
    })

selected_volumeID_6 = 0

# Extract positions of the selected detector
selected_detector_positions = hits_data[
    (hits_data["volumeID[2]"] == selected_volumeID_2) &
    (hits_data["volumeID[6]"] == selected_volumeID_6)
][["posX", "posY", "eventID"]]

# Check if there are any positions for the current volumeID[6]
if not selected_detector_positions.empty:
    selected_posX = selected_detector_positions["posX"].iloc[0]
    selected_posY = selected_detector_positions["posY"].iloc[0]
    highlighted = 1  # Highlight this detector
else:
    selected_posX, selected_posY = None, None
    highlighted = 0  # No detector highlighted

# Convert the results into a DataFrame
highlighted_detector_df = pd.DataFrame(highlighted_detectors)

# Find matching source events that hit the selected detector
matched_events = source_positions[source_positions["eventID"].isin(selected_detector_positions["eventID"])]

# Group by source position and count occurrences
source_counts = matched_events.groupby(["sourcePosX", "sourcePosY"]).size().reset_index(name="count")

# Add raw counts and normalized counts
source_counts["normalized_count"] = source_counts["count"] / source_counts["count"].sum()

# Save the PPDF (with raw and normalized counts) to a Parquet file
ppdf_output_file = f"ppdf_{hits_file.split('/')[-1].split('.')[0]}.parquet"
source_counts.to_parquet("/vscratch/grp-rutaoyao/Tridev/" + ppdf_output_file, engine='fastparquet')

# Save the source positions to a Parquet file
source_positions_output_file = f"source_positions_{hits_file.split('/')[-1].split('.')[0]}.parquet"
source_positions.to_parquet("/vscratch/grp-rutaoyao/Tridev/" + source_positions_output_file, engine='fastparquet')

# Save the detector positions to a Parquet file
detector_positions_output_file = f"detector_positions_{hits_file.split('/')[-1].split('.')[0]}.parquet"
detector_positions.to_parquet("/vscratch/grp-rutaoyao/Tridev/" + detector_positions_output_file, engine='fastparquet')

# Save the selected detector positions to a Parquet file
selected_detector_positions_output_file = f"selected_detector_positions_{hits_file.split('/')[-1].split('.')[0]}.parquet"
selected_detector_positions.to_parquet("/vscratch/grp-rutaoyao/Tridev/" + selected_detector_positions_output_file, engine='fastparquet')

# Save the highlighted detector data to a Parquet file
highlighted_detector_output_file = f"highlighted_detector_{hits_file.split('/')[-1].split('.')[0]}.parquet"
highlighted_detector_df.to_parquet("/vscratch/grp-rutaoyao/Tridev/" + highlighted_detector_output_file, engine='fastparquet')
