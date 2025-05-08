import pandas as pd
import numpy as np
import re

# Path settings
input_file = r"d:\PythonProjects\GP_site_metadata.txt"
output_file = r"d:\PythonProjects\GP_site_metadata_cleaned.txt"

# Read raw metadata
df = pd.read_csv(input_file, sep="\t", dtype=str)

# Replace all NA/nan/empty values with 'unknown'
df.fillna("unknown", inplace=True)
df.replace(["NA", "nan"], "unknown", inplace=True)

# Clean invalid characters from all string values
def clean_text(value):
    if isinstance(value, str):
        # Replace problematic symbols with "_"
        return re.sub(r"[ /(),&\"':]", "_", value)
    return value

df = df.applymap(clean_text)

# Convert 0 → no, 1 → yes (only for specific columns)
binary_columns = ["Cutting", "Cattle", "Sheep", "Plough"]
for col in binary_columns:
    if col in df.columns:
        df[col] = df[col].replace({"0": "no", "1": "yes"})

# Convert Year_est and Age to numeric, handle 'old' / '>100'
df["Year_est_clean"] = pd.to_numeric(df["Year_est"], errors="coerce")

df["Age_clean"] = df["Age"].replace({">100": "101", "old": "101", "unknown": np.nan})
df["Age_clean"] = pd.to_numeric(df["Age_clean"], errors="coerce")

# Group Year_est (e.g., into decades)
df["Year_group"] = pd.cut(df["Year_est_clean"], 
                          bins=[1940, 1960, 1980, 2000, 2010, 2020, 2030],
                          labels=["1940-60", "1961-80", "1981-2000", "2001-2010", "2011-2020", "2021+"])

# Group Age
df["Age_group"] = pd.cut(df["Age_clean"],
                         bins=[0, 10, 20, 30, 40, 50, 60, 70, 100, 200],
                         labels=["0-10", "11-20", "21-30", "31-40", "41-50", "51-60", "61-70", "71-100", "100+"])

# Save cleaned metadata
df.drop(columns=["Year_est_clean", "Age_clean"]).to_csv(output_file, sep="\t", index=False)

print(f"Cleaned metadata saved to: {output_file}")
