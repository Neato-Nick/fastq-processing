#!/bin/bash

##File initialization
# Does samples.txt map exist?
if [ ! -f "samples.txt" ]
then
	echo "samples.txt not found! Pipeline will not work."
	exit 1
fi


# samples count of the mapping file
samples_count=$(wc -l samples.txt | cut -d ' ' -f 1)
echo "Number of samples found: $samples_count"
# attempts below didn't work - turns out array jobs need integer parameters
#thread_handle="#$ -t 1-${samples_count}:1"
#thread_handle="-t 1-${samples_count}:1"
#mkdir bams
#mkdir sams

#echo $thread_handle

#$ -cwd
#$ -S /bin/bash
#$ -N alignSbf
#$ -e align1sbferr
#$ -o align1sbfout
#$ -q !gbs
# #$ -q !nem0
# #$ -l mem_free=10G
#$ -V
# #$ -h
# #$ -t 1-${samples_count}:1
# #"$thread_handle"
# #$ $thread_handle
#$ -t 1-97:1

i=$(expr $SGE_TASK_ID - 1)

## Align reads against a reference genome using BWA / Samtools

# http://bio-bwa.sourceforge.net/bwa.shtml
#BWA="~/bin/bwa-0.7.10/bwa"
BOWTIE="/home/bpp/carleson/bin/bowtie2"
SAMT="~/bin/samtools-1.6/samtools" #upgraded to Samtools 1.6

#carleson: Updated to 1.6 on 10/2
PATH=~/bin/samtools-1.6:$PATH
#echo $PATH
echo "Starting alignment job num $i+1"

#REF="/home/bpp/knausb/Grunwald_Lab/home/knausb/pinf_bwa/bwaref/pinf_super_contigs.fa"
#REF="ref/hop.fa"
#REF='bwaref/pinf_sc50.fasta'
#REF='bwaref/pinfsc50b.fa'
REF='Pcitr'

FILE=(`cat "samples.txt" `)
IFS=';' read -a arr <<< "${FILE[$i]}"
echo "system interpreting ${FILE[$i]}"
echo "Will align ${arr[0]} from file ${arr[1]}"

echo -n "Running on: "
hostname
echo "SGE job id: $JOB_ID"
time_before=$(date)
echo "Bowtie2 Started: $time_before"
#echo $time_before

#arr[0]='P17777us22A'
#arr[0]='P13626'


# Align reads with bwa.
#CMD="$BWA mem -M -R @RG'\t'ID:${arr[0]}'\t'SM:${arr[0]} $REF ${arr[1]} ${arr[2]} > sams/${arr[0]}.sam"
#CMD="$BWA mem -M -R @RG'\t'ID:${arr[0]}'\t'SM:${arr[0]} $REF P17777us22A.fastq.gz > sams/${arr[0]}.sam"
#CMD="$BWA mem -M -R @RG'\t'ID:${arr[0]}'\t'SM:${arr[0]} $REF ${arr[1]} > sams/${arr[0]}.sam"
CMD="$BOWTIE -x $REF -U ${arr[1]} -S "sams/${arr[0]}.sam" --rg-id "${arr[0]}" --rg "SM:${arr[0]}" --rg "PL:ILLUMINA" --rg "PI:150" -p 8 --very-sensitive"

echo $CMD
eval $CMD
time_after=$(date)
#echo $time_after
echo "BWA Finished: $time_after"
DIFF=$(diff <(echo "$time_before") <(echo "$time_after"))
#echo $DIFF
# Check if aligner ran at all
if [ "$DIFF" == "" ]
then
	echo "Alignment failed. Check BWA results and try again."
	exit 1
fi

# Echo samtools version info.
CMD="$SAMT --version"
#
eval $CMD

# view
# -b       output BAM
# -S       ignored (input format is auto-detected)
# -u       uncompressed BAM output (implies -b)

# sort
# -n         Sort by read name
# -o FILE  output file name [stdout]
# -O FORMAT  Write output as FORMAT ('sam'/'bam'/'cram')   (either -O or
# -T PREFIX  Write temporary files to PREFIX.nnnn.bam       -T is required)

# fillmd
# -u       uncompressed BAM output (for piping)

# Fix mate information and add the MD tag.
#
CMD="$SAMT view -bSu sams/${arr[0]}.sam | $SAMT sort -O bam -o bams/${arr[0]}_sorted.bam -T bams/${arr[0]}_sort_tmp"
#
date=$(date)
echo "started sorting at $date"
echo $CMD
eval $CMD
date=$(date)
echo "finished sorting at $date"

#
#CMD="$SAMT fixmate -O bam bams/${arr[0]}_nsort /dev/stdout | $SAMT sort -O bam -o - -T bams/${arr[0]}_csort_tmp | $SAMT fillmd -u - $REF > bams/${arr[0]}_fixed.bam"
#
#echo $CMD
#
#eval $CMD

date=$(date)
CMD="$SAMT index bams/${arr[0]}_sorted.bam"
echo "Indexing... started at $date"
echo $CMD
eval $CMD
date=$(date)
echo "Indexing finished at $date"

echo "Samtools finished"

date=$(date)
echo "Finished all operations at $date"
