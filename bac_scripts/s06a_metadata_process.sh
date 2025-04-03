#!/bin/bash
# Shangda.zhu March2025
# Aggregating feature data by site
# Processing of metadata

# PBS directives
#---------------

#PBS -N feature_table_by_site
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
module load QIIME2/2022.8

# Start message
echo "QIIME2 "
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results-2"

# Group by Site
# Metadata file altered using python script to include a sampleID column as first column
qiime feature-table group \
  --i-table "${results_folder}/s04_filtered_table_no_singletons.qza" \
  --m-metadata-file "${base_folder}/GP_metadata_fixed.txt" \
  --m-metadata-column Site \
  --p-mode median-ceiling \
  --p-axis sample \
  --o-grouped-table "${results_folder}/s04_table_grouped_by_site.qza"

# Summarize grouped table
# Metadata file 'collapsed' to reflect grouping of data by site
qiime feature-table summarize \
  --i-table "${results_folder}/s04_table_grouped_by_site.qza" \
  --o-visualization "${results_folder}/s04_table_grouped_by_site.qzv" \
  --m-sample-metadata-file "${base_folder}/GP_site_metadata.txt"



# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID