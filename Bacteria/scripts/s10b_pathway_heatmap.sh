#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

# PBS directives
#---------------

#PBS -N heatmapPathway
#PBS -l nodes=1:ncpus=12
#PBS -l walltime=12:00:00
#PBS -q half_day
#PBS -m abe
#PBS -M shangda.zhu@cranfield.ac.uk

#===============
#PBS -j oe
#PBS -v "CUDA_VISIBLE_DEVICES="
#PBS -W sandbox=PRIVATE
#PBS -k n
ln -s $PWD $PBS_O_WORKDIR/$PBS_JOBID
## Change to working directory
cd $PBS_O_WORKDIR
## Calculate number of CPUs and GPUs
export cpus=`cat $PBS_NODEFILE | wc -l`
## Load production modules
module use /apps2/modules/all
## =============

# Stop at runtime errors
set -e
module load CONDA/qiime2-amplicon-2024.5


# Start message
echo "QIIME2: picrust2"
date
echo ""


# ========== Set folder pathways ==========
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
picrust2_folder="${results_folder}/rarefied_picrust2"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"

# ========== File names ==========
raw_table="${picrust2_folder}/pathway_abundance.qza"
filtered_feature_table="${picrust2_folder}/pathway_top.qza"
heatmap_out="${picrust2_folder}/heatmaps_pathway"
mkdir -p "$heatmap_out"

# ========== Step 1: 筛选高丰度功能 ==========
echo "✅ Step 1: Filter most abundant pathways..."
qiime feature-table filter-features \
  --i-table "$raw_table" \
  --p-min-frequency 600000 \
  --p-min-samples 60 \
  --o-filtered-table "$filtered_feature_table"

# ========== Step 2: Generate Heatmap（仅指定列） ==========
echo "✅ Step 2: Generate heatmap figure..."

# Specify metadata columns
columns=("Establishment" "Cutting" "Cattle" "Sheep" "Plough" "Year_group" "Age_group" "Age_binary" "pH_binary")

# Loop through metadata columns for heatmap
for col in "${columns[@]}"; do
  echo "  ➤ Processing column: $col"

  qiime feature-table heatmap \
    --i-table "$filtered_feature_table" \
    --m-sample-metadata-file "$metadata_file" \
    --m-sample-metadata-column "$col" \
    --o-visualization "${heatmap_out}/pathway_heatmap_by_${col}.qzv" \
    --p-color-scheme "YlGnBu"

  if [ $? -eq 0 ]; then
    echo "    ✅ Heatmap for '$col' saved."
  else
    echo "    ❌ Heatmap generation failed for '$col'"
  fi
done

echo "������ All heatmap drawing complete！"
date


## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID