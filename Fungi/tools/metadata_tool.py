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
    # Read the manifest file and extract unique sample ID
    manifest_df = pd.read_csv(args.manifest)
    sample_ids = manifest_df['sample-id'].unique()
    sample_ids_dict = {str(int(extract_numeric(sid))): sid for sid in sample_ids if extract_numeric(sid)}
    
    metadata_df = pd.read_csv(args.metadata, sep="\t", dtype=str)

    # Check if CU Code columne exists
    if "CU Code" not in metadata_df.columns:
        raise ValueError("'CU Code' column is missing in the metadata file.")
    
    # Extract CU Code number
    metadata_df["CU_numeric"] = metadata_df["CU Code"].str.extract(r'(\d+)$')[0].astype(int).astype(str)

    # Filter metadata based on CU codes
    metadata_df = metadata_df[metadata_df["CU_numeric"].isin(sample_ids_dict.keys())]

    # Replace site code with new sample IDs from the manifest
    metadata_df.insert(0, "sample-id", metadata_df["CU_numeric"].map(sample_ids_dict))
    metadata_df.drop(columns=["CU_numeric"], inplace=True)
   
    metadata_df.to_csv(args.output, sep="\t", index=False)
    print(f"Processed metadata written to: {args.output}")

def main():
    args = parse_args()
    match_metadata(args)

if __name__ == "__main__":
    main()