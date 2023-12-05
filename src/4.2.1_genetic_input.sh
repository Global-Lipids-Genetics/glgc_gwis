#!/bin/bash

##################################################################################################################################
## 																																
## 	Script Name: 4.2.1_genetic_input.sh																			
## 	Description: This script converts the merged, pruned, polymorphic imputed files into the BGEN format.				
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
## 			This script will produce BGENs from each chromosome VCF generated in 2.5_merging-imputation-batches.sh.					
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Example: 																														
## 			4.2.1_genetic_input.sh		 														
## 																																
##################################################################################################################################

# ------------------------------------- #
#  Starting script						
# ------------------------------------- #
for i in {1..22};
	do
		qctool -g ../results_tmp/chr${i}.imputed.poly.filtered.vcf.gz -vcf-genotype-field GP -og ../results_tmp/chr${i}.imputed.poly.filtered.merged.bgen 
		bgenix -index -clobber -g ../results_tmp/chr${i}.imputed.poly.filtered.merged.bgen 
	done
