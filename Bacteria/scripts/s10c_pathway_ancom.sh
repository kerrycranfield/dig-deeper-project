#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

# PBS directives
#---------------

#PBS -N ancomPathway
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


set -e

# ========== Set folder paths ==========
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
picrust2_folder="${results_folder}/rarefied_picrust2"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"

# ========== Set file names ==========
input_table="${picrust2_folder}/pathway_abundance.qza"
out_folder="${picrust2_folder}/ancom_pathway"
mkdir -p "$out_folder"

log="${out_folder}/ancom_log.txt"

# ========== metadata columns ==========
columns=("Establishment" "Cutting" "Cattle" "Sheep" "Plough" "Year_group" "Age_group" "Age_binary" "pH_binary")

# ========== Step 0: Filter less abundant pathways ==========
echo "✅ Step 0: Filter pathway（pathways to appear in at least 10 samples）" | tee "$log"
qiime feature-table filter-features \
  --i-table "$input_table" \
  --p-min-samples 10 \
  --o-filtered-table "${out_folder}/pathway_filtered.qza" \
  2>> "$log"

# ========== Step 1: Add pseudocount ==========
echo "✅ Step 1: Add pseudocount..." | tee -a "$log"
qiime composition add-pseudocount \
  --i-table "${out_folder}/pathway_filtered.qza" \
  --o-composition-table "${out_folder}/pathway_composition.qza" \
  2>> "$log"

# ========== Step 2: Run ANCOM ==========
echo "✅ Step 2: Start running ANCOM analysis..." | tee -a "$log"

for col in "${columns[@]}"; do
  echo "  ➤ Process: $col ..." | tee -a "$log"

  # Check if column exists
  if ! head -n 1 "$metadata_file" | grep -wq "$col"; then
    echo "     ⚠️ Column '$col' absent in metadata, skip" | tee -a "$log"
    continue
  fi

  # Check if output file already exists
  output_file="${out_folder}/pathway_ancom_${col}.qzv"
  if [ -f "$output_file" ]; then
    echo "     ⏩ '$col' result already exists, skipping..." | tee -a "$log"
    continue
  fi

  # Run ANCOM
  if qiime composition ancom \
    --i-table "${out_folder}/pathway_composition.qza" \
    --m-metadata-file "$metadata_file" \
    --m-metadata-column "$col" \
    --o-visualization "$output_file" \
    2>> "$log"; then
    echo "     ✅ '$col' ANCOM complete ✔️" | tee -a "$log"
  else
    echo "     ❌ '$col' ANCOM failed. Please check the data❗" | tee -a "$log"
  fi
done

echo "������ All pathway ANCOM complete！ Output directory：$out_folder" | tee -a "$log"
date | tee -a "$log"



## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID