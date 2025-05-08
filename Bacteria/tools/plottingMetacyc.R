# Install once if not yet installed
# BiocManager::install("biomformat")

library(biomformat)
library(tidyverse)
library(ggplot2)
library(scales)

# ==== Set file paths ====
biom_file <- "C:/Users/administer/Desktop/rarefied_feature-table.biom"
mapping_file <- "C:/Users/administer/Desktop/metacyc_pathways_info.tsv"
metadata_file <- "C:/Users/administer/Desktop/GP_site_metadata_cleaned.txt"

# ==== Step 1: Read biom file ====
biom <- read_biom(biom_file)
table <- as.data.frame(as.matrix(biom_data(biom)))  # pathway × sample
table <- t(table)  # sample × pathway
table <- as.data.frame(table)
table$sample_id <- rownames(table)

# ==== Step 2: Read pathway annotation ====
map <- read.delim(mapping_file, header = FALSE, col.names = c("Pathway", "Description"))
pathway_name <- setNames(paste0(map$Description, " (", map$Pathway, ")"), map$Pathway)

# ==== Step 3: Read metadata ====
meta <- read.delim(metadata_file, sep = "\t", header = TRUE, check.names = FALSE)
colnames(meta)[colnames(meta) == "#SampleID"] <- "sample_id"

# ==== Step 4: Merge and filter common samples ====
common <- intersect(table$sample_id, meta$sample_id)
merged <- inner_join(
  table %>% filter(sample_id %in% common),
  meta %>% filter(sample_id %in% common),
  by = "sample_id"
)

# Step 5: Compute global top 10 pathways
numeric_table <- merged %>%
  select(-sample_id, -pH_binary, -Age_binary, -Establishment)

numeric_table[] <- lapply(numeric_table, as.numeric)

global_top <- colSums(numeric_table)
top10_ids <- names(sort(global_top, decreasing = TRUE)[1:10])

# ==== Step 6: Reshape to long format ====
df_long <- merged %>%
  select(all_of(top10_ids), sample_id, pH_binary, Age_binary, Establishment) %>%
  pivot_longer(cols = all_of(top10_ids), names_to = "Pathway", values_to = "Abundance") %>%
  mutate(Pathway = pathway_name[Pathway])

# ==== Step 7: Plotting function ====
plot_group <- function(df, group_col, out_file) {
  # Step 1: Aggregate data
  plot_df <- df %>%
    group_by(.data[[group_col]], Pathway) %>%
    summarise(Abundance = sum(Abundance), .groups = "drop") %>%
    group_by(.data[[group_col]]) %>%
    mutate(Percentage = Abundance / sum(Abundance) * 100)
  
  # Step 2: Save plotting data to CSV
  csv_out <- sub(".jpeg$", "_data.csv", out_file)
  write.csv(plot_df, file = csv_out, row.names = FALSE)
  
  # Step 3: Create plot
  p <- ggplot(plot_df, aes(x = .data[[group_col]], y = Percentage, fill = Pathway)) +
    geom_bar(stat = "identity", position = "stack") +
    scale_fill_manual(values = hue_pal()(10)) +
    theme_classic(base_size = 14) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    labs(
      title = paste("Top 10 Global MetaCyc Pathways by", group_col),
      x = group_col,
      y = "Relative Abundance (%)",
      fill = "Pathway"
    )
  
  # Step 4: Save plot
  ggsave(out_file, plot = p, width = 12, height = 8, dpi = 300)
  
  # Step 5: Console message
  message("Saved plot: ", out_file)
  message("Saved data: ", csv_out)
}

# ==== Step 8: Generate plots grouped by metadata ====
plot_group(df_long, "pH_binary", "top10_pathways_by_pH.jpeg")
plot_group(df_long, "Age_binary", "top10_pathways_by_Age.jpeg")
plot_group(df_long, "Establishment", "top10_pathways_by_Establishment.jpeg")
