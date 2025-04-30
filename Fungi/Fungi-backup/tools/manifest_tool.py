import pandas as pd
import os
import argparse

# Parse arguments
def parse_args():
    parser = argparse.ArgumentParser(description='Generate sample IDs and file paths from CU Codes')
    parser.add_argument('-i', required=True, help='Path to the input text file')
    parser.add_argument('-f', required=True, help='Folder containing FASTQ files')
    parser.add_argument('-o', required=True, help='Output directory for manifest.txt and manifest.log')
    return parser.parse_args()

# Function to generate the manifest file
def generate_manifest(args):
    
    os.makedirs(args.o, exist_ok=True)
    manifest_txt_path = os.path.join(args.o, 'manifest.txt')
    manifest_log_path = os.path.join(args.o, 'manifest.log')

    
    df = pd.read_csv(args.i, sep='\t')
    df['sample_id'] = df['CU Code'].apply(lambda x: 'GF' + str(int(x.replace('CU', ''))))
    df['GF_number'] = df['sample_id']

    output_rows = []
    missing_files = []

    # Loop through each row and check FASTQ file is present
    for _, row in df.iterrows():
        sample_id = row['sample_id']
        gf_num = row['GF_number']

        # Construct the file path
        forward_path = os.path.join(args.f, f"{gf_num}_trimmed_1.fastq.gz")
        reverse_path = os.path.join(args.f, f"{gf_num}_trimmed_2.fastq.gz")

        # Check if the forward file exists, if not add to log file
        if os.path.exists(forward_path):
            output_rows.append([sample_id, forward_path, 'forward'])
        else:
            missing_files.append(f"Missing file: {forward_path}")

        # Check if the reverse file exists, if not add to log file
        if os.path.exists(reverse_path):
            output_rows.append([sample_id, reverse_path, 'reverse'])
        else:
            missing_files.append(f"Missing file: {reverse_path}")

    # Save the output 
    output_df = pd.DataFrame(output_rows, columns=['sample-id', 'absolute-filepath', 'direction'])
    output_df.to_csv(manifest_txt_path, sep=',', index=False, header=True)

    # Write a log of missing files
    with open(manifest_log_path, 'w') as log_file:
        if missing_files:
            for line in missing_files:
                log_file.write(line + '\n')
        else:
            log_file.write('No missing files detected.\n')


def main():
    args = parse_args()
    generate_manifest(args)


if __name__ == "__main__":
    main()