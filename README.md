#tl;dr

*this includes minor variations from the code base of polysolver v4 (from the docker image)*

#### TABLE OF CONTENTS ####
1. Description
    1.1 POLYSOLVER
    1.2 POLYSOLVER-based mutation detection
    1.3	Annotation of mutations
2. Installation
3. Testing
    3.1 POLYSOLVER
    3.2 POLYSOLVER-based mutation detection
    3.3	Annotation of mutations
4. Running
    4.1 POLYSOLVER
    4.2 POLYSOLVER-based mutation detection
    4.3	Annotation of mutations

#### 1. Description ####

This software package consists of 3 main tools:

1.1 POLYSOLVER (POLYmorphic loci reSOLVER)

POLYSOLVER is a tool for HLA typing based on whole exome sequencing (WES) data and infers alleles for the three major MHC class I (HLA-A, -B, -C) genes.


Script: shell_call_hla_type

Input parameters:
	
	-bam: path to the BAM file to be used for HLA typing
	-race: ethnicity of the individual (Caucasian, Black, Asian or Unknown)
	-includeFreq: flag indicating whether population-level allele frequencies should be used as priors (0 or 1)
	-build: reference genome used in the BAM file (hg18 or hg19)
	-format: fastq format (STDFQ, ILMFQ, ILM1.8 or SLXFQ; see Novoalign documentation)
	-insertCalc: flag indicating whether empirical insert size distribution should be used in the model (0 or 1)
	-outDir: output directory

Output:

	winners.hla.txt: file containing the two inferred alleles for each of HLA-A, HLA-B and HLA-C
	  
	  
1.2 POLYSOLVER-based mutation detection

This tool detects mutations in HLA genes using POLYSOLVER-inferred HLA alleles as input.

Script: shell_call_hla_mutations_from_type

Input parameters:

	-normal_bam_hla: path to the normal BAM file
	-tumor_bam_hla: path to the tumor BAM file
	-hla: inferred HLA allele file from POLYSOLVER (winners.hla.txt or winners.hla.nofreq.txt)
	-build: reference genome used in the BAM file (hg18 or hg19)
	-format: fastq format (STDFQ, ILMFQ, ILM1.8 or SLXFQ; see Novoalign documentation)
	-outDir: output directory	  
	
Output:

	call_stats.$allele.out: Mutect output for each inferred allele in winners.hla.txt
	$allele.all.somatic.indels.vcf: Strelka output for each inferred allele in winners.hla.txt
	
1.3 Annotation of mutations

This tool annotates POLYSOLVER detected HLA mutations with gene compartment and amino acid change information.

Script: shell_annotate_hla_mutations

Input parameters:

	-indiv: individual ID, used as prefix for output files
	-dir: directory containing the raw call files (Mutect: call_stats*, Strelka: *all.somatic.indels.vcf). Also the output directory	
	
Output:

(a). Mutect
	$indiv.mutect.unfiltered.nonsyn.annotated -  list of all unfiltered mutations
	$indiv.mutect.filtered.nonsyn.annotated -  list of cleaned non-synonymous mutations
	$indiv.mutect.filtered.syn.annotated - list of cleaned synonymous changes
	$indiv.mutect.ambiguous.annotated - list of ambiguous calls. This will generally be empty (save for the header). It will be populated if the same mutation (ex. p.A319E) is found in two or more alleles in the individual, with the same allele fractions. In such cases one allele is randomly chosen and included in the .nonysn.annotated file while the complete list of alleles is listed in the .ambiguous.annotated file. If the ethnicity of the individual is known, an alternate method would be to pick the allele with the highest frequency.

(b). Strelka
	$indiv.mutect.unfiltered.nonsyn.annotated -  list of all unfiltered indels (as detected by Strelka)
	$indiv.strelka_indels.filtered.annotated - list of cleaned indels (as detected by Strelka)
	$indiv.strelka_indels.ambiguous.annotated - see description of $indiv.mutect.ambiguous.annotated in (a). above
	
	
#### 2. Installation ####

The POLYSOLVER suite of tools depends upon the following packages and utilities:


Samtools (http://samtools.sourceforge.net/)
GATK (https://www.broadinstitute.org/gatk/download)
Novoalign (http://www.novocraft.com/main/downloadpage.php)
Perl modules ((http://www.cpan.org/modules/INSTALL.html)
 - Math::BaseCalc
 - List::MoreUtils
 - List::Util
 - Parallel::ForkManager
 - POSIX
 - Dumpvalue
 - Data::Dumper
Bioperl (http://www.bioperl.org/wiki/Installing_BioPerl)
Mutect (http://www.broadinstitute.org/cancer/cga/mutect_download)
Strelka (https://sites.google.com/site/strelkasomaticvariantcaller/home/download)
 
Also make changes to the config.sh file to set up the following environmental variables

 -PSHOME: POLYSOLVER home directory
 -SAMTOOLS_DIR: directory containing the samtools executable
 -JAVA_DIR: directory containing the JAVA executable
 -NOVOALIGN_DIR: directory containing the Novoalign executables
 -GATK_DIR: directory containing the GATK jar files
 -MUTECT_DIR: directory containing the Mutect executable (for POLYSOLVER-based mutation detection only)
 -STRELKA_DIR: directory containing the Strelka  (for POLYSOLVER-based mutation detection only)

The following command should make the necessary changes prior to running the tools (assuming the tcsh shell):

source scripts/config.sh
  
 
#### 3. Testing ####

Your installation can be tested by running the following command from $PSHOME:

3.1 POLYSOLVER

scripts/shell_call_hla_type test/test.bam Unknown 1 hg19 STDFQ 0 test
 
If successful, the following command should not yield any differences:
 
diff test/winners.hla.txt test/orig.winners.hla.txt

3.2 POLYSOLVER-based mutation detection

scripts/shell_call_hla_mutations_from_type test/test.bam test/test.tumor.bam test/winners.hla.txt hg19 STDFQ test

If successful, the following command should not yield any differences:
 
diff test/call_stats.hla_b_39_01_01_02l.out test/orig.call_stats.hla_b_39_01_01_02l.out 

3.3 Annotation of mutations

scripts/shell_annotate_hla_mutations indiv test

If successful, the following command should not yield any differences:

diff test/indiv.mutect.filtered.nonsyn.annotated test/orig.indiv.mutect.filtered.nonsyn.annotated

#### 4. Running #####

The tools can be run using the following commands:

4.1 POLYSOLVER

$PSHOME/scripts/shell_call_hla_type </path/to/bam> <race> <includeFreq> <build> <format> <insertCalc> </path/to/output_directory>

example:

$PSHOME/scripts/shell_call_hla_type test/test.bam Unknown 1 hg19 STDFQ 0 test

4.2 POLYSOLVER-based mutation detection

$PSHOME/scripts/shell_call_hla_mutations_from_type </path/to/normal_bam> </path/to/tumor_bam> </path/to/winners.hla.txt> <build> <format> </path/to/output_directory>

example:

$PSHOME/scripts/shell_call_hla_mutations_from_type test/test.bam test/test.tumor.bam test/winners.hla.txt hg19 STDFQ test
 
4.3 Annotation of mutations

$PSHOME/scripts/shell_annotate_hla_mutations <prefix_to_use> </path/to/directory_with_mutation_detection_output>

example:

$PSHOME/scripts/shell_annotate_hla_mutations indiv test


