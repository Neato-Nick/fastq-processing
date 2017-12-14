# Prepare a reference genome for use

# Reference MUST END with ".fasta" (not ".fa" or ".txt") to work

# Input the reference name as command line argument
# Example: Pmult_genome27.fasta, you'd input: Pmult_genome27
ref_name=$1

# Create fasta reference
~/bin/samtools faidx ${1}.fasta

# Create dictionary
~/bin/javadir/jre1.8.0_144/bin/java -jar ~/bin/picard.jar CreateSequenceDictionary R=${1}.fasta O=${1}.dict
