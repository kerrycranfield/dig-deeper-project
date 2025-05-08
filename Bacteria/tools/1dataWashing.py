import pandas as pd
import re

input_file = r"d:\PythonProjects\GP_metadata.txt"
output_file = r"d:\PythonProjects\GP_metadata_fixed.txt"

# Read the file without interpreting 'NA' as missing values
df = pd.read_csv(input_file, sep="\t", dtype=str, keep_default_na=False, na_values=[])

# Forward-fill missing values in the first column (typically site_code / Field No.)
df.iloc[:, 0] = df.iloc[:, 0].ffill()

# Strip column names and locate the 'CU Code' column
df.columns = df.columns.str.strip()
cu_col = [col for col in df.columns if "CU" in col and "Code" in col]
if not cu_col:
    raise ValueError("Column 'CU Code' not found. Please check the file format.")

# Rename CU Code column to '#SampleID' and move it to the first column
df.rename(columns={cu_col[0]: "#SampleID"}, inplace=True)
df = df[["#SampleID"] + [col for col in df.columns if col != "#SampleID"]]

# Modify SampleID: remove 'CU' prefix and leading zeros → replace with 'GP'
df["#SampleID"] = df["#SampleID"].apply(lambda x: re.sub(r"^CU0*", "GP", x))

# Replace commas with semicolons in 'Lat_long' column
if "Lat_long" in df.columns:
    df["Lat_long"] = df["Lat_long"].str.replace(",", ";", regex=False)

# Clean column names: remove or replace special characters
df.columns = [col.strip().replace(" ", "_").replace("/", "_").replace("(", "").replace(")", "") for col in df.columns]

# Clean field values: replace problematic characters with underscores
df = df.applymap(lambda x: re.sub(r"[ \/()]", "_", x) if isinstance(x, str) else x)

# Write to output file, retaining literal 'NA' values
df.to_csv(output_file, sep="\t", index=False, na_rep="NA")

print(f"Metadata cleaned and saved to: {output_file}")
