import argparse
import pandas as pd

# Parse arguments
def parse_args():
    parser = argparse.ArgumentParser(description="Tool to restructure TSV so its compatiable with FUNGuild")
    parser.add_argument("-i", required=True, help="Input TSV file")
    parser.add_argument("-o", required=True, help="Output TSV file")
    return parser.parse_args()

# Function to restructure TSV file for FUNguild
def res_tsv(args):
    # Read the input file ignoring line starting with '#'
    df = pd.read_csv(args.i, sep='\t', comment='#', header=None)

    # Read the header
    with open(args.i, 'r') as f:
        for line in f:
            if line.startswith('#OTU ID'):
                header = line.lstrip('#').strip().split('\t')
                break

    header = header[:df.shape[1]]
    df.columns = header
    df = df.rename(columns={df.columns[0]: 'Taxonomy'})
    
    # Insert 'OTU ID' column
    df.insert(0, 'OTU ID', [f'OTU_{i+1}' for i in range(len(df))])
    
    # Rearrange columns to place 'OTU ID' and 'Taxonomy' at the start
    cols = ['OTU ID', 'Taxonomy'] + [col for col in df.columns if col not in ['OTU ID', 'Taxonomy']]
    df = df[cols]
    
    df.to_csv(args.o, sep='\t', index=False)

def main():
    args = parse_args()
    res_tsv(args)

if __name__ == "__main__":
    main()