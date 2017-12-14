#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N counting_seqs
#$ -e countsErr
#$ -o countsOut
#$ -q !nem
#$ -V

# Count number of reads in all FASTQ files in some directory

# Get working directory as first command line argument
if [[ "$1" != "" ]]
then
wd=$1
fi

if [[ "$1" == "" ]]
then
echo "no directory supplied, using current dir"
wd=$(pwd)
fi

echo "Searching inside $wd"

# for files demultiplexed without compression
#grep -c "@" $wd/*.fastq > $wd/counts.txt
#grep -c "@" $wd/*.fq >> $wd/counts.txt
# for files demultiplexed that are gzipped
zgrep -c "@" $wd/*.fq.gz > $wd/counts.txt
#zgrep -c "@" $wd/*.fastq.gz >> $wd/counts.txt
