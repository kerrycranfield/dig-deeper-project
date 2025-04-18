#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

# Crescent2 script
# Note: this script should be run on a compute node
# qsub script.sh

# PBS directives
#---------------

#PBS -N familycoremetrics
#PBS -l nodes=1:ncpus=12
#PBS -l walltime=00:30:00
#PBS -q half_hour
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
set -e
module load CONDA/qiime2-amplicon-2024.5

#!/bin/bash

# ========= Set up folder paths =========
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"
family_table="${results_folder}/family_ancom_results/family_table.qza"
output_folder="${results_folder}/coremetrics_family"
mkdir -p "$output_folder"
log="${output_folder}/coremetrics_log.txt"

# ========= Set rarefaction depth =========
sampling_depth=9473

# If output folder with the same name already exists, delete
rm -rf "$output_folder"
mkdir -p "$output_folder"

# ========= 样本分组列 =========
columns=("Establishment" "Cutting" "Cattle" "Sheep" "Plough" "Year_group" "Age_group" "Age_binary" "pH_binary")

# ========= Step 1: core-metrics =========
echo "? Start running core-metrics analysis (Family level) ..." | tee "$log"
echo "?? Output path: $output_folder" | tee -a "$log"
echo "?? Sampling depth: $sampling_depth" | tee -a "$log"

qiime diversity core-metrics \
  --i-table "$family_table" \
  --p-sampling-depth "$sampling_depth" \
  --m-metadata-file "$metadata_file" \
  --o-rarefied-table "$output_folder/rarefied_table.qza" \
  --o-observed-features-vector "$output_folder/observed_features.qza" \
  --o-shannon-vector "$output_folder/shannon.qza" \
  --o-evenness-vector "$output_folder/evenness.qza" \
  --o-jaccard-distance-matrix "$output_folder/jaccard_distance_matrix.qza" \
  --o-bray-curtis-distance-matrix "$output_folder/bray_curtis_distance_matrix.qza" \
  --o-jaccard-pcoa-results "$output_folder/jaccard_pcoa.qza" \
  --o-bray-curtis-pcoa-results "$output_folder/bray_curtis_pcoa.qza" \
  --o-jaccard-emperor "$output_folder/jaccard_emperor.qzv" \
  --o-bray-curtis-emperor "$output_folder/bray_emperor.qzv"

# ========= Step 2: Beta significance test =========
echo "?? Run beta-group-significance analysis..." | tee -a "$log"
for col in "${columns[@]}"; do
  if ! head -n 1 "$metadata_file" | grep -qw "$col"; then
    echo "?? '$col' not present in metadata, skip..." | tee -a "$log"
    continue
  fi

  qiime diversity beta-group-significance \
    --i-distance-matrix "$output_folder/bray_curtis_distance_matrix.qza" \
    --m-metadata-file "$metadata_file" \
    --m-metadata-column "$col" \
    --p-method permanova \
    --o-visualization "$output_folder/bray_permanova_${col}.qzv"

  echo "  ? $col PERMANOVA completed" | tee -a "$log"
done

# ========= Step 3: Alpha diversity significance =========
echo "?? Alpha Diversity analysis..." | tee -a "$log"
alpha_metrics=("observed_features" "shannon" "evenness")
for metric in "${alpha_metrics[@]}"; do
  for col in "${columns[@]}"; do
    if ! head -n 1 "$metadata_file" | grep -qw "$col"; then
      echo "?? '$col' not present in metadata, skip..." | tee -a "$log"
      continue
    fi

    qiime diversity alpha-group-significance \
      --i-alpha-diversity "$output_folder/${metric}.qza" \
      --m-metadata-file "$metadata_file" \
      --o-visualization "$output_folder/${metric}_alpha_significance_${col}.qzv"

    echo "  ? ${metric} vs. $col analysis completed" | tee -a "$log"
  done
done

echo "?? All Family-level core-metrics completed！" | tee -a "$log"
date
