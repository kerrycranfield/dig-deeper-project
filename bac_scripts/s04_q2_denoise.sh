#!/bin/bash
# QIIME2 - Denoise
# shangda zhu March2025
# Requires environment with QIIME2 

# PBS directives
#---------------

#PBS -N denoise
#PBS -l nodes=1:ncpus=12
#PBS -l walltime=24:00:00
#PBS -q one_day
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
echo "QIIME2: Denoise"
date
echo ""


# Folders
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results-2"

# Denoise (default --p-n-reads-learn 1000000)
# Setting the number of threads to 4 for use on HPC
# --p-trunc-len values set after checking base quality in reads  
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs "${results_folder}/s03_pe_dmx_trim.qza" \
  --p-trunc-len-f 223 \
  --p-trunc-len-r 218 \
  --p-n-threads 4 \
  --o-table "${results_folder}/s04_table_dada2.qza" \
  --o-denoising-stats "${results_folder}/s04_stats_dada2.qza" \
  --o-representative-sequences "${results_folder}/s04_rep_seqs_dada2.qza" \
  --verbose



# Summarise feature table
qiime feature-table summarize \
--i-table "${results_folder}/s04_table_dada2.qza" \
--o-visualization "${results_folder}/s04_table_dada2.qzv"

# Visualise statistics
qiime metadata tabulate \
--m-input-file "${results_folder}/s04_stats_dada2.qza" \
--o-visualization "${results_folder}/s04_stats_dada2.qzv"

# Tabulate representative sequences
qiime feature-table tabulate-seqs \
--i-data "${results_folder}/s04_rep_seqs_dada2.qza" \
--o-visualization "${results_folder}/s04_rep_seqs_dada2.qzv"

# Completion message
echo ""
echo "Done"
date
## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
