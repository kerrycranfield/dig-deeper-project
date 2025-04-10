import argparse
import pandas as pd

# Parse arguments
def parse_args():
    parser = argparse.ArgumentParser(description="Aggregate metadata based on selected column.")
    parser.add_argument("--input", "-i", required=True, help="Path to input metadata file.")
    parser.add_argument("--output", "-o", required=True, help="Path to output aggregated metadata file.")
    parser.add_argument("--column", "-c", default="Site", help="Column name to aggregate on (default: Site).")
    return parser.parse_args()

# Function to aggregate metadata based on selected column
def aggregate_metadata(args):
    metadata_df = pd.read_csv(args.input, sep="\t", dtype=str)

    # Check if selected column exists
    if args.column not in metadata_df.columns:
        raise ValueError(f"Column '{args.column}' not found in metadata.")

    # Aggregate metadata by selected column, joining unique values including NAs
    aggregated_df = metadata_df.groupby(args.column, as_index=False).agg(
        lambda x: ';'.join(sorted(x.astype(str).unique()))
    )

    # Drop 'sample-id' column if it exists, then insert it as the first column
    if 'sample-id' in aggregated_df.columns:
        aggregated_df.drop(columns=['sample-id'], inplace=True)

    aggregated_df.insert(0, 'sample-id', aggregated_df[args.column])
    aggregated_df.drop(columns=[args.column], inplace=True)

    # Remove unwanted columns
    for col in ['plot_number', 'CU Code']:
        if col in aggregated_df.columns:
            aggregated_df.drop(columns=[col], inplace=True)

    aggregated_df.to_csv(args.output, sep="\t", index=False)
    print(f"Aggregated metadata written to: {args.output}")

def main():
    args = parse_args()
    aggregate_metadata(args)

if __name__ == "__main__":
    main()
