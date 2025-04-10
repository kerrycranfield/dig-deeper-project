#!/bin/bash
# QIIME2 - Phylogenetic tree
# shangda zhu 12Dec2024
# Requires environment with QIIME2 

# PBS directives
#---------------

#PBS -N taxabySite
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

# Start message
echo "QIIME2: texabysitebarplot"
date
echo ""

# Folders
# 文件路径
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"

# Assign taxonomy to sequences
qiime feature-classifier classify-sklearn \
    --i-classifier "${base_folder}/gg-13-8-99-515-806-nb-classifier.qza" \
    --i-reads "${results_folder}/s04_filtered_rep_seqs.qza" \
    --o-classification "${results_folder}/s10_taxonomy.qza"

# Show taxonimies assigned to each ASV
qiime metadata tabulate \
    --m-input-file "${results_folder}/s10_taxonomy.qza" \
    --o-visualization "${results_folder}/s10_taxonomy.qzv"

qiime taxa barplot \
    --i-table "${results_folder}/s06b_rarefied_table_grouped_by_site.qza" \
    --i-taxonomy "${results_folder}/s10_taxonomy.qza" \
    --m-metadata-file "${base_folder}/GP_site_metadata.txt" \
    --o-visualization "${results_folder}/s10_taxa_bar_plot_by_site.qzv"


# Completion message
echo ""
echo "Done"
date
