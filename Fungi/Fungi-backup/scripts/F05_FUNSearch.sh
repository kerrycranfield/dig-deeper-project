#!/bin/bash

# Activate conda environment
source /home/sam/miniconda3/bin/activate qiime2-amplicon-2024.10

# Define paths
ITS_DIR="/home/sam/UniGroup/data/restreco_grassland/ITS"
FUNSEARCH_DIR="$ITS_DIR/Fun_Search"
TABLE="$ITS_DIR/denoise/rare_table_aggregated.qza"
TAXONOMY="$ITS_DIR/denoise/taxonomy.qza"
GUILD_INPUT="$FUNSEARCH_DIR/funguild_input.tsv"
GUILD_OUTPUT="$FUNSEARCH_DIR/funguild_output.txt"
FUN_SEARCH="/home/sam/UniGroup/tools/FUN_Search.py"
FUNGUILD="/home/sam/UniGroup/resources/FUNGuild/Guilds_v1.1.py"

# Create output directory
mkdir -p "$FUNSEARCH_DIR"

# Collapse table at species level (level 7)
qiime taxa collapse \
  --i-table "$TABLE" \
  --i-taxonomy "$TAXONOMY" \
  --p-level 7 \
  --o-collapsed-table "$FUNSEARCH_DIR/table_collapsed_species.qza"

# Export collapsed table to BIOM format
qiime tools export \
  --input-path "$FUNSEARCH_DIR/table_collapsed_species.qza" \
  --output-path "$FUNSEARCH_DIR"

# Convert BIOM to TSV (for FUNGuild input)
biom convert \
  -i "$FUNSEARCH_DIR/feature-table.biom" \
  -o "$FUNSEARCH_DIR/feature-table.tsv" \
  --to-tsv \
  --header-key taxonomy

# Restructure TSV for FUNGuild compatibility
python /home/sam/UniGroup/tools/FUN_tool.py \
  -i "$FUNSEARCH_DIR/feature-table.tsv" \
  -o "$GUILD_INPUT"

# Run FUNGuild
python "$FUNGUILD" \
  -otu "$GUILD_INPUT" \
  -db fungi \
  -m \
  -u

# Run FUNGuild_search to identify species
python "$FUN_SEARCH" \
  -i "$FUNSEARCH_DIR/funguild_input.guilds.txt" \
  -o "$FUNSEARCH_DIR/species_count.txt"

# Deactivate environment
conda deactivate

echo "FUNGuild species-level search complete."
