#!/bin/bash

# In order to downdload the fasta file and and store it in a file we can use wget and  -O for saving the output in a file.
wget -O NC_000913.faa https://ftp.ncbi.nlm.nih.gov/genomes/archive/old_refseq/Bacteria/Escherichia_coli_K_12_substr__MG1655_uid57779/NC_000913.faa

# To count the number of sequences present in the file, using grep (number of headers starting with ">")
num_sequences=$(grep -c "^>" NC_000913.faa)
# grep is used to find specific text in a datafile, -c is used to count that specific text's occurances. 

# To calculate the total number of amino acids
total_amino_acids=$(grep -v "^>" NC_000913.faa | tr -d '\n' | wc -c)
# tr -d is used to delete characters and concatinates all the sequences in one continous line. further we count each amino acid present.

# To calculate the average length of proteins. bc is the math library -l help in division with float 
average_length=$(echo $total_amino_acids / $num_sequences| bc -l)

# Printing the result i.e the average length
printf "Average length of protein in this strain is = %.2f\n" $average_length

# Lastly removing the file for neatness
rm NC_000913.faa
