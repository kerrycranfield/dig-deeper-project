# Read Metadata and Funguild table
meta <- read.delim("agg_metadata.txt", check.names = FALSE)

#Calculate medians from the original pH and Age columns

pH_median <- median(as.numeric(meta$pH), na.rm = TRUE)
Age_median <- median(as.numeric(meta$Age), na.rm = TRUE)

df <- read.delim("funguild_input.guilds.txt", check.names = FALSE)

# Identify site columns
site_cols <- names(df)[3:(which(names(df) == "Taxon") - 1)]

# Extract Guild information between pipes (|...|)
df$Guild_Extracted <- str_extract(df$Guild, "\\|[^|]+\\|") %>%
                      str_replace_all("\\|", "") %>%
                      trimws()

# converts NA to Unassigned
df$Guild_Extracted[is.na(df$Guild_Extracted)] <- "Unassigned"

# Set factor level so "Unassigned" appears first (bottom of bar)
df$Guild_Extracted <- factor(df$Guild_Extracted, levels = c("Unassigned", sort(unique(df$Guild_Extracted[df$Guild_Extracted != "Unassigned"]))))

# Filter out rows without pipe-delimited guilds
df_filtered <- df %>% filter(!is.na(Guild_Extracted))

#######################################ALL######################################

# Restructure data for all Guilds including undefined ("-")
guild_data <- df %>%
  pivot_longer(cols = all_of(site_cols), names_to = "Site", values_to = "Abundance") %>%
  filter(Abundance > 0) %>%
  group_by(Site, Guild_Extracted) %>%
  summarise(Abundance = sum(Abundance), .groups = "drop")

# Define color palette for Unassigned
guild_colors <- c("Unassigned" = "gray70", scales::hue_pal()(length(levels(df$Guild_Extracted)) - 1))
names(guild_colors)[-1] <- levels(df$Guild_Extracted)[-1]  

# Plot unfiltered guilds
guild_plot <- ggplot(guild_data, aes(x = Site, y = Abundance, fill = Guild_Extracted)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = guild_colors) +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(
    title = "Fungal Guild Abundance by Site",
    x = "Site",
    y = "Abundance",
    fill = "Guild"
  )

###################################FILTERED#####################################

# Restructure data for filtered guilds, excludes undefined
guild_data_filtered <- df_filtered %>%
  pivot_longer(cols = all_of(site_cols), names_to = "Site", values_to = "Abundance") %>%
  filter(Abundance > 0) %>%
  group_by(Site, Guild_Extracted) %>%
  summarise(Abundance = sum(Abundance), .groups = "drop")



# Plot filtered guilds
guild_plot_filtered <- ggplot(guild_data_filtered, aes(x = Site, y = Abundance, fill = Guild_Extracted)) +
  geom_bar(stat = "identity") +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(
    title = "Fungal Guild Abundance by Site Filtered",
    x = "Site",
    y = "Abundance",
    fill = "Guild"
  )

##################################PH###########################################

# Restructure data for pH, excludes undefined
guild_pH_data <- df_filtered %>%
  pivot_longer(cols = all_of(site_cols), names_to = "sample-id", values_to = "Abundance") %>%
  filter(Abundance > 0) %>%
  left_join(meta[, c("sample-id", "pH_category")], by = "sample-id") %>%
  group_by(pH_category, Guild_Extracted) %>%
  summarise(Abundance = sum(Abundance), .groups = "drop")

# Plot guild abundance aggregated by pH category
guild_pH_plot <- ggplot(guild_pH_data, aes(x = pH_category, y = Abundance, fill = Guild_Extracted)) +
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(title = paste("Fungal Guild Abundance by pH Category (Median pH =", round(pH_median, 2), ")"),
       x = "pH Category",
       y = "Abundance",
       fill = "Guild")

#####################################AGE########################################

# Restructure data for Age, excludes undefined
guild_Age_data <- df_filtered %>%
  pivot_longer(cols = all_of(site_cols), names_to = "sample-id", values_to = "Abundance") %>%
  filter(Abundance > 0) %>%
  left_join(meta[, c("sample-id", "Age_category")], by = "sample-id") %>%
  group_by(Age_category, Guild_Extracted) %>%
  summarise(Abundance = sum(Abundance), .groups = "drop")

# Plot guild abundance aggregated by Age category
guild_Age_plot <- ggplot(guild_Age_data, aes(x = Age_category, y = Abundance, fill = Guild_Extracted)) +
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(title = paste("Fungal Guild Abundance by Age Category (Median Age =", round(Age_median, 2), ")"),
       x = "Age Category",
       y = "Abundance",
       fill = "Guild")

###############################ESTABLISHMENT####################################

# Restructure data for Establishment, excludes undefined
guild_Establishment_data <- df_filtered %>%
  pivot_longer(cols = all_of(site_cols), names_to = "sample-id", values_to = "Abundance") %>%
  filter(Abundance > 0) %>%
  left_join(meta[, c("sample-id", "Establishment")], by = "sample-id") %>%
  group_by(Establishment, Guild_Extracted) %>%
  summarise(Abundance = sum(Abundance), .groups = "drop")

# Plot guild abundance aggregated by Establishment category
guild_Establishment_plot <- ggplot(guild_Establishment_data, aes(x = Establishment, y = Abundance, fill = Guild_Extracted)) +
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(title = "Fungal Guild Abundance by Establishment",
       x = "Establishment",
       y = "Abundance",
       fill = "Guild")


# Save plots as JPEGs
ggsave("guild_abundance_all.jpeg", plot = guild_plot, width = 20, height = 10, dpi = 300)
ggsave("guild_abundance_all_filtered.jpeg", plot = guild_plot_filtered, width = 20, height = 10, dpi = 300)
ggsave("guild_abundance_by_Age_category.jpeg", plot = guild_Age_plot, width = 12, height = 8, dpi = 300)
ggsave("guild_abundance_by_pH_category.jpeg", plot = guild_pH_plot, width = 12, height = 8, dpi = 300)
ggsave("guild_abundance_by_Establishment.jpeg", plot = guild_Establishment_plot, width = 12, height = 8, dpi = 300)