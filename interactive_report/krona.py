import os
import re
import zipfile
import pandas as pd


taxa_qzv = "data/taxonomy_gg2_full_length_barplot.qzv"  # Path to your taxonomy.qzv file
metadata_file = "data/GP_metadata.txt"                  # Sample metadata file (contains sample -> site mapping)
outdir = "Krona"                                        # Output directory for the final Krona HTML
tmpdir = "krona-tsv"                                    # Temporary directory for intermediate Krona TSVs


def unzip_taxa_csv(qzv_file):
    # Open the .qzv archive as a zip file
    with zipfile.ZipFile(qzv_file) as zipf:
        for zip_info in zipf.infolist():
            # Search for level-7.csv, which contains taxa abundance per sample
            if "level-7.csv" in zip_info.filename:
                zip_info.filename = os.path.basename(zip_info.filename)
                zipf.extract(zip_info)  # Extract the file to current directory
                return zip_info.filename  # Return the name for loading

csv_file = unzip_taxa_csv(taxa_qzv)  # Extract and store CSV filename


data = pd.read_csv(csv_file)  # Load the table with sample x taxon abundances
os.remove(csv_file)           # Clean up extracted file after loading


meta = pd.read_csv(metadata_file, sep="\t")  # Load metadata file (tab-separated)
meta = meta.rename(columns=lambda x: x.strip())  # Strip whitespace from column names
meta["SampleID"] = meta["CU Code"].str.replace(r"^CU0", "GP", regex=True)  # Fix sample IDs if needed

# Create a dictionary that maps each sample ID to its site
sample_to_site = dict(zip(meta["SampleID"], meta["Site"]))


# Keep only the columns that represent taxonomic lineages
taxa_cols = [col for col in data.columns if ";" in col or col.startswith("Unassigned")]


def clean_taxon(t):
    # Remove prefixes like D_0__ or k__, p__, etc.
    t = re.sub(r"D_\d__", "", t)
    t = re.sub(r"\w__", "", t)
    return t.replace(";", "\t")  # Convert semicolons to tabs for Krona format

cleaned_taxa = [clean_taxon(t) for t in taxa_cols]


# For each site, we will sum the taxon counts from all its samples
site_taxa = {}

for idx, row in data.iterrows():
    sample = row["index"]  # Sample name
    site = sample_to_site.get(sample, None)  # Lookup corresponding site
    if site is None:
        continue  # Skip if no matching site in metadata

    if site not in site_taxa:
        site_taxa[site] = [0] * len(taxa_cols)  # Initialise zero vector

    # Add each taxon's count for this sample to the site's total
    for i, col in enumerate(taxa_cols):
        site_taxa[site][i] += row[col]


os.makedirs(tmpdir, exist_ok=True)

for site, abundances in site_taxa.items():
    # Sanitize site name for safe filenames
    safe_site = re.sub(r"[\\/:*?\"<>|]", "_", site)
    outpath = os.path.join(tmpdir, f"{safe_site}.tsv")

    # Write TSV: each line = <abundance> \t <taxonomic lineage>
    with open(outpath, "w") as f:
        for val, lineage in zip(abundances, cleaned_taxa):
            if val > 0:
                f.write(f"{int(val)}\t{lineage}\n")

os.makedirs(outdir, exist_ok=True)
html_output = os.path.join(outdir, "krona_by_site.html")


os.system(f"ktImportText {tmpdir}/*.tsv -o {html_output}")

os.system(f"rm -r {tmpdir}")  # Remove the temporary directory with TSV files

print(f"\n Krona HTML generated: {html_output}")
