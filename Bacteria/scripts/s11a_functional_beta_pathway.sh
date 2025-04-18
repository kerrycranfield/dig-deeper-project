#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

# PBS directives
#---------------

#PBS -N betaPathway
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


#!/bin/bash

# ========== Set file paths ==========
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
picrust2_folder="${results_folder}/rarefied_picrust2"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"

# Analysing PICRUSt2 pathway abundance output
input_table="${picrust2_folder}/pathway_abundance.qza"
prefix="pathway"
functional_out="${picrust2_folder}/functional_beta_${prefix}"
mkdir -p "$functional_out"
log="${functional_out}/beta_diversity_log.txt"

# metadata columns
columns=("Establishment" "Cutting" "Cattle" "Sheep" "Plough" "Year_group" "Age_group" "Age_binary" "pH_binary")

echo "‚úÖ Pathway Beta Diversity analysis..." | tee "$log"
echo "Ì†ΩÌ≥Å Output path: $functional_out" | tee -a "$log"

# ========== Step 1: Calculate Beta diversity metrics ==========
qiime diversity beta \
  --i-table "$input_table" \
  --p-metric braycurtis \
  --o-distance-matrix "${functional_out}/${prefix}_braycurtis.qza"
echo "‚û°Ô∏è  Step 1: Beta diversity distance matrix complete" | tee -a "$log"

# ========== Step 2: PCoA ==========
qiime diversity pcoa \
  --i-distance-matrix "${functional_out}/${prefix}_braycurtis.qza" \
  --o-pcoa "${functional_out}/${prefix}_pcoa.qza"
echo "‚û°Ô∏è  Step 2: PCoA analysis complete" | tee -a "$log"

# ========== Step 3: Emperor plot ==========
qiime emperor plot \
  --i-pcoa "${functional_out}/${prefix}_pcoa.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "${functional_out}/${prefix}_emperor.qzv"
echo "‚û°Ô∏è  Step 3: Emperor visualisation complete" | tee -a "$log"

# ========== Step 4: PERMANOVA significance testing ==========
echo "‚û°Ô∏è  Step 4: PERMANOVA significance testing..." | tee -a "$log"

for col in "${columns[@]}"; do
  echo "   ‚û§ Processing: $col" | tee -a "$log"

  if ! head -n 1 "$metadata_file" | grep -wq "$col"; then
    echo "     ‚ö†Ô∏è  '$col' column not present in metadata, skipping..." | tee -a "$log"
    continue
  fi

  qiime diversity beta-group-significance \
    --i-distance-matrix "${functional_out}/${prefix}_braycurtis.qza" \
    --m-metadata-file "$metadata_file" \
    --m-metadata-column "$col" \
    --p-method permanova \
    --p-permutations 999 \
    --o-visualization "${functional_out}/${prefix}_permanova_${col}.qzv"

  if [ $? -eq 0 ]; then
    echo "     ‚úÖ '$col' PERMANOVA complete" | tee -a "$log"
  else
    echo "     ‚ùå '$col' PERMANOVA error ‚ùó" | tee -a "$log"
  fi
done

echo "Ì†ºÌæâ Pathway Beta Diversity all doneÔºÅ Output directoryÔºö$functional_out" | tee -a "$log"

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID