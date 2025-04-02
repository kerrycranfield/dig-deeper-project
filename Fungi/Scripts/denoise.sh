#!/bin/bash

# Script to import trimmed sequences, perform denoise, classification, aggregation and rarefaction plot
# Sam Brocklehurst

# Define directories
ITS_DIR="/home/sam/UniGroup/data/restreco_grassland/ITS"
INPUT_DIR="$ITS_DIR/01.RawData"
TRIMMED_DIR="$ITS_DIR/trimmed_reads"
DENOISE_DIR="$ITS_DIR/denoise"
METADATA_DIR="$ITS_DIR/metadata"
CLASSIFIER="/home/sam/UniGroup/resources/unite_ver10_dynamic_all_19.02.2025-Q2-2024.10.qza"
RAW_METADATA="/home/sam/UniGroup/data/restreco_grassland/GP_metadata.txt"
MANIFEST="$TRIMMED_DIR/manifest.txt"

# Create output directories
mkdir -p "$DENOISE_DIR" "$METADATA_DIR"

# Activate environment
source /home/sam/miniconda3/bin/activate qiime2-amplicon-2024.10

# Generate manifest
python /home/sam/UniGroup/tools/manifest_tool.py \
  -i "$RAW_METADATA" -f "$TRIMMED_DIR" -o "$TRIMMED_DIR"

# Import sequences
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-format PairedEndFastqManifestPhred33 \
  --input-path "$MANIFEST" \
  --output-path "$DENOISE_DIR/sequence.qza"

# Denoise with DADA2
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs "$DENOISE_DIR/sequence.qza" \
  --p-trunc-len-f 0 \
  --p-trunc-len-r 0 \
  --o-representative-sequences "$DENOISE_DIR/rep-seqs-dada2.qza" \
  --o-table "$DENOISE_DIR/table-dada2.qza" \
  --o-denoising-stats "$DENOISE_DIR/stats-dada2.qza"

# Taxonomy classification
qiime feature-classifier classify-sklearn \
  --i-classifier "$CLASSIFIER" \
  --i-reads "$DENOISE_DIR/rep-seqs-dada2.qza" \
  --o-classification "$DENOISE_DIR/taxonomy.qza"

# Generate non-aggregated metadata
python /home/sam/UniGroup/tools/metadata_tool.py \
  -m "$MANIFEST" -d "$RAW_METADATA" -o "$METADATA_DIR/metadata.txt"

# Summarize feature table
qiime feature-table summarize \
  --i-table "$DENOISE_DIR/table-dada2.qza" \
  --o-visualization "$DENOISE_DIR/table-dada2.qzv" \
  --m-sample-metadata-file "$METADATA_DIR/metadata.txt"

# Aggregate feature table by Site
qiime feature-table group \
  --i-table "$DENOISE_DIR/table-dada2.qza" \
  --p-axis sample \
  --m-metadata-file "$METADATA_DIR/metadata.txt" \
  --m-metadata-column Site \
  --p-mode median-ceiling \
  --o-grouped-table "$DENOISE_DIR/table_aggregated.qza"

# Generate aggregated metadata
python /home/sam/UniGroup/tools/agg_metadata_tool.py \
  -i "$METADATA_DIR/metadata.txt" \
  -o "$METADATA_DIR/agg_metadata.txt" \
  -c "Site"

# Alpha rarefaction on aggregated data
qiime diversity alpha-rarefaction \
  --i-table "$DENOISE_DIR/table_aggregated.qza" \
  --p-max-depth 50000 \
  --m-metadata-file "$METADATA_DIR/agg_metadata.txt" \
  --o-visualization "$DENOISE_DIR/aggregated_rarefaction.qzv"

# Deactivate environment
conda deactivate

echo "Denoising and aggregation complete."

