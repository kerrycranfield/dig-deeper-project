
#!/bin/bash
# Shangda.zhu April2025
# QIIME2 - Calculate multiple diversity metrics

# PBS directives
#---------------

#PBS -N diversitymetrics
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
echo "QIIME2: Calculate multiple diversity metrics"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
diversity_metrics_folder="${results_folder}/diversity_metrics_by_site"



# Calculate a whole bunch of diversity metrics
# Uses minimal non-chimeric reads from rarefied feature table
qiime diversity core-metrics-phylogenetic \
  --i-table "${results_folder}/s04_table_grouped_by_site.qza" \
  --i-phylogeny "${results_folder}/s05_rooted_tree.qza" \
  --p-sampling-depth 3529 \
  --m-metadata-file "${base_folder}/GP_site_metadata_cleaned.txt" \
  --output-dir "$diversity_metrics_folder"
echo " 分析完成！结果保存在：$diversity_metrics_folder"


# Export some results out of QIIME2 format to explore
# (these files can be used for analysis outside of QIIME2)

# Alpha-diversity metrics
qiime tools export \
  --input-path "${diversity_metrics_folder}/observed_features_vector.qza" \
  --output-path "${diversity_metrics_folder}/observed_features_vector"

qiime tools export \
  --input-path "${diversity_metrics_folder}/faith_pd_vector.qza" \
  --output-path "${diversity_metrics_folder}/faith_pd_vector"

qiime tools export \
  --input-path "${diversity_metrics_folder}/evenness_vector.qza" \
  --output-path "${diversity_metrics_folder}/evenness_vector"

qiime tools export \
  --input-path "${diversity_metrics_folder}/shannon_vector.qza" \
  --output-path "${diversity_metrics_folder}/shannon_vector"

# Beta-diversity metrics
qiime tools export \
  --input-path "${diversity_metrics_folder}/unweighted_unifrac_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/unweighted_unifrac_distance_matrix"

qiime tools export \
  --input-path "${diversity_metrics_folder}/weighted_unifrac_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/weighted_unifrac_distance_matrix"

qiime tools export \
  --input-path "${diversity_metrics_folder}/jaccard_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/jaccard_distance_matrix"

qiime tools export \
  --input-path "${diversity_metrics_folder}/bray_curtis_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/bray_curtis_distance_matrix"
  
# Generate alpha diversity boxplots and carry out significance tests
qiime diversity alpha-group-significance \
  --i-alpha-diversity "${diversity_metrics_folder}/faith_pd_vector.qza" \
  --m-metadata-file "GP_site_metadata_cleaned.txt" \
  --o-visualization "${results_folder}/s08_alpha_faith_pd_per_group.qzv"

qiime diversity alpha-group-significance \
  --i-alpha-diversity "${diversity_metrics_folder}/evenness_vector.qza" \
  --m-metadata-file "GP_site_metadata_cleaned.txt" \
  --o-visualization "${results_folder}/s08_alpha_evenness_per_group.qzv"

qiime diversity alpha-group-significance \
  --i-alpha-diversity "${diversity_metrics_folder}/shannon_vector.qza" \
  --m-metadata-file "GP_site_metadata_cleaned.txt" \
  --o-visualization "${results_folder}/s08_alpha_shannon_per_group.qzv"

# Beta diversity PCoA plot
# Uses the weighted unifrac distances (custom-axes parameter can be used to specific any column from your metadata file)
qiime emperor plot \
--i-pcoa "${diversity_metrics_folder}/weighted_unifrac_pcoa_results.qza" \
--m-metadata-file "GP_site_metadata_cleaned.txt" \
--o-visualization "${results_folder}/s09_beta_weighted_unifrac_emperor_pcoa.qzv"

# Use the bray curtis distances (custom-axes parameter can be used to specific any column from your metadata file)
qiime emperor plot \
--i-pcoa "${diversity_metrics_folder}/bray_curtis_pcoa_results.qza" \
--m-metadata-file "GP_site_metadata_cleaned.txt" \
--o-visualization "${results_folder}/s09_beta_bray_curtis_emperor_pcoa.qzv"

# Completion message
echo ""
echo "Done"
date
