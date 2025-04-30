import argparse
import pandas as pd
import re

# Parse arguments
def parse_args():
    parser = argparse.ArgumentParser(description="Match and merge sample IDs with metadata.")
    parser.add_argument("--manifest", "-m", required=True, help="Path to manifest file (CSV format with sample-id column).")
    parser.add_argument("--metadata", "-d", required=True, help="Path to metadata file (tab-delimited).")
    parser.add_argument("--output", "-o", required=True, help="Path to output processed metadata file.")
    return parser.parse_args()

# Function to extract sample ID number
def extract_numeric(sample_id):
    match = re.search(r'(\d+)$', sample_id)
    return match.group(1) if match else None

# Function to match metadata sample IDs from manifest
def match_metadata(args):
    manifest_df = pd.read_csv(args.manifest)
    sample_ids = manifest_df['sample-id'].unique()
    sample_ids_dict = {str(int(extract_numeric(sid))): sid for sid in sample_ids if extract_numeric(sid)}

    metadata_df = pd.read_csv(args.metadata, sep="\t", dtype=str)

    if "CU Code" not in metadata_df.columns:
        raise ValueError("'CU Code' column is missing in the metadata file.")

    metadata_df["CU_numeric"] = metadata_df["CU Code"].str.extract(r'(\d+)$')[0].astype(int).astype(str)
    metadata_df = metadata_df[metadata_df["CU_numeric"].isin(sample_ids_dict.keys())]
    metadata_df.insert(0, "sample-id", metadata_df["CU_numeric"].map(sample_ids_dict))
    metadata_df.drop(columns=["CU_numeric"], inplace=True)

    metadata_df = metadata_df.replace('/', '_', regex=True)

    columns_to_modify = ['Cutting', 'Cattle', 'Sheep', 'Plough']
    metadata_df[columns_to_modify] = metadata_df[columns_to_modify].replace({'1': 'Yes', '0': 'No', pd.NA: 'NA', '': 'NA'})

    # Process pH column
    if 'pH' in metadata_df.columns:
        metadata_df['pH'] = pd.to_numeric(metadata_df['pH'], errors='coerce')
        pH_median = metadata_df['pH'].median()
        metadata_df['pH_category'] = metadata_df['pH'].apply(lambda x: 'Above_median' if x > pH_median else 'Below_median')

    # Process Age column
    if 'Age' in metadata_df.columns:
        metadata_df['Age_numeric'] = pd.to_numeric(metadata_df['Age'].replace('>100', '101'), errors='coerce')
        age_median = metadata_df['Age_numeric'].median()
        metadata_df['Age_category'] = metadata_df.apply(
            lambda row: 'Above_median' if (row['Age'] == '>100' or row['Age_numeric'] > age_median) else 'Below_median', axis=1)
        metadata_df.drop(columns=['Age_numeric'], inplace=True)

    metadata_df.to_csv(args.output, sep="\t", index=False, na_rep='NA')
    print(f"Processed metadata written to: {args.output}")

def main():
    args = parse_args()
    match_metadata(args)

if __name__ == "__main__":
    main()