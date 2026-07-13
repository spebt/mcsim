import os
import glob
import uproot
import pandas as pd

N_CRYSTALS_PER_PANEL = 144
N_PANELS = 6
N_DETECTORS = N_PANELS * N_CRYSTALS_PER_PANEL  # 864

run_tag = os.environ.get("RUN_TAG")
if not run_tag:
    raise RuntimeError("RUN_TAG environment variable not set (expected 'box')")
base_dir = f"/vscratch/grp-rutaoyao/Tridev/{run_tag}"

hits_files = sorted(glob.glob(f"{base_dir}/hits*.root"))
print(f"Found {len(hits_files)} hits files in {base_dir}")

# Tally counts per detector across every merged hits file. No sourcePosX/Y is
# ever read here -- this deliberately mirrors a real detector readout: counts
# per crystal, nothing about where the photon actually came from.
counts = pd.Series(0, index=range(N_DETECTORS), dtype="int64")

for f in hits_files:
    hits = uproot.open(f)["tree;1"].arrays(["volumeID[2]", "volumeID[6]"], library="pd")
    hits = hits.rename(columns={"volumeID[2]": "panel_id", "volumeID[6]": "crystal_id"})
    hits["detector_id"] = hits["panel_id"] * N_CRYSTALS_PER_PANEL + hits["crystal_id"]
    file_counts = hits["detector_id"].value_counts()
    counts = counts.add(file_counts, fill_value=0)
    print(f"  {f}: {int(file_counts.sum())} hits")

projection_data = counts.astype("int64").reset_index()
projection_data.columns = ["detector_id", "counts"]

# Saved OUTSIDE /vscratch -- this is your one persistent copy of the
# box-source measurement, used directly by mlem_reconstruct.py.
output_path = "/user/YOURNAME/mcsim/GateParallel_MOBY/GATE-Macro/projection_data_box_source.parquet"
projection_data.to_parquet(output_path, index=False)
print(f"Projection data saved to {output_path}")
print(f"Total detected counts: {projection_data['counts'].sum()}")