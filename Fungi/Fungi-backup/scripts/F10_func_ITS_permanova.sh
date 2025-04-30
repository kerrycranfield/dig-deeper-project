#!/bin/bash
# Kerry Hathway 11Apr2025
# QIIME2 - Beta diversity significance for functional data ITS

# PBS directives
#---------------

#PBS -N functional_diversity_significance
#PBS -l nodes=1:ncpus=12
#PBS -l walltime=01:00:00
#PBS -q one_hour
#PBS -m abe
#PBS -M kerry.hathway@cranfield.ac.uk

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
module load CONDA/qiime2-amplicon-2024.2

# Start message
echo "QIIME2: statistical analysis - beta diversity significance"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/kerry.hathway/soil_microbiome"
results_folder="${base_folder}/results/ITS"
diversity_metrics_folder="${results_folder}/func_diversity_metrics"
data_folder="${base_folder}/data/ITS"

# Beta-diversity significance using PERMANOVA (Jaccard)
qiime diversity beta-group-significance \
  --i-distance-matrix "${diversity_metrics_folder}/jaccard_distance_matrix.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --m-metadata-column Establishment \
  --p-pairwise \
  --o-visualization "${diversity_metrics_folder}/jaccard_significance_est_ITS"

qiime diversity beta-group-significance \
  --i-distance-matrix "${diversity_metrics_folder}/jaccard_distance_matrix.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --m-metadata-column pH_category \
  --p-pairwise \
  --o-visualization "${diversity_metrics_folder}/jaccard_significance_ph_ITS"

qiime diversity beta-group-significance \
  --i-distance-matrix "${diversity_metrics_folder}/jaccard_distance_matrix.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --m-metadata-column Age_category \
  --p-pairwise \
  --o-visualization "${diversity_metrics_folder}/jaccard_significance_age_ITS"

# Beta diversity significance using PERMANOVA (Bray-Curtis)
qiime diversity beta-group-significance \
  --i-distance-matrix "${diversity_metrics_folder}/bray_curtis_distance_matrix.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --m-metadata-column Establishment \
  --p-pairwise \
  --o-visualization "${diversity_metrics_folder}/bray_curtis_significance_est_ITS"

qiime diversity beta-group-significance \
  --i-distance-matrix "${diversity_metrics_folder}/bray_curtis_distance_matrix.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --m-metadata-column pH_category \
  --p-pairwise \
  --o-visualization "${diversity_metrics_folder}/bray_curtis_significance_ph_ITS"

qiime diversity beta-group-significance \
  --i-distance-matrix "${diversity_metrics_folder}/bray_curtis_distance_matrix.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --m-metadata-column Age_category \
  --p-pairwise \
  --o-visualization "${diversity_metrics_folder}/bray_curtis_significance_age_ITS"


# Completion message
echo ""
echo "Done"
date
