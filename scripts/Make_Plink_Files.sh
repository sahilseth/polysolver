#!/bin/bash -l

if [ $# -ne 1 ]
then
  echo "Require file output prefix."
  exit 1
fi

prefix=$1

date
echo "Starting $prefix ..."

#Create TPED, PED, and BED files from a VCF file

if [ ! -e ${prefix}.vcf.gz ]
then
  echo "Missing file ${prefix}.vcf.gz"
  exit 1
fi

if [ ! -e ${prefix}.tped ]
then
  $VCFTOOLS_DIR/vcftools --gzvcf ${prefix}.vcf.gz --plink-tped --max-alleles 2 --out ${prefix}
else
  echo "File already exists: ${prefix}.tped"
fi

date

if [ ! -e ${prefix}.ped ]
then
  $PLINK_DIR/plink --noweb --tfile ${prefix}  --recode --out ${prefix}
else
  echo "File already exists: ${prefix}.ped"
fi

date

if [ ! -e ${prefix}.bed ]
then
  $PLINK_DIR/plink --noweb --file ${prefix} --make-bed --out ${prefix}
else
  echo "File already exists: ${prefix}.bed"
fi

date
echo "done"
