#!/bin/sh

GATK_dir=$1
bam_list=$2
jobspecmemory=$3
interval_file=$4
dbsnp=$5
reference=$6
outdir=$7

while read a b
do
bamfile=$b
sampleID=$a
bash $PSHOME/scripts/HaplotypeCaller.sh $GATK_dir $bamfile $sampleID $jobspecmemory $dbsnp $reference $interval_file $outdir
done < $bam_list
