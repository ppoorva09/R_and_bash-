### Task: draw a plot of number of genes per chromosome in human genomes.

## importing all the needed libraries
library(ggplot2)
library(dplyr)

getwd() #place the dataset in the working directory for ease of use.

Homo_gene <- read.csv("Homo_sapiens.gene_info.gz", sep="\t", header=TRUE)
glimpse(Homo_gene)

# to filter out rows the contains the ambiguous data in chromosome column
# Reference: https://stackoverflow.com/questions/22850026/filter-rows-which-contain-a-certain-string
filamb_data <- Homo_gene %>%
  filter(!grepl("\\|", chromosome) & chromosome != "-")
print(filamb_data)

# to find gene counts per chromosome
chrom_count <- filamb_data %>%
  count(chromosome)
# view(chrom_count)

# To ensure that the chromosomes are plotted in a specific order on the x-axis of the plot
chrom_count$chromosome <- factor(chrom_count$chromosome, 
                                               levels = c(as.character(1:22), "X", "Y", "MT", "Un"))
# view(chrom_count)

# plotting the desired bar plot
p <- ggplot(chrom_count, aes(x = chromosome, y = n)) +
  geom_bar(stat = "identity", fill = "gray40") +
  theme_classic() +
  labs(title = "Number of genes in each chromosome",
       x = "Chromosomes",
       y = "Gene count") +
  theme(plot.title = element_text(hjust = 0.5))
p

# Saving the plot output as pdf
ggsave("genes_in_each_chromosome.pdf", plot = p, device = "pdf")
