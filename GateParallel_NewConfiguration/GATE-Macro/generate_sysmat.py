import sys
import uproot
import pandas as pd

# Get input file names from command line arguments
hits_file = sys.argv[1]
singles_file = sys.argv[2]

# Open the ROOT files
hits_data = uproot.open("/vscratch/grp-rutaoyao/Tridev/" + hits_file)["tree;1"].arrays(
    ["posX", "posY", "volumeID[2]", "volumeID[6]", "eventID"], library="pd"
)
source_data = uproot.open("/vscratch/grp-rutaoyao/Tridev/" + singles_file)["tree;1"].arrays(
    ["sourcePosX", "sourcePosY", "sourcePosZ", "eventID"], library="pd"
)

# Extract relevant positions
source_positions = source_data[["sourcePosX", "sourcePosY", "eventID"]]

# Initialize a list to store PPDF for all detectors
ppdf_list = []

# Loop over all detectors
selected_volumeID_2 = 0  # Assuming volumeID[2] is constant
for detector_id in range(144):  # volumeID[6] ranges from 0 to 127
    # Extract positions of the selected detector
    selected_detector_positions = hits_data[
        (hits_data["volumeID[2]"] == selected_volumeID_2)
        & (hits_data["volumeID[6]"] == detector_id)
    ][["posX", "posY", "eventID"]]

    # Find matching source events that hit the selected detector
    matched_events = source_positions[source_positions["eventID"].isin(selected_detector_positions["eventID"])]

    # Group by source position and count occurrences
    source_counts = matched_events.groupby(["sourcePosX", "sourcePosY"]).size().reset_index(name="count")

    # Normalize the counts to get a probability density
    source_counts["normalized_count"] = source_counts["count"] / source_counts["count"].sum()

    # Add detector ID to the dataframe
    source_counts["detector_id"] = detector_id

    # Append to the PPDF list
    ppdf_list.append(source_counts)

# Combine all PPDFs into a single DataFrame
ppdf_system_matrix = pd.concat(ppdf_list, ignore_index=True)

# Save the system matrix to a Parquet file
output_file = f"system_matrix_{hits_file.split('/')[-1].split('.')[0]}.parquet"
ppdf_system_matrix.to_parquet("/vscratch/grp-rutaoyao/Tridev/"+output_file, index=False)

print(f"System matrix saved to: /vscratch/grp-rutaoyao/Tridev/{output_file}")
