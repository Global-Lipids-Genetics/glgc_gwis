## Libraries
library(MAGEE)
library(parallel)
library(argparse)
library(gdsfmt)

parser <- ArgumentParser()
parser$add_argument("--path_to_nullmodel", type = "character", required = TRUE) # "/path/to/nullmodel/LDLC_ALLFAST_BMI_ALL_TOT_adult_case.glmmkin_nullmod.rds"
parser$add_argument("--path_to_genotype", type = "character", required = TRUE) # "/path/to/genotype/file.gds"
parser$add_argument("--outcome", type = "character", required = TRUE) # Outcome variable
parser$add_argument("--exposure", type = "character", required = TRUE) # Exposure (interaction) variables
parser$add_argument("--outfile", type = "character", required = TRUE) # "/path/to/output/"

## Parse arguments 
args <- parser$parse_args()

path_to_nullmodel <- args$path_to_nullmodel 

path_to_genotype <- args$path_to_genotype 

outcome <- args$outcome

exposure <- args$exposure

outfile <- args$outfile

print(paste("Null Model File Path: ", path_to_nullmodel))
print(paste("Genotype File Path: ", path_to_genotype))
print(paste("Outcome: ", outcome))
print(paste("Exposure: ", exposure))
print(paste("Output File Path: ", outfile))

## Null model
model0 <- readRDS(path_to_nullmodel)

## Imputed genotypes
geno.file <- path_to_genotype

## Exposure (interaction) variables
exposure <- exposure

## Output
outfile <- outfile

## Run MAGEE
glmm.gei(null.obj = model0, 
         interaction = exposure, 
         geno.file = geno.file, 
         outfile = outfile, 
         MAF.range = c(0.001,0.5), 
         meta.output = T,
         ncores = detectCores(), ## You can change the numbers based on computational resources
         center = F)

showfile.gds(closeall = T)