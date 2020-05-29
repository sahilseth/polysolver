#!/bin/sh


if [ $# -ne 8 ]; then
    echo 1>&2 Usage: GATK_dir bam_list interval_file dbsnp_file reference project_name LD_file outdir
	echo "	-GATK_dir: path to the directory where the GATK jar file is located"
	echo "	-bam_list: path to a headless, tab-separated text file containing one sample ID and BAM filepath per line for each project sample"
	echo "	-interval_file: path to an interval list of capture sequencing regions for use with GATK commands"
	echo "	-dbsnp_file: path to a VCF file containing dbsnp IDs for dbsnp variants for use with GATK commands"
	echo "	-reference: path to the genome reference fasta file for use with GATK commands"
	echo "	-project_name: string handle used for naming output data files"
	echo "	-LD_file: path to interval file containing regions of linkage disequilibrium"
	echo "  -outdir: output directory"
    exit 127
fi


GATK_dir=$1
bam_list=$2
interval_file=$3
#interval_file=$PSHOME/data/purcell5k.chrPos.list
dbsnp_file=$4
reference=$5
project_name=$6
LD_file=$7
#LD_file=$PSHOME/data/excludeLD.txt
outdir=$8


#Run HaplotypeCaller (in serial)
echo -n -e "Running GATK HaplotypeCaller on input BAMs...\n"
bash $PSHOME/scripts/Call_HaplotypeCaller.sh $GATK_dir $bam_list 3 $interval_file $dbsnp_file $reference $outdir


#Genotype Samples
echo -n -e "Joint genotyping samples...\n"
cut -f 1 $bam_list | sed 's|$|.gvcf.gz|' | sed "s|^|${outdir}/|" > ${outdir}/sample_gvcfs.list
bash $PSHOME/scripts/GenotypeGVCFs.sh $GATK_dir ${outdir}/sample_gvcfs.list $project_name 10 $dbsnp_file $reference $outdir


#Combine with Training data
echo -n -e "Combining sample genotypes with training set genotypes...\n"
$VCFTOOLS_DIR/vcf-merge $PSHOME/data/Training_Set.purcell5k.recode.vcf.gz ${outdir}/${project_name}.vcf.gz | $TABIX_DIR/bgzip -c > \
	 ${outdir}/${project_name}_and_Training_Set.purcell5k.vcf.gz


#Make PLINK files for PCA
echo -n -e "Creating PLINK files for smartpca...\n"
bash $PSHOME/scripts/Make_Plink_Files.sh ${outdir}/${project_name}_and_Training_Set.purcell5k


#Run smartpca
echo -n -e "Running smartpca...\n"
bash $PSHOME/scripts/Run_PCA.sh $LD_file ${outdir} ${project_name}_and_Training_Set.purcell5k ${outdir}


#Adjust sample naming for R processing
sed -i 's|^.*:||' ${outdir}/${project_name}_and_Training_Set.purcell5k.pcaOut.evec.tsv
cut -f 1 $bam_list | sed '1iSample_ID' > ${outdir}/sample_ids.txt


#Infer ethnicities of project samples and visualize
echo -n -e "Inferring ethnicities of project samples...\n"
$R_DIR/Rscript $PSHOME/scripts/Infer_Ethnicity.R ${outdir}/${project_name}_and_Training_Set.purcell5k.pcaOut.evec.tsv $PSHOME/data/Race_Annotations.txt ${outdir}/sample_ids.txt ${project_name} ${outdir}
