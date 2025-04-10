#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu 12Dec2024

# PBS directives
#---------------

#PBS -N picrust
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
module load CONDA/qiime2-amplicon-2024.5


# Start message
echo "QIIME2: picrust2"
date
echo ""



# set folder
base_folder="/mnt/beegfs/home/shangda.zhu/groupproject"
results_folder="${base_folder}/results"
picrust2_folder="${results_folder}/picrust2"
metadata_file="${base_folder}/GP_site_metadata_cleaned.txt"



# ========== Step 2: Filter high-abundance KOs from the original KO table ==========

qiime feature-table filter-features \
  --i-table "${picrust2_folder}/ko_metagenome.qza" \
  --p-min-frequency 100000 \
  --p-min-samples 5 \
  --o-filtered-table "${picrust2_folder}/ko_top.qza"

# ========== Plot heatmap (grouped by Establishment) ==========


qiime feature-table heatmap \
  --i-table "${picrust2_folder}/ko_top.qza" \
  --m-sample-metadata-file "$metadata_file" \
  --m-sample-metadata-column Establishment \
  --o-visualization "${picrust2_folder}/ko_heatmap_by_establishment.qzv"


echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID