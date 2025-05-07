# dig-deeper-project
Repository for Cranfield University's Applied Bioinformatics soil microbiome group project, studying soil communities in restored grassland

This project analyses 16S and ITS amplicon data obtained from soil samples to determine how ecosystem restoration affects microbial and fungal communities. This is a group project for Cranfield University's MSc in Applied Bioinformatics 2024/2025 with data from 330 soil samples supplied by the Restoring Resilient Ecosystems (RestREco) project.

The specific aim of this project is to evaluate how grassland site age, establishment method, management and pH affect the diversity, taxonomy and functions of bacterial and fungal communities during restoration. 

Within this, the study aims to identify the main functional, microbial and fungal groups present in grassland sites undergoing either natural regeneration or different management methods. Interactions between microbial and fungal communities have also been studied to determine if there are correlations between the abundance of different taxa, metabolic pathways and fungal guilds.

The repository includes:
- Scripts from the 16S and ITS analysis pipelines to process and analyse bacterial and fungal amplicon sequencing data
- R-markdown code to create an interactive report to display outputs from the project
- R scripts for analysis of bacterial and fungal correlations

## Scripts description: ITS

1. F01_itsxpress.sh – Trimming and Quality Control
•	Purpose: Trims adapters and low-quality bases from raw ITS amplicon sequences and performs quality assessment.
•	Tools: ITSxpress, FastQC, MultiQC.
2. F02_denoise.sh – Denoising, Taxonomic Assignment, and Aggregation
•	Purpose: Imports trimmed sequences into QIIME 2, denoises reads using DADA2, assigns taxonomy, and aggregates feature tables by site.
•	Tools: QIIME2, DADA2.
3. F03_metrics.sh – Diversity and Statistical Analysis
•	Purpose: Computes diversity metrics (alpha and beta diversity), performs statistical tests, and generates visualisations.
•	Tools: QIIME2.
4. F04_FUNGuild.sh – Functional Guild Classification
•	Purpose: Collapses feature tables at genus level and identifies ecological guilds using FUNGuild.
•	Tools: FUNGuild, QIIME2.
5. F05_FUNSearch.sh – Species-Level Guild Identification
•	Purpose: Performs species-level functional guild classification for detailed ecological insights.
•	Tools: FUNGuild, QIIME2.
6. F09_calc_func_div_metrics_ITS.sh - Functional diversity analysis
* Purpose: Compute alpha and beta diversity metrics at guild level, alpha statistical significance
* Tools: QIIME2
7. F10_func_ITS_permanova.sh - Statistical analysis
* Purpose: Perform statistical tests for functional beta diversity
* Tools: QIIME2

## Scripts description: 16S

1. S02_qc.sh - Quality control
• Purpose: Performs quality assessment of reads
• Tools: FastQC, MultiQC
2. S03_q2_import_and_trim.sh - Trimming and visualising quality profiles
• Purpose: Trim primer sequences and visualising quality profiles
• Tools: QIIME2, CutAdapt
3. S04_q2_denoise.sh - Denoising
* Purpose: Denoises and pairs trimmed sequences, generates ASV feature tables
* Tools: QIIME2, DADA2
4. S05_preprocess_to_tree.sh - Constructs phylogenetic tree and aligns sequences
* Purpose: Generates phylogenetic tree to be used in taxonomic assignment step
* Tools: MAFFT, QIIME2, FastTree
5. S06a_group_table_by_site.sh - Aggregates feature tables to site level
* Purpose: Groups features by site for downstream analysis
* Tools: QIIME2
6. S06b_q2_rarefaction_plot.sh - rarify feature tables
* Purpose: Generates plot to determine threshold for rarefaction/normalisation of samples
* Tools: QIIME2
7. S07a_q2_calculate_diversity_metrics.sh - Diversity metrics
* Purpose: Computes diversity metrics (alpha and beta diversity), performs statistical tests and generates visualisations
* Tools: QIIME2
8. S07b_q2_beta_diversity_permanova.sh - Statistical analysis
* Purpose: Perform statistical tests for beta diversity
* Tools: QIIME2
9. S08_q2_taxonomy_barplot.sh - Taxonomic assignment and generating barplots
* Purpose: Assign taxonomy and produce visualisations
* Tools: QIIME2
10. S09a_genus_ancom.sh, s09b_family_ancom.sh - Statistical analysis
* Purpose: Collapse taxonomy tables to family and genus levels and carry out differential abundance analyses
* Tools: QIIME2, ANCOM
11. S10_picrust2_pipeline.sh - Functional analysis
* Purpose: Predict prominent metabolic pathways
* Tools:  QIIME2, PICRUSt2
12. S10b_pathway_heatmap.sh - Produce heatmaps
* Purpose: Produce heatmaps of pathway abundances for each site across metadata variables
* Tools: QIIME2
13. S10c_pathway_ancom.sh - Pathway differential abundance
* Purpose: Identify pathways with abundance shifts across metadata groups
* Tools: QIIME2, ANCOM
14. S11b_functional_alpha_pathway, S11a_functional_beta_pathway.sh - Pathway diversity metrics
* Purpose: Compute diversity metrics (alpha and beta) for functional diversity, perform statistical tests
* Tools: QIIME2
