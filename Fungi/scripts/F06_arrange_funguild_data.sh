# PYTHON - arrange_funguild_data
# Kerry Hathway, 11Apr2025
# Requires environment with Python3 

# PBS directives
#---------------

#PBS -N arrange_funguild_data_python
#PBS -l nodes=1:ncpus=4
#PBS -l walltime=00:30:00
#PBS -q half_hour
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

module load Python/3.11.3-GCCcore-12.3.0


# Start message
echo "Rearranging FUNGuild table for compatibility with QIIME2"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/kerry.hathway/soil_microbiome"
results_folder="${base_folder}/results"
data_folder="${base_folder}/data"

#Rearrange FUNGuild table before deduplication of data for use in QIIME2

python3 "${base_folder}/scripts/prepare_funguild_data.py"

# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
