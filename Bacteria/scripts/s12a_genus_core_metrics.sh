#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

# Crescent2 script
# Note: this script should be run on a compute node
# qsub script.sh

# PBS directives
#---------------

#PBS -N genuscoremetrics
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



# ========= Set up folder paths =========
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"
genus_table="${results_folder}/genus_ancom_results/genus_table.qza"
output_folder="${results_folder}/coremetrics_genus"

mkdir -p "$output_folder"
log="${output_folder}/coremetrics_log.txt"

# ========= Set rarefaction depth =========
sampling_depth=9473

echo "‚úÖ Start running core-metrics analysis (Genus level) ..." | tee "$log"
echo "Ì†ΩÌ≥Å Output path: $output_folder" | tee -a "$log"
echo "Ì†ΩÌ≥è Sampling depth: $sampling_depth" | tee -a "$log"

# ========= Step 1: alpha + beta diversity core metrics =========
qiime diversity core-metrics \
  --i-table "$genus_table" \
  --p-sampling-depth "$sampling_depth" \
  --m-metadata-file "$metadata_file" \
  --o-rarefied-table "$output_folder/rarefied_table.qza" \
  --o-observed-features-vector "$output_folder/observed_features_vector.qza" \
  --o-shannon-vector "$output_folder/shannon_vector.qza" \
  --o-evenness-vector "$output_folder/evenness_vector.qza" \
  --o-jaccard-distance-matrix "$output_folder/jaccard_distance_matrix.qza" \
  --o-bray-curtis-distance-matrix "$output_folder/bray_curtis_distance_matrix.qza" \
  --o-jaccard-pcoa-results "$output_folder/jaccard_pcoa_results.qza" \
  --o-bray-curtis-pcoa-results "$output_folder/bray_curtis_pcoa_results.qza" \
  --o-jaccard-emperor "$output_folder/jaccard_emperor.qzv" \
  --o-bray-curtis-emperor "$output_folder/bray_curtis_emperor.qzv"

# ========= Step 2: Significance testing =========
columns=("Establishment" "Cutting" "Cattle" "Sheep" "Plough" "Year_group" "Age_group" "Age_binary" "pH_binary")

echo "‚û°Ô∏è Run beta-group-significance analysis..." | tee -a "$log"

for col in "${columns[@]}"; do
  if ! head -n 1 "$metadata_file" | grep -qw "$col"; then
    echo "‚ö†Ô∏è '$col' not present in metadata, skip..." | tee -a "$log"
    continue
  fi

  qiime diversity beta-group-significance \
    --i-distance-matrix "$output_folder/bray_curtis_distance_matrix.qza" \
    --m-metadata-file "$metadata_file" \
    --m-metadata-column "$col" \
    --p-method permanova \
    --o-visualization "$output_folder/bray_permanova_${col}.qzv"

  echo "  ‚úÖ $col completed" | tee -a "$log"
done

# ========= Step 3: Alpha group significance =========
qiime diversity alpha-group-significance \
  --i-alpha-diversity "$output_folder/shannon_vector.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$output_folder/shannon_group_significance.qzv"

qiime diversity alpha-group-significance \
  --i-alpha-diversity "$output_folder/observed_features_vector.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$output_folder/observed_features_group_significance.qzv"

echo "Ì†ºÌæâ All Genus-level core-metrics completedÔºÅ" | tee -a "$log"
date

echo "Done"
date

