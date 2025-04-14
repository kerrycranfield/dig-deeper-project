#!/bin/bash

#Script to export Taxonomy abudence table and perform Guild identification and abundence using FUNGuild
#Sam Brocklehurst

# Activate conda environment
source /home/sam/miniconda3/bin/activate qiime2-amplicon-2024.10

# Define paths
ITS_DIR="/home/sam/UniGroup/data/restreco_grassland/ITS"
DENOISE_DIR="$ITS_DIR/denoise"
GUILD_DIR="$ITS_DIR/funguild"
TABLE="$DENOISE_DIR/rare_table_aggregated.qza"
TAXONOMY="$DENOISE_DIR/taxonomy.qza"
GUILD_INPUT="$GUILD_DIR/funguild_input.tsv"
GUILD_OUTPUT="$GUILD_DIR/funguild_output.txt"
FUN_TOOL="/home/sam/UniGroup/tools/FUN_tool.py"
FUNGUILD="/home/sam/UniGroup/resources/FUNGuild/Guilds_v1.1.py"

# Collapse table at genus level, level 6
qiime taxa collapse \
  --i-table "$TABLE" \
  --i-taxonomy "$TAXONOMY" \
  --p-level 6 \
  --o-collapsed-table "$GUILD_DIR/table_collapsed_genus.qza"
  
# Export collapsed table to BIOM format
qiime tools export \
  --input-path "$GUILD_DIR/table_collapsed_genus.qza" \
  --output-path "$GUILD_DIR"

# Convert BIOM to TSV 
biom convert \
  -i "$GUILD_DIR/feature-table.biom" \
  -o "$GUILD_DIR/feature-table.tsv" \
  --to-tsv \
  --header-key taxonomy

# Restructure TSV for FUNGuild compatibility
python "$FUN_TOOL" \
  -i "$GUILD_DIR/feature-table.tsv" \
  -o "$GUILD_INPUT"

# Run FUNGuild
python "$FUNGUILD" \
  -otu "$GUILD_INPUT" \
  -db fungi \
  -m \
  -u

# Deactivate environment
conda deactivate

echo "Fun complete."