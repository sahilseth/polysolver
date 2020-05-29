#!/bin/bash -l

GATK_dir=$1
bamfile=$2
sampleID=$3
jobspecmemory=$4
dbsnp=$5
reference=$6
interval_file=$7
outdir=$8


$JAVA_DIR/java -Xmx${jobspecmemory}g -jar ${GATK_dir}/GenomeAnalysisTK.jar \
	-T HaplotypeCaller \
	-R $reference \
	-I $bamfile \
	--max_alternate_alleles 3 \
	--dbsnp $dbsnp \
	--genotyping_mode DISCOVERY \
	--variant_index_type LINEAR \
	-ERC GVCF \
	--variant_index_parameter 128000 \
	--minPruning 2 \
	-stand_call_conf 30.0 \
	-stand_emit_conf 30.0 \
	-A DepthPerSampleHC \
	-A StrandBiasBySample \
	-pairHMM VECTOR_LOGLESS_CACHING \
	-o ${outdir}/${sampleID}.gvcf.gz \
	-L $interval_file
