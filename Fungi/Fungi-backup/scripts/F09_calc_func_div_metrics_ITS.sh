#!/bin/bash
# Kerry Hathway 11Apr2025
# QIIME2 - Calculate multiple functional diversity metrics

# PBS directives
#---------------

#PBS -N functional_diversity_metrics
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
echo "QIIME2: Calculate multiple functional diversity metrics, alpha significance, beta diversity plots"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/kerry.hathway/soil_microbiome"
results_folder="${base_folder}/results/ITS"
diversity_metrics_folder="${results_folder}/func_diversity_metrics"
data_folder="${base_folder}/data/ITS"

# Calculate a whole bunch of diversity metrics 
# Select the sampling-depth as the minimal count of non-chimeric reads (see output of step 4)
qiime diversity core-metrics \
  --i-table "${results_folder}/feature_table.qza" \
  --p-sampling-depth 11000 \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --output-dir "${diversity_metrics_folder}"

# Export some results out of QIIME2 format to explore
# (these files can be used for analysis outside of QIIME2)

# Alpha-diversity metrics
qiime tools export \
  --input-path "${diversity_metrics_folder}/observed_features_vector.qza" \
  --output-path "${diversity_metrics_folder}/observed_features_vector_ITS"

qiime tools export \
  --input-path "${diversity_metrics_folder}/evenness_vector.qza" \
  --output-path "${diversity_metrics_folder}/evenness_vector_ITS"

qiime tools export \
  --input-path "${diversity_metrics_folder}/shannon_vector.qza" \
  --output-path "${diversity_metrics_folder}/shannon_vector_ITS"

# Beta-diversity metrics
qiime tools export \
  --input-path "${diversity_metrics_folder}/jaccard_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/jaccard_distance_matrix_ITS"

qiime tools export \
  --input-path "${diversity_metrics_folder}/bray_curtis_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/bray_curtis_distance_matrix_ITS"

# Generate alpha diversity boxplots and carry out significance tests
qiime diversity alpha-group-significance \
  --i-alpha-diversity "${diversity_metrics_folder}/evenness_vector.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --o-visualization "${results_folder}/alpha_evenness_ITS.qzv"

qiime diversity alpha-group-significance \
  --i-alpha-diversity "${diversity_metrics_folder}/shannon_vector.qza" \
  --m-metadata-file "${data_folder}/agg_metadata.txt" \
  --o-visualization "${results_folder}/alpha_shannon_ITS.qzv"


# Completion message
echo ""
echo "Done"
date
