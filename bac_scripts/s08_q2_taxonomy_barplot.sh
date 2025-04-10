#!/bin/bash
# Shangda.zhu March2025
# QIIME2 - Taxonomy barplots

# PBS directives
#---------------

#PBS -N test
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
module load CONDA/qiime2-amplicon-2024.2

# Assumes that the resources folder contains the claccifier recommended by QIIME2 for 515F/806R 16S region. 
# The classifier was trained on Greengenes 13.8 99% OTUs ( see https://docs.qiime2.org/2022.8/data-resources/ )
# The classifier was downloaded once using the code like this: 
# cd "${resources_folder}"
# wget https://data.qiime2.org/2022.8/common/gg-13-8-99-515-806-nb-classifier.qza


# Start message
echo "QIIME2: Taxonomy barplot"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"

# Assign taxonomy to sequences
qiime feature-classifier classify-sklearn \
--i-classifier "${base_folder}/gg-13-8-99-515-806-nb-classifier.qza" \
--i-reads "${results_folder}/s04_filtered_rep_seqs.qza " \
--o-classification "${results_folder}/s10_taxonomy.qza"

# Show taxonimies assigned to each ASV
qiime metadata tabulate \
--m-input-file "${results_folder}/s10_taxonomy.qza" \
--o-visualization "${results_folder}/s10_taxonomy.qzv"

# Make taxonomy barplot
qiime taxa barplot \
--i-table "${results_folder}/s06b_rarefied_table.qza" \
--i-taxonomy "${results_folder}/s10_taxonomy.qza" \
--m-metadata-file "GP_metadata_fixed.txt" \
--o-visualization "${results_folder}/s10_taxa_bar_plot.qzv"

# Completion message
echo ""
echo "Done"
date
