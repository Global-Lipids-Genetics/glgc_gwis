#!/bin/bash

##################################################################################################################################
## 																																																															
## 	Script Name: 1.2_pre-imputation-check.sh																																										
## 	Description: This script checks files prior for imputation with the TOPMed reference panel ONLY. It is not for 1KG or HRC.  
## 	Authors: Jacqueline S. Dron <jdron@broadinstitute.org>																																			
## 	Date: 2023-05-03																																																						
## 	Version: 1.0																																																								
## 																																																															
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Usage:																																																											
## 			1.2_pre-imputation-check.sh A B 																																																
## 																																																															
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Input Parameters (* are required): 																																													
##			*A (Type: String) = Path to QC'd genotype files. Must be BED/BIM/FAM. Do NOT include the file extension. 								
##			*B (Type: Int) = Reference build for QC'd genotype data. Must be either '19' or '38'. 																	
## 																																																															
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Output: 																																																										
## 			This script will produce a shell script in the /src/ folder: ./Run-plink.sh  																						
## 																																																															
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Example: 																																																											
## 			1.2_pre-imputation-check.sh /path/to/my/QC/files 19  																													 					
## 																																																															
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	IMPORTANT NOTE: 																																																							
## 			The user MUST download the VCF version (GRCh38) of the TOPMed reference file prior to running this script. 							  
##			The file must be downloaded directly from the website: https://bravo.sph.umich.edu/freeze5/hg38/												
##			Please download the file to the ../data/ directory and do not change the file name.																			
## 																																																															
##################################################################################################################################

# ------------------------------------- #
#  Input parameters											
# ------------------------------------- #
geno_input=${1} # the path to the genotype files
build=${2} # the build of the genotype files
file_prefix=$(basename ${geno_input} | cut -d. -f1-10) # the prefix of the genotype files without the full path

# ------------------------------------- #
#  Starting script											
# ------------------------------------- #

### Download two tools to the /tools/ directory, unzip them both, and remove the original zipped file.
  # Tool: HRC-1000G-check-bim-v4.3.0
	wget --no-check-certificate https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip -P ../tools/
	unzip ../tools/HRC-1000G-check-bim-v4.3.0.zip -d ../tools/
	rm ../tools/HRC-1000G-check-bim-v4.3.0.zip
	rm ../tools/LICENSE.txt

  # Tool: CreateTOPMed
	wget --no-check-certificate https://www.well.ox.ac.uk/~wrayner/tools/CreateTOPMed.zip -P ../tools/
	unzip ../tools/CreateTOPMed.zip -d ../tools/
	rm ../tools/CreateTOPMed.zip
	rm ../tools/LICENSE.txt

### Generate frequency files for your genotypes
	plink --bfile ${geno_input} --freq --out ../data/${file_prefix}

### Convert the file downloaded from the Bravo website into an HRC-formatted reference legend. By default, this tool creates a file filtered for variants flagged as PASS only. 
	../tools/CreateTOPMed.pl -i ../data/ALL.TOPMed_freeze5_hg38_dbSNP.vcf.gz # The output file is PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab.gz
	mv ./PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab.gz ../data/

### If the QC'd genotype data are in build hg19/GRCh37, the Bravo-downloaded file will need to be lifted over to buld GRCh38
  # hg19
	if [[ ${build} -eq 19 ]]; then

		### If you do not have your own pipeline for variant liftover, you can download the liftOver tool and appropriate chain file
		mkdir ../tools/liftover
		  
		  # Tool: liftOver 	
		 	wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver -P ../tools/liftover 
		  
		  # File: hg38ToHg19.over.chain.gz
			wget https://hgdownload.cse.ucsc.edu/goldenpath/hg38/liftOver/hg38ToHg19.over.chain.gz -P ../tools/liftover 
			
		### Complete the GRCh38 to hg19 liftover
			../tools/liftover/liftOver PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab.gz ../tools/liftoverhg38ToHg19.over.chain.gz ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.bed ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.failed.bed 

			### With the (i) PLINK frequency files and the (ii) HRC-formatted TOPMed reference file, the tool can be run as follows	
			./tools/HRC-1000G-check-bim.pl -b ../data/${file_prefix}.bim -f ../data/${file_prefix}.frq -r ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.bed -h -l ${geno_input} # This script produces a shell script called Run-plink.sh.
  
  # GRCh 38
	elif [[ ${build} -eq 38  ]]; then

		### With the (i) PLINK frequency files and the (ii) HRC-formatted TOPMed reference file, the tool can be run as follows	
			./tools/HRC-1000G-check-bim.pl -b ../data/${file_prefix}.bim -f ../data/${file_prefix}.frq -r ../data/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab.gz -h -l ${geno_input} ## This script produces a shell script called Run-plink.sh.

	fi