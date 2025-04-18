#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

# PBS directives
#---------------

#PBS -N ANCOM_family
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
echo "QIIME2: ANCOM"
date
echo ""





# 路径设置
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"
taxonomy_file="${results_folder}/s10_taxonomy.qza"
input_table="${results_folder}/s04_table_grouped_by_site.qza"
ancom_out="${results_folder}/family_ancom_results"

mkdir -p "$ancom_out"
log="${ancom_out}/ancom_log.txt"

# metadata columns for analysing differential abundance
columns=("Establishment" "Cutting" "Cattle" "Sheep" "Plough" "Year_group" "Age_group" "Age_binary" "pH_binary")

echo "✅ 开始按 Family 分组并运行 ANCOM..." | tee "$log"

# Step 1: collapse to Family level （Level 5）
echo "➡️ Collapsing to Family level..." | tee -a "$log"
qiime taxa collapse \
  --i-table "$input_table" \
  --i-taxonomy "$taxonomy_file" \
  --p-level 5 \
  --o-collapsed-table "${ancom_out}/family_table.qza"

# Step 2: Add pseudocount
echo "➡️ Adding pseudocount..." | tee -a "$log"
qiime composition add-pseudocount \
  --i-table "${ancom_out}/family_table.qza" \
  --o-composition-table "${ancom_out}/family_composition.qza"

# Step 3: Loop over metadata columns to run ANCOM
for col in "${columns[@]}"; do
  echo "   ➤ Process: $col" | tee -a "$log"
  
  if ! head -n 1 "$metadata_file" | grep -wq "$col"; then
    echo "     ⚠️  '$col' not present in metadata, skip" | tee -a "$log"
    continue
  fi

  qiime composition ancom \
    --i-table "${ancom_out}/family_composition.qza" \
    --m-metadata-file "$metadata_file" \
    --m-metadata-column "$col" \
    --o-visualization "${ancom_out}/family_ancom_${col}.qzv"

  if [ $? -eq 0 ]; then
    echo "     ✅ '$col' ANCOM complete" | tee -a "$log"
  else
    echo "     ❌ '$col' ANCOM failed. please check the metadata" | tee -a "$log"
  fi
done

echo "������ All Family-level ANCOM analysis completed, outputs in directory ：$ancom_out" | tee -a "$log"




echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID