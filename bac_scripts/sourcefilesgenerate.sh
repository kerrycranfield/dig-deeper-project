#!/bin/bash
# FastQC & MiltiQC
# Shangda Zhu, March2025
# Requires FastQC and MultiQC in environment

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
#!/bin/bash
data_folder="/mnt/beegfs/project/Alexey_Larionov/IBIX-PRO-24/restreco_grassland/16S/01.RawData/"
output_file="/mnt/beegfs/home/shangda.zhu/groupproject/source_files.txt"

# 写入正确的表头，确保用 TAB 分隔
printf "sample-id\tforward-absolute-filepath\treverse-absolute-filepath\n" > "$output_file"

# 遍历所有子文件夹
for sample_folder in "${data_folder}"*/; do
    # 获取样本名称（去掉路径）
    sample_name=$(basename "${sample_folder}")

    # 查找 *_1.fastq.gz 和 *_2.fastq.gz（排除 raw_1.fastq.gz）
    fwd_read=$(find "${sample_folder}" -type f -name "*_1.fastq.gz" ! -name "*raw*")
    rev_read=$(find "${sample_folder}" -type f -name "*_2.fastq.gz" ! -name "*raw*")

    # 确保找到的文件不为空
    if [[ -f "$fwd_read" && -f "$rev_read" ]]; then
        printf "%s\t%s\t%s\n" "$sample_name" "$fwd_read" "$rev_read" >> "$output_file"
    else
        echo "Warning: Missing paired-end files for $sample_name"
    fi
done
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
