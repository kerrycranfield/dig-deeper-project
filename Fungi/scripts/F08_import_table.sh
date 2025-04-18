# QIIME2 - import_feature_table
# Kerry Hathway, 11Apr2025
# Requires environment with QIIME2 

# PBS directives
#---------------

#PBS -N import_feature_table
#PBS -l nodes=1:ncpus=4
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

module load CONDA/qiime2-amplicon-2024.5

# Start message
echo "QIIME2: import converted feature table"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/kerry.hathway/soil_microbiome"
results_folder="${base_folder}/results"
data_folder="${base_folder}/data/ITS"

biom convert \
-i "${data_folder}/guilds_feature_dedupe.tsv" \
-o "${data_folder}/guilds_feature.biom" \
--table-type="OTU table" \
--to-hdf5

qiime tools import \
--input-path "${data_folder}/guilds_feature.biom" \
--output-path "${results_folder}/feature_table.qza" \
--input-format BIOMV210Format \
--type "FeatureTable[Frequency]"


# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
