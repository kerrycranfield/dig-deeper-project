#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

# PBS directives
#---------------

#PBS -N alphadiversityfunctional
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


#!/bin/bash

# ========= Set folder paths =========
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
picrust2_folder="${results_folder}/rarefied_picrust2"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"

input_table="${picrust2_folder}/pathway_abundance.qza"
out_folder="${picrust2_folder}/funtional_alpha_pathway"
mkdir -p "$out_folder"
log="${out_folder}/alpha_diversity_log.txt"

echo "‚úÖ Pathway Alpha Diversity start analysing..." | tee "$log"
echo "Ì†ΩÌ≥Å Output path: $out_folder" | tee -a "$log"

# ========= Step 1: Calculating diversity metrics for abundant pathways =========
metrics=("observed_features" "shannon" "pielou_e")

for metric in "${metrics[@]}"; do
  echo "‚û°Ô∏è Step 1: Calculate Alpha diversity metric: $metric" | tee -a "$log"

  qiime diversity alpha \
    --i-table "$input_table" \
    --p-metric "$metric" \
    --o-alpha-diversity "${out_folder}/pathway_${metric}_vector.qza"

  if [ $? -eq 0 ]; then
    echo "  ‚úÖ $metric calculated" | tee -a "$log"
  else
    echo "  ‚ùå $metric unsuccessfulÔºåskipping" | tee -a "$log"
    continue
  fi

  # ========= Step 2: Alpha diversity significance =========
  echo "‚û°Ô∏è Step 2: Generate group significance analysis..." | tee -a "$log"

  qiime diversity alpha-group-significance \
    --i-alpha-diversity "${out_folder}/pathway_${metric}_vector.qza" \
    --m-metadata-file "$metadata_file" \
    --o-visualization "${out_folder}/pathway_${metric}_significance.qzv"

  if [ $? -eq 0 ]; then
    echo "  ‚úÖ $metric significance calculated" | tee -a "$log"
  else
    echo "  ‚ùå $metric significance analysis error" | tee -a "$log"
  fi
done

echo "Ì†ºÌæâ Pathway Alpha Diversity all doneÔºÅOutput directoryÔºö$out_folder" | tee -a "$log"


## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID