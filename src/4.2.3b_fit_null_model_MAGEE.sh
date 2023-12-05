#!/bin/bash

##################################################################################################################################
## 																																
## 	Script Name: 4.2.3b_null_model_MAGEE.sh																						
## 	Description: This is a wrapper that simplifies the process of running an R script "4.2.4_fit_null_model_MAGEE.R" 
##               by providing the necessary command-line arguments. 				
## 	Authors: Yuxuan Wang <yxw@bu.edu>
## 	Date: 2023-11-01																											
## 	Version: 1.1																												
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Usage:																													
## 			4.2.3b_fit_null_model_MAGEE.sh 	A 	B 	C 	D 	E   F
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Input Parameters (* are required): 																							
##			*A (Type: String) = Path to the phenotype file, including file prefix and extension.  								
##			*B (Type: String) = Outcome. 
##			*C (Type: String) = Path to GRM. 	
##			*D (Type: String) = Exposure. 
##			*E (Type: String) = Covariates as a comma-separated list.
##			*F (Type: String) = Path to the output file, including file prefix and extension. 
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Example: 																														
## 			4.2.3b_fit_null_model_MAGEE.sh "/path/to/my/phenotype/fileName.csv" "LDLC" "/path/to/grm/mypcrel.Rdata" "age"
##			"sex,PC1,PC2,PC3,PC4,PC5" "/path/to/nullmodel/LDLC_ALLFAST_AGE_ALL_TOT_adult_case.glmmkin_nullmod.rds"
## 
##################################################################################################################################

# ------------------------------------- #
#  Input parameters						
# ------------------------------------- #

path_to_pheno=$1
outcome=$2
path_to_grm=$3
exposure=$4
covariates=$5
outfile=$6

# ------------------------------------- #
#  Starting script						
# ------------------------------------- #

Rscript ../helper/4.2.3b_fit_null_model_MAGEE.R \
--pheno_file $path_to_pheno \
--outcome $outcome \
--grm $path_to_grm \
--exposure $exposure \
--covariates $covariates \
--outfile $outfile


