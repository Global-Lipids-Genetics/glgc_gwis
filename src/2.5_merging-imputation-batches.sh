#!/bin/bash

##################################################################################################################################
## 																																
## 	Script Name: 2.5_merging-imputation-batches.sh																			
## 	Description: This script merges your polymorphic-only, R2-filtered VCF files generated from the previous script.					
## 	Authors: Jacqueline S. Dron <jdron@broadinstitute.org>																		
## 	Date: 2023-05-27																											
## 	Version: 1.0																												
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Usage:																														
## 			2.5_merging-imputation-batches.sh 																			
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Input Parameters: None						
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Output: 																													
## 			This script will produce VCFs (one per chromosome) that are merged across imputation batches.					
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Example: 																														
## 			2.5_merging-imputation-batches.sh	 														
## 																																
##################################################################################################################################

# ------------------------------------- #
#  Starting script						
# ------------------------------------- #
for i in {1..22};
	do
		bcftools merge /path/to/batch1/chr${i}.imputed.poly.filtered.vcf.gz /path/to/batch2/chr${i}.imputed.poly.filtered.vcf.gz /path/to/batch3/chr${i}.imputed.poly.filtered.vcf.gz -Oz -o ../results_tmp/chr${i}.imputed.poly.filtered.vcf.gz 
	done



