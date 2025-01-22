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
highlighted_detector_pattern = "/vscratch/grp-rutaoyao/Tridev/highlighted_detector_*.parquet"

# Merge files and store unique values
highlighted_detector_combined = merge_parquet_files(highlighted_detector_pattern)

# Save to a new Parquet file
highlighted_detector_combined.to_parquet("merged_highlighted_detector.parquet", index=False)
