#!/bin/bash
# FastQC & MultiQC
# Shangda Zhu, March2025
# Requires FastQC and MultiQC in environment

# PBS directives
#---------------

#PBS -N QC
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
# Load required modules
module load FastQC/0.11.9-Java-11
module load MultiQC/1.12-foss-2021b

# Optional: force headless Java mode just in case
export _JAVA_OPTIONS="-Djava.awt.headless=true"

# Start message
echo "FastQC & MultiQC"
date
echo ""

# Input/output directories
data_folder="/mnt/beegfs/project/Alexey_Larionov/IBIX-PRO-24/restreco_grassland/16S/01.RawData/"
results_folder="/mnt/beegfs/home/shangda.zhu/groupproject/fastqc_results/"
mkdir -p "${results_folder}"

# Loop through sample folders
for sample_folder in "${data_folder}"*/; do
    sample_name=$(basename "${sample_folder}")
    echo "Processing ${sample_name}..."
    echo "In folder: ${sample_folder}"

    cd "${sample_folder}" || continue

    # Find relevant FASTQ files (.fastq or .fastq.gz), excluding raw/extended
    fastq_files=$(find . -maxdepth 1 -type f \( \
        -name "*_1.fastq" -o -name "*_2.fastq" -o \
        -name "*_1.fastq.gz" -o -name "*_2.fastq.gz" \
        \) ! -name "*raw*" ! -name "*extended*")

    echo "Found files: $fastq_files"

    if [[ -n "$fastq_files" ]]; then
        sample_out="${results_folder}/${sample_name}"
        mkdir -p "${sample_out}"
        fastqc --noextract --nogroup --quiet $fastq_files -o "${sample_out}" && echo "FastQC done for ${sample_name}"
    else
        echo "No matching FASTQ files in ${sample_name}, skipping..."
    fi
done

# Run MultiQC to summarize all FastQC outputs
echo "Running MultiQC..."
multiqc "${results_folder}" -o "${results_folder}"

# Done!
echo "All done!"
date
## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
