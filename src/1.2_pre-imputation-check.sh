#!/bin/bash

##################################################################################################################################
## 																																																															
## 	Script Name: 1.2_pre-imputation-check.sh																																										
## 	Description: This script checks files prior for imputation with the TOPMed reference panel ONLY. It is not for 1KG or HRC.  
## 	Authors: Jacqueline S. Dron <jdron@broadinstitute.org>																																			
## 	Date: 2024-02-12																																																						
## 	Version: 2.0																																																								
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
##			The file must be downloaded directly from the website: https://legacy.bravo.sph.umich.edu/freeze5/hg38/												
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
			# Convert the TOPMed .tab.gz to a .bed file for proper liftOver input format
			# NOTE THAT THIS WILL PRODUCE A VERY LARGE FILE! (>25GB)
		  zcat /medpop/esp2/jdron/projects/glgc/02_cohort_analysis/03_glgc_internal/data/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab.gz | awk 'NR==1 {print "CHROM","POS","ID","end"} NR>1 {print "chr"$1,$2,$2+1,$3}' | tail -n +2 > ../data/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.bed

			../tools/liftover/liftOver ../data/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.bed ../tools/liftoverhg38ToHg19.over.chain.gz ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.bed ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.failed.bed 

			rm ../data/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.bed # Remove this large file now that it is no longer needed

			# Generate TOPMed .tab.gz using the hg19 .bed that was just generated
			zcat ../data/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab.gz | \
					awk 'BEGIN { FS = OFS = "\t" }
					     # Process the first file (hg38.tab) to store IDs
					     NR == FNR { ids[$4] = $0; next }
					     # Process the second file (hg19.bed)
					     FNR == 1 { print "#CHROM", "POS", "ID", "REF", "ALT", "AC", "AN", "AF"; next }
					     # Check if the ID test_hg38.tab matches an ID in hg19.bed
					     $3 in ids { 
					         # Split the values from hg38.tab and assign them to corresponding fields
					         split(ids[$3], values, "\t");
					         $1 = values[1]; $2 = values[2]; $4 = $4; # Only update #CHROM and POS, keep REF unchanged
					         # Remove 'chr' prefix from #CHROM
					         gsub(/^chr/, "", $1);
					         print $0 
					     }' ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.bed - | gzip > ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.tab.gz

			rm ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.bed # Remove this large file now that it is no longer needed

			### With the (i) PLINK frequency files and the (ii) HRC-formatted TOPMed reference file, the tool can be run as follows	
			./tools/HRC-1000G-check-bim.pl -b ../data/${file_prefix}.bim -f ../data/${file_prefix}.frq -r ../data/PASS.Variants.TOPMed_freeze5_hg19_dbSNP.tab.gz -h -l ${geno_input} # This script produces a shell script called Run-plink.sh.

  # GRCh 38
	elif [[ ${build} -eq 38  ]]; then

		### With the (i) PLINK frequency files and the (ii) HRC-formatted TOPMed reference file, the tool can be run as follows	
			./tools/HRC-1000G-check-bim.pl -b ../data/${file_prefix}.bim -f ../data/${file_prefix}.frq -r ../data/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab.gz -h -l ${geno_input} ## This script produces a shell script called Run-plink.sh.

	fi