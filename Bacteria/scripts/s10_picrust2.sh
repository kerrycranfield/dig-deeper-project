#!/bin/bash
# Minimal set of Crescent2 batch submission instructions 
# Shangda.zhu April2025

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
picrust2_folder="${results_folder}/rarefied_picrust2"
mkdir -p $picrust2_folder
qiime picrust2 full-pipeline \
  --i-table "${results_folder}/s06b_grouped_rarefied_table.qza" \
  --i-seq "${results_folder}/s04_filtered_rep_seqs.qza" \
  --p-threads 8 \
  --o-ko-metagenome "${picrust2_folder}/ko_metagenome.qza" \
  --o-ec-metagenome "${picrust2_folder}/ec_metagenome.qza" \
  --o-pathway-abundance "${picrust2_folder}/pathway_abundance.qza" \
  --verbose 
  
qiime feature-table relative-frequency \
  --i-table "${picrust2_folder}/pathway_abundance.qza" \
  --o-relative-frequency-table "${picrust2_folder}/relfreq_pathway.qza"

qiime feature-table relative-frequency \
  --i-table "${picrust2_folder}/ko_metagenome.qza" \
  --o-relative-frequency-table "${picrust2_folder}/relfreq_ko.qza"

qiime feature-table relative-frequency \
  --i-table "${picrust2_folder}/ec_metagenome.qza" \
  --o-relative-frequency-table "${picrust2_folder}/relfreq_ec.qza"



echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID