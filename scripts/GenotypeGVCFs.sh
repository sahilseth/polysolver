#!/bin/bash -l

GATK_dir=$1
sample_list=$2
project_name=$3
jobspecmemory=$4
dbsnp=$5
reference=$6
outdir=$7


$JAVA_DIR/java -Xmx${jobspecmemory}g -jar ${GATK_dir}/GenomeAnalysisTK.jar \
   -R $reference \
   -T GenotypeGVCFs \
   --variant $sample_list \
   -o ${outdir}/${project_name}.vcf.gz \
   --dbsnp $dbsnp
