#!/bin/bash
# QIIME2 - Phylogenetic tree
# shangda zhu March2025
# Requires environment with QIIME2
# Removing low frequency features, filtering and generating visualisations
# Generating phylogenetic tree 

# PBS directives
#---------------

#PBS -N preprocess_phylogenetic
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
echo "QIIME2: Pre-processing and phylogenetic tree"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results-2"

# 1️⃣ 过滤掉低丰度 ASVs（总丰度 < 10）
# Filter features/ASVs with a frequency of less than 10
qiime feature-table filter-features \
  --i-table "${results_folder}/s04_table_dada2.qza" \
  --p-min-frequency 10 \
  --o-filtered-table "${results_folder}/s04_filtered_table.qza"

# 2️⃣ 进一步过滤掉仅出现在 1 个样本的 ASVs（去单样本特异 ASVs）
# Feature must be in at least 2 samples to be retained - removes singletons
qiime feature-table filter-features \
  --i-table "${results_folder}/s04_filtered_table.qza" \
  --p-min-samples 2 \
  --o-filtered-table "${results_folder}/s04_filtered_table_no_singletons.qza"

# 生成可视化文件
# Summarise outputs for visualisation 
qiime feature-table summarize \
  --i-table "${results_folder}/s04_filtered_table_no_singletons.qza" \
  --o-visualization "${results_folder}/s04_filtered_table_no_singletons.qzv"

# 3️⃣ 同步过滤 `rep-seqs.qza` 以匹配新过滤的特征表
# Filtering out of the rep-sequences sequences that are not in the feature table
qiime feature-table filter-seqs \
  --i-data "${results_folder}/s04_rep_seqs_dada2.qza" \
  --i-table "${results_folder}/s04_filtered_table_no_singletons.qza" \
  --o-filtered-data "${results_folder}/s04_filtered_rep_seqs.qza"

# 生成可视化文件
# For visualisation
qiime feature-table tabulate-seqs \
  --i-data "${results_folder}/s04_filtered_rep_seqs.qza" \
  --o-visualization "${results_folder}/s04_filtered_rep_seqs.qzv"
  
# For visualisation  
qiime feature-table summarize \
  --i-table "${results_folder}/s04_filtered_table_no_singletons.qza" \
  --o-visualization "${results_folder}/s04_stats_filtered.qzv"

# Phylogenetic tree using the filtered rep sequences table
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences "${results_folder}/s04_filtered_rep_seqs.qza" \
  --p-n-threads 8 \
  --o-alignment "${results_folder}/s05_aligned_rep_seqs.qza" \
  --o-masked-alignment "${results_folder}/s05_masked_aligned_rep_seqs.qza" \
  --o-tree "${results_folder}/s05_unrooted_tree.qza" \
  --o-rooted-tree "${results_folder}/s05_rooted_tree.qza"

# --- Export tree data for plotting outside QIIME2 --- #
# Tree files can be used to plot trees in several online tree viewers.
# For example, tree.nwk file can be viewed using NCBI tree viewer
# https://www.ncbi.nlm.nih.gov/tools/treeviewer/

# Export tree as tree.nwk
qiime tools export \
  --input-path "${results_folder}/s05_rooted_tree.qza" \
  --output-path "${results_folder}/s05_phylogenetic_tree"

# Export masked alignment as aligned-dna-sequences.fasta which can be used by other viewers
qiime tools export \
  --input-path "${results_folder}/s05_masked_aligned_rep_seqs.qza" \
  --output-path "${results_folder}/s05_phylogenetic_tree"

# Completion message
echo ""
echo "Done"
date
