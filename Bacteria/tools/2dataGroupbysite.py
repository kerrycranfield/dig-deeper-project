import pandas as pd

# File paths
input_file = r"d:\PythonProjects\GP_metadata_fixed.txt"
output_file = r"d:\PythonProjects\GP_site_metadata.txt"

# Read data (preserve string 'NA' as-is)
df = pd.read_csv(input_file, sep="\t", dtype=str, keep_default_na=False, na_values=[])

# Select columns for deduplication (keep one row per Site)
group_cols = [
    'Site', 'Year_est', 'Age', 'OS_location', 'Lat_long',
    'Establishment', 'pH', 'EC', 'Cutting', 'Cattle', 'Sheep', 'Plough'
]
df_unique = df[group_cols].drop_duplicates()

# Set Site as index and rename it to #SampleID (does not rename column itself)
df_unique = df_unique.set_index('Site')
df_unique.index.name = '#SampleID'

# Save cleaned metadata
df_unique.to_csv(output_file, sep="\t", na_rep="NA")

print(f"New metadata file has been saved to: {output_file}")
