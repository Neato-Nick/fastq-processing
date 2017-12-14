# subsample a bunch of fastq files...
# retain only 1/$div_use files
# subsample $num_reads from each file
# output to new folder called subsampled_reads

if [[ "$1" != "" ]]
then
wd=$1
fi

if [[ "$1" == "" ]]
then
echo "no directory supplied, using current dir"
wd=$(pwd)
fi

# enter fraction of samples, where
# fraction is 1/$2. If $2=3, get 1/3 of samples
div_use=$2

echo "Subsampling fastqs in $wd"

# get list of fastq files
touch samples.list
ls -1 $wd/*.fq* >> samples.list
ls -1 $wd/*.fastq* >> samples.list

# first take a random selection of fastq files
# let's say half of the samples
echo "using 1/$div_use of all samples"
sample_tot=$(wc -l samples.list | cut -d ' ' -f 1)

# number of samples divided by denominator of fraction
sample_use=$(echo $((sample_tot / div_use)))
echo "Using $sample_use samples"

# get that number of files from our list
shuf samples.list | head -n $sample_use > samples_random.list

# write n reads to file from every sample on list
mkdir subsampled_reads
touch subsampled_reads/samples_subset.list
num_reads=75000
num_lines=$(echo $(($num_reads * 4)))

while read fastq
do
	echo "$fastq"
	#grab name of file before the extension (fastq|fq|.fq.gz...)
	name=$(echo "$fastq" | cut -d '.' -f 2)
	# write the first specified number of lines to file
	# didn't shuf because it shuffled up quadruplets in fastqs...
	# but IN THEORY sequences arrive in a random order anyway
	gunzip -c $fastq | head -n $num_lines > subsampled_reads/${name}_subset.fastq
	# grow list of subsampled reads by name rather than file name
	echo "${fastq}_subset" >> subsampled_reads/samples_subset.list
done < samples_random.list
