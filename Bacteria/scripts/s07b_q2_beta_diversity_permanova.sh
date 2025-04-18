#!/bin/bash
# Shangda.zhu April2025
# QIIME2 - Calculate multiple diversity metrics

# PBS directives
#---------------

#PBS -N beta
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

# Stop at runtime errors
set -e
module load CONDA/qiime2-amplicon-2024.5


# Start message

# Stop at runtime errors
set -e

# Start message
echo "QIIME2: "
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
diversity_metrics_folder="${base_folder}/results/diversity_metrics_by_site"
permanova_folder="${diversity_metrics_folder}/permanova"

mkdir -p ${permanova_folder}
# 你已有的变量列表
for var in Establishment Cutting Plough Sheep Cattle Year_group Age_group Age_binary pH_binary
do
  # Bray-Curtis
  qiime diversity beta-group-significance \
    --i-distance-matrix "${diversity_metrics_folder}/bray_curtis_distance_matrix.qza" \
    --m-metadata-file "GP_site_metadata_cleaned.txt" \
    --m-metadata-column $var \
    --p-method permanova \
    --p-pairwise \
    --o-visualization "${permanova_folder}/bray_permanova_${var}.qzv"

  # Jaccard
  qiime diversity beta-group-significance \
    --i-distance-matrix "${diversity_metrics_folder}/jaccard_distance_matrix.qza" \
    --m-metadata-file "GP_site_metadata_cleaned.txt" \
    --m-metadata-column $var \
    --p-method permanova \
    --p-pairwise \
    --o-visualization "${permanova_folder}/jaccard_permanova_${var}.qzv"
done

# Completion message
echo ""
echo "Done"
date
