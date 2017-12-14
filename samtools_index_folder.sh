#!/bin/bash

# indexes all bams in current/working folder
# since I had an error in read_alignment that made the indexing not work...

for bam in *.bam
do
	echo "opened $bam"
	~/bin/samtools sort $bam > sorted_$bam
	echo "indexing sorted_$bam"
	~/bin/samtools index sorted_$bam
done
