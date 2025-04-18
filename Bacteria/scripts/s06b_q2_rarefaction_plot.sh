#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu March2025

# PBS directives
#---------------

#PBS -N rarefaction
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
module load CONDA/qiime2-amplicon-2024.2


# Start message
echo "QIIME2: Rarefaction plot"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"

# Alpha rarefaction
# Max-depth based on max non-chimeric reads in s04_stats_dada2.qzv
# Download csv from qiime2view to get exact numeric rarefaction thresholds
qiime diversity alpha-rarefaction \
--i-table "${results_folder}/s04_filtered_table_no_singletons.qza" \
--i-phylogeny "${results_folder}/s05_rooted_tree.qza" \
--p-max-depth 42946 \
--m-metadata-file "GP_metadata_fixed.txt" \
--o-visualization "${results_folder}/s06a_alpha_rarefaction.qzv" 

# Rarefaction
# Select the sampling-depth as the minimal count of non-chimeric reads (see output of step 4)
qiime feature-table rarefy \
--i-table "${results_folder}/s04_filtered_table_no_singletons.qza" \
--p-sampling-depth 9473 \
--o-rarefied-table "${results_folder}/s06b_rarefied_table.qza"


# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID