#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu March2025

# PBS directives
#---------------

#PBS -N picrust
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



# ========== Path Setup ==========
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
picrust2_folder="${results_folder}/picrust2"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"

# Output prefix
composition_table="$picrust2_folder/ko_top_composition.qza"

echo " Step 1: Adding pseudocount..."
qiime composition add-pseudocount \
  --i-table "$picrust2_folder/ko_top.qza" \
  --o-composition-table "$composition_table"

# Metadata columns to test as needed
declare -a columns=("Establishment" "Cutting" "Cattle" "Sheep" "Plough" "Year_group" "Age_group")

# Run ANCOM for each metadata column
echo " Step 2: Running ANCOM for each metadata column..."
for col in "${columns[@]}"; do
  echo "   Processing $col ..."
  qiime composition ancom \
    --i-table "$composition_table" \
    --m-metadata-file "$metadata_file" \
    --m-metadata-column "$col" \
    --o-visualization "$picrust2_folder/ko_ancom_${col}.qzv"
done

echo " All ANCOM analyses are complete! Results are saved in $picrust2_folder"


echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID