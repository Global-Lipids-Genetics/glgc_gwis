#!/bin/bash

##################################################################################################################################
## 																																
## 	Script Name: 4.3.2_perform-GWIS_MAGEE.sh																						
## 	Description: This is a wrapper that simplifies the process of running 
##               the R script "4.3.2_perform-GWIS_MAGEE.R" by providing the necessary command-line arguments. 						
## 	Authors: Yuxuan Wang <yxw@bu.edu>
## 	Date: 2023-08-17																											
## 	Version: 1.1																												
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Usage:																													
## 			4.3.2_perform-GWIS_MAGEE.sh 	A 	B 	C 	D 	E
## 																																
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Input Parameters (* are required): 																							
##			*A (Type: String) = Path to null models													
##			*B (Type: String) = Path to genotype files (GDS format)
##			*C (Type: String) = Outcome variables (LDLC/HDLC/TG)
##			*D (Type: String) = Exposure (interaction) variables (AGE/BMI)
##			*E (Type: String) = The prefix for all of the MAGEE output files.	Please use the naming convention detailed in XXXXXX. 	
## ---------------------------------------------------------------------------------------------------------------------------- 
## 	Example: 																														
## 			4.3.2_perform-GWIS_MAGEE.sh "/path/to/nullmodel/LDLC_ALLFAST_BMI_ALL_TOT_adult_case.glmmkin_nullmod.rds"
##      "/path/to/genotype/" "LDLC"  "BMI" "LDLC_ALLFAST_BMI_ALL_TOT_adult_case"
##						
##################################################################################################################################

# ------------------------------------- #
#  Input parameters		                
# ------------------------------------- #

path_to_nullmodel=$1
path_to_genotype=$2
outcome=$3
exposure=$4
output_filename=$5

output=../results_tmp/MAGEE/${outcome}/${exposure}/
mkdir -p ${output}


# ------------------------------------- #
#  Starting script						
# ------------------------------------- #

for chr in {1..22}; do
    # Generate the specific input file path for each chromosome
    geno_file="${path_to_genotype}/chr${chr}.gds"
    outfile="${output}${output_filename}.chr${chr}.magee.out"

    # Call the R script for each chromosome-specific file
    Rscript ../helper/4.3.2_perform-GWIS_MAGEE.R \
        --path_to_nullmodel "$path_to_nullmodel" \
        --path_to_genotype "$geno_file" \
        --outcome "$outcome" \
        --exposure "$exposure" \
        --outfile "$outfile"
done



## Merge MAFEE output if chromosome files are separate
for chr in {1..22}; do

  results=${output}${output_filename}.chr${chr}.magee.out
  cat $results | sed '1d' >> ${output}${output_filename}.chrALL.MAGEE.out

done

output_final=../results_for_upload/MAGEE/
mkdir -p ${output_final}

gzip < "${output}${output_filename}.chrALL.MAGEE.out" > "${output_final}${output_filename}.chrALL.MAGEE.out.gz"
rm ${output}${output_filename}.chrALL.MAGEE.out

echo "Merged MAGEE output files successfully!"