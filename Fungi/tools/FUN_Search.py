import pandas as pd
import argparse

# --- Argument parser setup ---
parser = argparse.ArgumentParser(description="Search FUNGuild output for specific species.")
parser.add_argument("-i", "--input", required=True, help="Path to FUNGuild output file (TSV)")
parser.add_argument("-o", "--output", required=True, help="Path to save the results (CSV)")
args = parser.parse_args()

# --- Species list to search ---
species_list = [
    "Hygrocybe_conica",
    "Hygrocybe_viginea",
    "Hygrocybe_sp",
    "Coprinus_sp",
    "Hygrocybe_psittacina",
    "Geoglossum_glutinosum",
    "Agaricus_campestris",
    "Vascellum_pratense",
    "Marasmius_oreades",
    "Geoglossum_sp"
]

# --- Load TSV file ---
try:
    df = pd.read_csv(args.input, sep="\t", dtype=str)
    df.fillna("0", inplace=True)
except Exception as e:
    print(f"? Error reading input file: {e}")
    exit(1)

# --- Identify abundance columns by excluding known metadata columns ---
non_abundance_cols = {
    "OTU ID", "Taxonomy", "Taxon", "Taxon Level", "Trophic Mode", "Guild",
    "Growth Morphology", "Trait", "Confidence Ranking", "Notes", "Citation/Source"
}
abundance_columns = [col for col in df.columns if col not in non_abundance_cols]

# Try to convert only abundance columns to float
try:
    df[abundance_columns] = df[abundance_columns].astype(float)
except Exception as e:
    print(f"? Error parsing abundance values: {e}")
    exit(1)

# --- Search logic ---
results = []

for species in species_list:
    for _, row in df.iterrows():
        taxonomy = row.get("Taxonomy", "")
        if species.lower() in taxonomy.lower():
            for sample in abundance_columns:
                abundance = row[sample]
                if float(abundance) > 0:
                    results.append({
                        "Species Match": species,
                        "Sample": sample,
                        "Abundance": abundance
                    })

# --- Output results ---
output_df = pd.DataFrame(results)

if not output_df.empty:
    try:
        output_df.to_csv(args.output, index=False)
        print(f"Results saved to {args.output}")
    except Exception as e:
        print(f"Could not save output: {e}")
else:
    print("No matches found for the listed species.")



