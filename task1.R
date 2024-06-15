### Task 1.1 
# Mapping of Symbol and Synonym to GeneId

## importing all the needed libraries
library(tidyverse)
library(dplyr)
library(data.table)

getwd() #place the dataset in the working directory for ease of use.

# the data being very large so using fread
file_path <- "Homo_sapiens.gene_info.gz"  
gene_info <- fread(file_path, sep = "\t", header = TRUE)
class(gene_info)

# As we are just interested in column 2, 3 and 5, So making a separate dataframe to work with.
# In order to combine synonymns with the symbol data, first we can expand to separate each gene name.
# processing for NA characters.
gene_expanded <- gene_info %>%
  select(GeneID = GeneID, Symbol = Symbol, Synonyms = Synonyms) %>%
  mutate(SynonymsList = str_split(Synonyms, "\\|")) %>%
  unnest(SynonymsList) %>%
  mutate(SynonymsList = if_else(SynonymsList == "", NA_character_, SynonymsList)) %>%
  drop_na(SynonymsList)
view(gene_expanded)

# Combining the symbols and synonyms with geneID into one data frame 
# and removing the duplicates created while expanding.
files_combined <- bind_rows(
  gene_expanded %>% select(GeneID, Symbol = SynonymsList),
  gene_expanded %>% select(GeneID, Symbol)
) %>%
  distinct(Symbol, .keep_all = TRUE)
view(files_combined)

# Converting two-column data frames to a list, 
# using the first column as name and the second column as value.
# https://stackoverflow.com/questions/19265172/converting-two-columns-of-a-data-frame-to-a-named-vector
symbol_to_geneid <- files_combined %>%
  select(Symbol, GeneID) %>%
  deframe()

### Task 1.2
# Reading the GMT Symbol file line by line and replace gene symbols with Entrez IDs, 
# also create another GMT Entrez file as output. 

## File paths
matrix_file <- "h.all.v2023.1.Hs.symbols.gmt"  
converted_file <- "h.all.v2023.1.Hs.entrez.gmt"

# input and output files
input_GMT <- file(matrix_file, "r")
output_GMT <- file(converted_file, "w")

# Processing each line and separate gene symbols with other two fields
while (length(line <- readLines(input_GMT, n = 1, warn = FALSE)) > 0) {
  fields <- str_split(line, "\t")[[1]]
  pathway_name <- fields[1]
  pathway_desc <- fields[2]
  gene_symbols <- fields[-c(1, 2)]
  
  # To map gene Symbols to Entrez_ID
  # Initialize an empty vector
  Entrez_id <- c()
  
  # Looping through each symbol in gene_symbol and using symbol_to_geneid 
  # to look up for the corresponding Entrez ID
  for (symbol in gene_symbols) {
    
    id <- symbol_to_geneid[[symbol]]
    
    # If the Entrez ID is found and not NA then add it to the Entrez_id vector
    if (!is.na(id)) {
      Entrez_id <- c(Entrez_id, id)
    }
  }
  
  # To concatinate the result in GMT format of the single string
  output_line <- paste(c(pathway_name, pathway_desc, Entrez_id), collapse = "\t")
  
  # Writing the result to the output GMT file
  writeLines(output_line, output_GMT)
}


# Closing the input and output files once they have been read and written
close(input_GMT)
close(output_GMT)

# the new output file can be obtained from the location using:
getwd()

