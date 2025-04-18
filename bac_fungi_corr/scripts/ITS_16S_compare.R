install.packages("psych")
install.packages("corrplot")
library(psych)
library(corrplot)

# Comparing taxa abundance between fungi and bacteria - at genus level as no family level for ITS
# Inputs: feature-table-genus.tsv (16S); feature-table.tsv (collapsed to genus) (ITS)
# NOTE: make sure you remove the '#' in front of the #OTU ID header and remove the final 
# 'taxonomy' column at the end of the file before running - this was done manually

ITS.taxa <- read.table("data2/fungi_results_by_site/feature-table.tsv", header = TRUE, sep = "\t")
bac.taxa <- read.table("data2/results_by_site_bac/feature-table-genus.tsv", header = TRUE, sep = "\t")

# Make sure site names are uniform between the two data sets
colnames(bac.taxa)[2] <- colnames(ITS.taxa)[2] 

# Transpose rows and columns - ITS
ITS.taxa.trans <- as.data.frame(t(ITS.taxa))
colnames(ITS.taxa.trans) <- ITS.taxa.trans[1,]
ITS.taxa.trans <- ITS.taxa.trans[-1,]

# Transpose rows and columns - 16S
bac.taxa.trans <- as.data.frame(t(bac.taxa))
colnames(bac.taxa.trans) <- bac.taxa.trans[1,]
bac.taxa.trans <- bac.taxa.trans[-1,]

# Convert values to numeric to undo character conversion from transpose step
ITS.taxa.trans[] <- lapply(ITS.taxa.trans, type.convert, as.is = TRUE)
bac.taxa.trans[] <- lapply(bac.taxa.trans, type.convert, as.is = TRUE)

# Taxa correlation
corr.taxa <- corr.test(x = bac.taxa.trans, y = ITS.taxa.trans, use = "pairwise", method="pearson")
cor.taxa.p <- as.data.frame(corr.taxa$p.adj)
cor.taxa.r <- as.data.frame(corr.taxa$r)


# Comparing functional abundance between fungi and bacteria
ITS.guilds <- read.table("data2/fungi_results_by_site/guilds_feature_dedupe.tsv", header=TRUE, sep="\t")
bac.pathway <- read.table("data2/results_by_site_bac/pathway.tsv", header=TRUE, sep="\t")

# Make sure site names are uniform between the two data sets
colnames(bac.pathway)[2] <- colnames(ITS.guilds)[2] 

# Transpose rows and columns - ITS
ITS.guilds.trans <- as.data.frame(t(ITS.guilds))
colnames(ITS.guilds.trans) <- ITS.guilds.trans[1,]
ITS.guilds.trans <- ITS.guilds.trans[-1,]

# Transpose rows and columns - 16S
bac.pathway.trans <- as.data.frame(t(bac.pathway))
colnames(bac.pathway.trans) <- bac.pathway.trans[1,]
bac.pathway.trans <- bac.pathway.trans[-1,]

# Convert values to numeric to undo character conversion from transpose step
ITS.guilds.trans[] <- lapply(ITS.guilds.trans, type.convert, as.is = TRUE)
bac.pathway.trans[] <- lapply(bac.pathway.trans, type.convert, as.is = TRUE)


# Function correlation
corr.func <- corr.test(x = ITS.guilds.trans, y = bac.pathway.trans, use = "pairwise", method="pearson")
corr.func
cor.func.r <- as.data.frame(corr.func$r)
cor.func.p <- as.data.frame(corr.func$p.adj)

# Save workspace
save.image(file="corr_workspace.RData")

library(dplyr)
library(tidyr)
library(tibble)
library(stringr)

# Filtering taxa to get most significant correlations
taxa.rows <- rownames_to_column(cor.taxa.r, var="Bacteria")
pivoted.taxa <- pivot_longer(taxa.rows, cols=!Bacteria, names_to = "Fungi", values_to = "r")

taxa.rows.p <- rownames_to_column(cor.taxa.p, var="Bacteria")
pivoted.taxa.p <- pivot_longer(taxa.rows.p, cols=!Bacteria, names_to = "Fungi", values_to = "padj")

merged.taxa <- merge(pivoted.taxa, pivoted.taxa.p)

# FOR ALL CORRELATIONS REGARDLESS OF COUNTS
# Remove rows where the bacteria and fungi are only identified to kingdom level or where fungi are unassigned
baconly.taxa <- merged.taxa %>% filter(!str_detect(Bacteria, "k__Archaea"))
baconly.taxa <- baconly.taxa %>% filter(!str_detect(Bacteria, "k__Bacteria;__"))
baconly.taxa <- baconly.taxa %>% filter(!str_detect(Bacteria, "k__Bacteria;p__;"))
baconly.taxa <- baconly.taxa %>% filter(!str_detect(Fungi, "k__Fungi;__"))
baconly.taxa <- baconly.taxa %>% filter(!str_detect(Fungi, "Unassigned"))

filtered.taxa <- filter(baconly.taxa, r <= -0.6 | r >= 0.7)
filtered.taxa <- filter(filtered.taxa, padj <= 1e-20)

filt.taxa.05 <- filter(baconly.taxa, padj <= 0.05)
filt.taxa.01 <- filter(baconly.taxa, padj <= 0.01)

# Filter out uninformative taxa
filtered.taxa <- filtered.taxa %>% filter(!str_detect(Bacteria, "k__Bacteria;p__Acidobacteria;__;"))

# Taxa with the highest r (1) and p-adjusted values (0)
highest.taxa <- filter(filtered.taxa, r == 1 & padj == 0)

# Remove taxa not classified to at least family level
highest.taxa.filtered <- highest.taxa %>% filter(!str_detect(Bacteria, ".f__;"))
highest.taxa.filtered <- highest.taxa.filtered %>% filter(!str_detect(Bacteria, "k__Bacteria;p__Actinobacteria;c__Thermoleophilia;__;__;__"))
highest.taxa.filtered <- highest.taxa.filtered %>% filter(!str_detect(Bacteria, "k__Bacteria;p__Chloroflexi;c__Anaerolineae;__;__;__"))
highest.taxa.filtered <- highest.taxa.filtered %>% filter(!str_detect(Bacteria, "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;__;__"))
highest.taxa.filtered <- highest.taxa.filtered %>% filter(!str_detect(Bacteria, "k__Bacteria;p__Proteobacteria;c__Alphaproteobacteria;o__Sphingomonadales;__;__"))
highest.taxa.filtered <- highest.taxa.filtered %>% filter(!str_detect(Fungi, "k__Fungi;p__Basidiomycota;__;"))
highest.taxa.filtered <- highest.taxa.filtered %>% filter(!str_detect(Fungi, "k__Fungi;p__Monoblepharomycota;__;"))

# As above filtering removes all correlations with negative r values, 
# a separate negative correlation table is created here
filtered.taxa.neg <- filter(baconly.taxa, r <= -0.4) # 189 negative correlations
filtered.taxa.neg <- filter(filtered.taxa.neg, padj <= 0.05) # reduced to 6 correlations

# NOTE: There more negative correlations than positive correlations but the negative ones are
# less significant

# Filtering functions to get most significant correlations

# Create and merge tables
func.rows.r <- rownames_to_column(cor.func.r, var="Guild")
pivoted.func.r <- pivot_longer(func.rows.r, cols=!Guild, names_to = "Pathway", values_to = "r")

func.rows.p <- rownames_to_column(cor.func.p, var="Guild")
pivoted.func.p <- pivot_longer(func.rows.p, cols=!Guild, names_to = "Pathway", values_to = "padj")

merged.func <- merge(pivoted.func.r, pivoted.func.p)

# These are to determine metrics ie. number of correlations with padj less than 0.05 etc
func.05 <- filter(merged.func, padj <= 0.05)
func.01 <- filter(merged.func, padj <= 0.01)
fun.unassigned <- func.01 %>% filter(!str_detect(Guild, "^-"))

# Filter out unassigned guilds
filtered.func <- merged.func %>% filter(!str_detect(Guild, "^-"))

filtered.func.sig <- filter(filtered.func, r <= -0.7 | r >= 0.7)
filtered.func.sig <- filter(filtered.func.sig, padj <= 0.05) # 42 significant correlations

# Key results tables

write.table(highest.taxa.filtered, "taxa_corr_pos.txt", sep="\t", row.names=FALSE)
write.table(filtered.taxa.neg, "taxa_corr_neg.txt", sep="\t", row.names=FALSE)
write.table(filtered.func.sig, "func_corr.txt", sep="\t", row.names=FALSE)

# FOR TAXA CORRELATIONS INVOLVING MOST ABUNDANT TAXA ONLY
# Filtering rerun to only include taxa with abundance above the median

# Get total counts for each bacterial taxa and fetch mean
bac.taxa$sumcounts <- rowSums(bac.taxa[,2:ncol(bac.taxa)])
mean.count <- mean(bac.taxa$sumcounts)

# Do the same for fungi
ITS.taxa$sumcounts <- rowSums(ITS.taxa[,2:ncol(ITS.taxa)])
mean.count.fungi <- mean(ITS.taxa$sumcounts)

# Filter bacteria taxa table to only include most abundant taxa with total counts above mean of 517
abundant.taxa <- filter(bac.taxa, sumcounts > mean.count)
abundant.taxa <- abundant.taxa %>% rename(Bacteria = OTU.ID)
diff.taxa <- filter(merged.taxa, Bacteria %in% abundant.taxa$Bacteria)

# Same for fungi - mean = 1138
abundant.mush <- filter(ITS.taxa, sumcounts > mean.count.fungi)
abundant.mush <- abundant.mush %>% rename(Fungi = OTU.ID)
diff.taxa <- filter(diff.taxa, Fungi %in% abundant.mush$Fungi)

# Remove taxa not identified to at least family level plus unassigned fungi
taxa.all <- diff.taxa %>% filter(!str_detect(Bacteria, "k__Archaea"))
taxa.all <- taxa.all %>% filter(!str_detect(Bacteria, "k__Bacteria;__"))
taxa.all <- taxa.all %>% filter(!str_detect(Bacteria,"k__Bacteria;p__;"))

taxa.all <- taxa.all %>% filter(!str_detect(Fungi, "k__Fungi;__"))
taxa.all <- taxa.all %>% filter(!str_detect(Fungi, "Unassigned"))

# Filter correlations by r value and p-adjusted value
filtered.taxa.all <- filter(taxa.all, r <= -0.6 | r >= 0.7)
filtered.taxa.all <- filter(filtered.taxa.all, padj <= 0.05)

write.table(filtered.taxa.all, "taxa_corr_abundant.txt", sep="\t", row.names=FALSE)

# FUNCTIONAL CORRELATION FOR MOST ABUNDANT PATHWAYS ONLY

# Get total counts for each bacterial pathway and fetch mean and median
bac.pathway$sumcounts <- rowSums(bac.pathway[,2:ncol(bac.pathway)])
mean.path.count <- mean(bac.pathway$sumcounts)

# Do the same for guilds
ITS.guilds$sumcounts <- rowSums(ITS.guilds[,2:ncol(ITS.guilds)])
mean.count.guilds <- mean(ITS.guilds$sumcounts)

# Filter pathway table to only include most abundant pathways with total counts above mean of 269507
abundant.func.bac <- filter(bac.pathway, sumcounts > mean.path.count)
abundant.func.bac <- abundant.func.bac %>% rename(Pathway = OTU.ID)
diff.func <- filter(merged.func, Pathway %in% abundant.func.bac$Pathway)

# Same for fungi - mean ~ 3945
abundant.guilds <- filter(ITS.guilds, sumcounts > mean.count.guilds)
abundant.guilds <- abundant.guilds %>% rename(Guild = OTU.ID)
diff.func <- filter(diff.func, Guild %in% abundant.guilds$Guild)

# Filter out unassigned guilds
diff.func <- diff.func %>% filter(!str_detect(Guild, "^-"))

# Filter correlations by r value and p-adjusted value
filtered.func.all <- filter(diff.func, r <= -0.6 | r >= 0.6)
filtered.func.all <- filter(filtered.func.all, padj <= 0.05)

write.table(filtered.func.all, "func_corr_abundant.txt", sep="\t", row.names=FALSE)
