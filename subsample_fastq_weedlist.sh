# Subsamples some other file (in this case population map)
# and keeps only entries that are among the subset of files

if [[ "$1" != "" ]]
then
wd=$1
fi

if [[ "$1" == "" ]]
then
echo "no directory supplied, using current dir"
wd=$(pwd)
fi

popmap=$2

### If you didn't run subsample_fastq first, uncomment out these lines
# get list of fastq files
#touch samples_subset.list
#ls -1 $wd/*.fq* >> samples_subset.list
#ls -1 $wd/*.fastq* >> samples_subset.list
###

echo "Subsampling list of fastqs in popmap"
while read fastq
do
	#grab name of file before the extension (fastq|fq|.fq.gz...)
	name=$(echo "$fastq" | cut -d '.' -f 2 | cut -d '/' -f 2)
	# search for name in supplied map, write
	echo "Searching for $name"
	grep $name $popmap >> popmap_subset.tsv
done < samples_subset.list
