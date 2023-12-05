#!/bin/bash

##################################################################################################################################
## 																																
## 	Script Name: 4.3.1_perform-GWIS_GEM.sh																						
## 	Description: This script runs GEM using the input variables as GEM-specific parameters.  						
## 	Authors: Jacqueline S. Dron <jdron@broadinstitute.org>																		
## 	Date: 2023-05-15																											
## 	Version: 1.0																												
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Usage:																													
## 			4.3.1_perform-GWIS_GEM.sh 	A 	B 	C 	D 	E 	F 	G 	H 	I 	J 	
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Input Parameters (* are required): 																							
##			*A (Type: String) = Indicator for imputation input. Must be one of the following:	 								
##									'BGEN' = .bgen input																		
##									'PGEN' = .pgen, .pvar, .psam input															
##									'BED'  = .bed, .bim, .fam																		
##			*B (Type: String) = Path to imputation files, including the file prefix. Do NOT include any file extensions. 		
##			*C (Type: String) = If 'BGEN' input does not contain sample identifiers, this is the path to the sample file, 		
##								including the file prefix and extension. If the sample file is not needed, set parameter as 'NA'.  																		
##			*D (Type: String) = Path to the phenotype file, including file prefix and extension. 								
##			*E (Type: String) = Delimiter of the phenotype file. Must be one of the following:									
##									'\t' = tab-delimited																		
##									'\0' = space-delimited																		
##									','  = comma-separated																		
##			*F (Type: String) = Variable name in the phenotype file that contains sample identifiers. Needs to match the IDs 	
##								used in the .bgen sample file, if provided.														
##			*G (Type: String) = Variable name in the phenotype file that contains the outcome of interest.						
##			*H (Type: String) = Variable name in the phenotype file that contains the exposure of interest.						
##			*I (Type: String) = List of covariates to be used in the model. Variable names must correspond to names used		
##								in the phneotype file. Put a single space between each listed variable.							
##								DO NOT INCLUDE THE EXPOSURE AS A COVARIATE or else an error will occur. GEM automatically		
##								includes the exposure as a covariate. 														
##			*J (Type: String) = The path and prefix for all of the GEM output files. 
##								Please use the naming convention detailed in Section 5.2 of the Analysis Plan. 	
##																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Output: 																													
## 			This script will produce a  ... 
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Example 1: 																														
## 			4.3.1_perform-GWIS_GEM.sh 'BGEN' /path/to/my/bgen/fileName /path/to/my/bgen/sample/fileName.tsv				
##					/path/to/my/phenotype/fileName.tsv '\t' 'sample_ID' 'LDLC' 'bmi' 'age age2 sex PC1 PC2 PC3 PC3 PC4'				
##					'HDLC_ALLFAST_BMI_All_TOT_adult'
## 	Example 2: 																														
## 			4.3.1_perform-GWIS_GEM.sh 'BGEN' /path/to/my/bgen/fileName NA /path/to/my/phenotype/fileName.csv ',' 'IID'
##					'LDLC' 'age' 'age2 sex PC1 PC2 PC3 PC3 PC4 PC5 PC6'	'LDLC_NONFAST_BMI_M_EAS_adult'
##
## 	Example 3: 																														
## 			4.3.1_perform-GWIS_GEM.sh 'PGEN' /path/to/my/pfile/fileName NA /path/to/my/phenotype/fileName.tsv '\t' 'ids'
##					'TG' 'age' 'age2 sex PC1' 'TG_FAST_AGE_All_EAS_adult'	
## 																																
##################################################################################################################################

# ------------------------------------- #
#  Input parameters											
# ------------------------------------- #
file_type=${1} # Type of imputation file
imputation_file=${2} # Path to imputation file
sample_file=${3} # If .bgen doesn't have a header block, this file must have the sample ID information. Troubleshooting here: https://large-scale-gxe-methods.github.io/GEMShowcaseWorkspace
pheno=${4} # Path to the phenotype file that includes information on outcomes, exposures, and covariates
delim=${5} # Delimiter separating values in the phenotype file
sampleID=${6} # Name of the variable/column header in the phenotype file that corresponds to the sample IDs
outcome=${7} # Name of the variable/column header in the phenotype file that corresponds to the outcome of interest
exposure=${8} # Name of the variable/column header in the phenotype file that corresponds to the exposure of interest
covariates=${9} # List of covariates
output_filename=${10} # Path and prefix for output files

# ------------------------------------- #
#  Starting script											
# ------------------------------------- #

output=../results_tmp/GEM/${outcome}/${exposure}/
mkdir -p ${output}

file_prefix=$(basename ${imputation_file} | cut -d. -f1-10)

for i in {1..22}; do

	if [[ ${file_type} = 'BGEN' ]] && [[ ${sample_file} = 'NA' ]]; then

## update this GEM path to the appropriate location/version
		../tools/GEM \
		   --bgen ${imputation_file}${i}.bgen \
		   --pheno-file ${pheno} \
		   --delim ${delim} \
		   --sampleid-name ${sampleID} \
		   --pheno-name ${outcome} \
		   --exposure-names ${exposure} \
		   --covar-names ${covariates}  \
		   --robust 1 \
		   --center 0 \
		   --scale 0 \
		   --threads 8 \
		   --out ${output}${output_filename}.chr${i} \
		   --output-style full 

## update this GEM path to the appropriate location/version
	elif [[ ${file_type} = 'BGEN' ]] && [[ ${sample_file} != 'NA' ]]; then

		../tools/GEM \
		   --bgen ${imputation_file}${i}.bgen \
		   --sample ${sample_file} \
		   --pheno-file ${pheno} \
		   --delim ${delim} \
		   --sampleid-name ${sampleID} \
		   --pheno-name ${outcome} \
		   --exposure-names ${exposure} \
		   --covar-names ${covariates}  \
		   --robust 1 \
		   --center 0 \
		   --scale 0 \
		   --threads 8 \
		   --out ${output}${output_filename}.chr${i} \
		   --output-style full 

## update this GEM path to the appropriate location/version
	elif [[ ${file_type} = 'BED' ]]; then

		../tools/GEM \
		   --bfile ${imputation_file}${i} \
		   --pheno-file ${pheno} \
		   --delim ${delim} \
		   --sampleid-name ${sampleID} \
		   --pheno-name ${outcome} \
		   --exposure-names ${exposure} \
		   --covar-names ${covariates}  \
		   --robust 1 \
		   --center 0 \
		   --scale 0 \
		   --threads 8 \
		   --out ${output}${output_filename}.chr${i} \
		   --output-style full 

## update this GEM path to the appropriate location/version
	elif [[ ${file_type} = 'PGEN' ]]; then

		../tools/GEM \
		   --pfile ${imputation_file}${i} \
		   --pheno-file ${pheno} \
		   --delim ${delim} \
		   --sampleid-name ${sampleID} \
		   --pheno-name ${outcome} \
		   --exposure-names ${exposure} \
		   --covar-names ${covariates}  \
		   --robust 1 \
		   --center 0 \
		   --scale 0 \
		   --threads 8 \
		   --out ${output}${output_filename}.chr${i} \
		   --output-style full 

	fi  	

done


## Merge GEM output if chromosome files are separate
for i in {1..22}; do

  results=${output}${output_filename}.chr${i}
  cat $results | sed '1d' >> ${output}${output_filename}.chrALL.GEM.out

done

output_final=../results_tmp/GEM/

cat ${output}${output_filename}.chrALL.GEM.out | gzip > ${output_final}${output_filename}.chrALL.GEM.out.gz

rm ${output}${output_filename}.chrALL.GEM.out