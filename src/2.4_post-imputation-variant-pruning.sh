#!/bin/bash

##################################################################################################################################
## 																																
## 	Script Name: 2.4_post-imputation-variant-pruning.sh																			
## 	Description: This script removes any monomorphic variants and only keeps polymophic variants. It will also remove 
##				 variants not meeting the R2 threshold of 0.3.  								
## 	Authors: Jacqueline S. Dron <jdron@broadinstitute.org>																		
## 	Date: 2023-05-03																											
## 	Version: 1.0																												
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Usage:																														
## 			2.4_post-imputation-variant-pruning.sh	 A 																			
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Input Parameters (* are required): 																							
##			*A (Type: String) = Directory path to imputation output.  																	
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Output: 																													
## 			This script will produce VCFs (one per chromosome) that only include polymorphic sites and have variants with an
##			R2 of greater than or equal to 0.3.								
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Example: 																														
## 			2.4_post-imputation-variant-pruning.sh /path/to/my/QC/files   														
## 																																
##################################################################################################################################

# ------------------------------------- #
#  Input parameters						
# ------------------------------------- #
imputation_path=${1} # path to output from imputation

# ------------------------------------- #
#  Starting script						
# ------------------------------------- #

for i in {1..22};
	do
		bcftools view -c 1:minor ${imputation_path}/chr${i}.dose.vcf.gz | bcftools filter -e 'INFO/R2<=0.3' -O z > ${imputation_path}/chr${i}.imputed.poly.filtered.vcf.gz
		tabix -p vcf ${imputation_path}/chr${i}.imputed.poly.filtered.vcf.gz
	done