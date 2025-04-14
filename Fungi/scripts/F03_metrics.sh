#!/bin/bash

# Activate conda environment
source /home/sam/miniconda3/bin/activate qiime2-amplicon-2024.10

# Define paths
ITS_DIR="/home/sam/UniGroup/data/restreco_grassland/ITS"
DENOISE_DIR="$ITS_DIR/denoise"
METADATA_DIR="$ITS_DIR/metadata"
AGG_METADATA_FILE="$METADATA_DIR/agg_metadata.txt"
METADATA_FILE="$METADATA_DIR/metadata.txt"
COREMETRICS_DIR="$ITS_DIR/coremetrics"
VISUAL_DIR="$COREMETRICS_DIR/visual"
GUILD_DIR="$ITS_DIR/funguild"
RESULTS_DIR="/home/sam/UniGroup/results"

# Clean and recreate output directories (can be run multiple times)
rm -rf "$COREMETRICS_DIR"
mkdir -p "$COREMETRICS_DIR"
mkdir -p "$VISUAL_DIR"
mkdir -p "$RESULTS_DIR"
mkdir -p "$GUILD_DIR"

# Run metrics non-aggregated
qiime diversity core-metrics \
  --i-table "$DENOISE_DIR/table-dada2.qza" \
  --p-sampling-depth 30000 \
  --m-metadata-file "$METADATA_FILE" \
  --o-rarefied-table "$COREMETRICS_DIR/rarefied_table.qza" \
  --o-observed-features-vector "$COREMETRICS_DIR/observed_vector.qza" \
  --o-shannon-vector "$COREMETRICS_DIR/shannon_vector.qza" \
  --o-evenness-vector "$COREMETRICS_DIR/evenness_vector.qza" \
  --o-jaccard-distance-matrix "$COREMETRICS_DIR/jaccard_distance_matrix.qza" \
  --o-bray-curtis-distance-matrix "$COREMETRICS_DIR/bray_curtis_distance_matrix.qza" \
  --o-jaccard-pcoa-results "$COREMETRICS_DIR/jaccard_pcoa.qza" \
  --o-bray-curtis-pcoa-results "$COREMETRICS_DIR/bray_curtis_pcoa.qza" \
  --o-jaccard-emperor "$VISUAL_DIR/jaccard_emperor.qzv" \
  --o-bray-curtis-emperor "$VISUAL_DIR/bray_curtis_emperor.qzv"

# Run metrics aggregated
qiime diversity core-metrics \
  --i-table "$DENOISE_DIR/table_aggregated.qza" \
  --p-sampling-depth 30000 \
  --m-metadata-file "$AGG_METADATA_FILE" \
  --o-rarefied-table "$COREMETRICS_DIR/agg_rarefied_table.qza" \
  --o-observed-features-vector "$COREMETRICS_DIR/agg_observed_vector.qza" \
  --o-shannon-vector "$COREMETRICS_DIR/agg_shannon_vector.qza" \
  --o-evenness-vector "$COREMETRICS_DIR/agg_evenness_vector.qza" \
  --o-jaccard-distance-matrix "$COREMETRICS_DIR/agg_jaccard_distance_matrix.qza" \
  --o-bray-curtis-distance-matrix "$COREMETRICS_DIR/agg_bray_curtis_distance_matrix.qza" \
  --o-jaccard-pcoa-results "$COREMETRICS_DIR/agg_jaccard_pcoa.qza" \
  --o-bray-curtis-pcoa-results "$COREMETRICS_DIR/agg_bray_curtis_pcoa.qza" \
  --o-jaccard-emperor "$VISUAL_DIR/agg_jaccard_emperor.qzv" \
  --o-bray-curtis-emperor "$VISUAL_DIR/agg_bray_curtis_emperor.qzv"

# Alpha diversity significance on non-aggregated table (Eveness)
qiime diversity alpha-group-significance \
  --i-alpha-diversity "$COREMETRICS_DIR/evenness_vector.qza" \
  --m-metadata-file "$METADATA_FILE" \
  --o-visualization "$VISUAL_DIR/evenness_vector.qzv"

# Alpha diversity significance on non-aggregated table (Shannon)
qiime diversity alpha-group-significance \
  --i-alpha-diversity "$COREMETRICS_DIR/shannon_vector.qza" \
  --m-metadata-file "$METADATA_FILE" \
  --o-visualization "$VISUAL_DIR/shannon_significance.qzv"

categories=("Establishment" "pH_category" "Age_category" "Cutting" "Cattle" "Sheep" "Plough")

for category in "${categories[@]}"; do
  qiime diversity beta-group-significance \
    --i-distance-matrix "$COREMETRICS_DIR/agg_bray_curtis_distance_matrix.qza" \
    --m-metadata-file "$AGG_METADATA_FILE" \
    --m-metadata-column "$category" \
    --o-visualization "$VISUAL_DIR/${category}_bray_curtis_significance.qzv" \
    --p-pairwise
  
  qiime diversity beta-group-significance \
    --i-distance-matrix "$COREMETRICS_DIR/agg_jaccard_distance_matrix.qza" \
    --m-metadata-file "$AGG_METADATA_FILE" \
    --m-metadata-column "$category" \
    --o-visualization "$VISUAL_DIR/${category}_jaccard_significance.qzv" \
    --p-pairwise
done

  
# Rarefy aggregated feature table
qiime feature-table rarefy \
  --i-table "$DENOISE_DIR/table_aggregated.qza" \
  --p-sampling-depth 11000 \
  --o-rarefied-table "$DENOISE_DIR/rare_table_aggregated.qza"

# Create taxonomy bar plot on aggregated table
qiime taxa barplot \
  --i-table "$DENOISE_DIR/rare_table_aggregated.qza" \
  --i-taxonomy "$DENOISE_DIR/taxonomy.qza" \
  --m-metadata-file "$AGG_METADATA_FILE" \
  --o-visualization "$VISUAL_DIR/taxa_barplot.qzv"
  
# Collapse table at genus level, level 6
qiime taxa collapse \
  --i-table "$DENOISE_DIR/rare_table_aggregated.qza" \
  --i-taxonomy "$DENOISE_DIR/taxonomy.qza" \
  --p-level 6 \
  --o-collapsed-table "$GUILD_DIR/table_collapsed_genus.qza"   
  
# Perform ANCOM for differential abundance testing on rarefied_aggregated table
 qiime composition add-pseudocount \
   --i-table "$GUILD_DIR/table_collapsed_genus.qza" \
   --o-composition-table "$DENOISE_DIR/composition_table.qza"
 
for category in "${categories[@]}"; do
  qiime composition ancom \
    --i-table "$DENOISE_DIR/composition_table.qza" \
    --m-metadata-file "$AGG_METADATA_FILE" \
    --m-metadata-column "$category" \
    --o-visualization "$VISUAL_DIR/${category}_ancom.qzv"
done 
  
# Copy .qzv outputs to results directory
cp "$VISUAL_DIR"/*.qzv "$RESULTS_DIR/"

# Deactivate environment
conda deactivate

echo "Core metrics complete."
