## Convert VCF files to GDS files

library(SeqArray)

vcffile <- paste0("/path/to/vcf/chr", 1:22, "vcf.gz")
gdsfile <- paste0("/path/to/gds/chr", 1:22, ".gds")

for (i in 12:22){
  seqVCF2GDS(vcffile[i], gdsfile[i], verbose=T,parallel = 16)
}