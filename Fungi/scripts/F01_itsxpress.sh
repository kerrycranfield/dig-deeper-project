#!/bin/bash

#Script to trim and perform quality check
#Sam Brocklehurst

# Define directories
ITS_DIR="/home/sam/UniGroup/data/restreco_grassland/ITS"
INPUT_DIR="$ITS_DIR/01.RawData"
TRIMMED_DIR="$ITS_DIR/trimmed_reads"
FASTQC_DIR="$ITS_DIR/fastqc_reports"
MULTIQC_DIR="$ITS_DIR/multiqc_summary"

# Create output directories
mkdir -p "$TRIMMED_DIR" "$FASTQC_DIR" "$MULTIQC_DIR"

# Activate conda environment
source /home/sam/miniconda3/bin/activate itsxpressenv

# Loop through sample folders
for folder in "$INPUT_DIR"/GF*; do
  [ -d "$folder" ] || continue
  sample=$(basename "$folder")
  R1="$folder/${sample}.raw_1.fastq.gz"
  R2="$folder/${sample}.raw_2.fastq.gz"

  if [[ -f "$R1" && -f "$R2" ]]; then
    echo "Trimming $sample..."
    OUT1="$TRIMMED_DIR/${sample}_trimmed_1.fastq.gz"
    OUT2="$TRIMMED_DIR/${sample}_trimmed_2.fastq.gz"

    itsxpress --fastq "$R1" --fastq2 "$R2" \
      --region ITS1 --taxa Fungi --threads 32 --cluster_id 1.0 \
      --log "$TRIMMED_DIR/${sample}.log" \
      --outfile "$OUT1" --outfile2 "$OUT2"

    [[ -f "$OUT1" && -f "$OUT2" ]] && fastqc "$OUT1" "$OUT2" -o "$FASTQC_DIR"
  else
    echo "Skipping $sample (missing FASTQ files)"
  fi
done

# Run MultiQC
multiqc "$FASTQC_DIR" -o "$MULTIQC_DIR"

# Deactivate conda environment
conda deactivate

echo "Trimming and QC complete."