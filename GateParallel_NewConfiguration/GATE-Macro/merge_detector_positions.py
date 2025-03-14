import pandas as pd
import glob

def merge_parquet_files(pattern):
    """
    Efficiently merge Parquet files matching a pattern.
    """
    files = glob.glob(pattern)
    if not files:
        return pd.DataFrame()  # Return empty DataFrame if no files found
    # Read and concatenate all Parquet files matching the pattern
    return pd.concat((pd.read_parquet(f) for f in files), ignore_index=True).drop_duplicates()

# Paths to the generated Parquet files
detector_positions_pattern = "/vscratch/grp-rutaoyao/Tridev/detector_positions_*.parquet"

# Merge files and store unique values
detector_positions_combined = merge_parquet_files(detector_positions_pattern)

# Save to a new Parquet file
detector_positions_combined.to_parquet("/vscratch/grp-rutaoyao/Tridev/"+"merged_detector_positions.parquet", index=False)
