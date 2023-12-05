## This is to be run in an R environment
## It is showing an example of how to use GENESIS to create a GRM

## Libraries
library(SNPRelate)
library(GENESIS)
library(SeqArray)
library(SeqVarTools)

setwd("/path/to/gdsfiles") # EDIT path to working directory
gdsfile <- "your.genotype.gds" # EDIT the .gds filename


## LD pruning
gds <- seqOpen(gdsfile)
gds

# Samples
sample.id <- seqGetData(gds, 'sample.id')

snpset <- snpgdsLDpruning(gds, method="corr", slide.max.bp=10e6, ld.threshold=0.2, verbose=FALSE)
pruned <- unlist(snpset, use.names=FALSE)

## Initial estimates of kinship
king <- snpgdsIBDKING(gds, snp.id=pruned, verbose=T)
kingMat <- king$kinship
dimnames(kingMat) <- list(king$sample.id, king$sample.id)

## Run PC-AiR on pruned SNPs
pcs <- pcair(gds,
             kinobj=kingMat,
             divobj=kingMat,
             snp.include=pruned)

# Determine which PCs are ancestry informative
jpeg(file="pc1_vs_pc2.jpeg") # EDIT the output name if desired
plot(pcs) # plot top 2 PCs
dev.off()

jpeg(file="pc3_vs_pc4.jpeg") # EDIT the output name if desired
plot(pcs, vx = 3, vy = 4) # plot PCs 3 and 4
dev.off()

## Run PC-Relate
seqSetFilter(gds, variant.id=pruned)
iterator <- SeqVarBlockIterator(gds, variantBlock=20000, verbose=FALSE)
mypcrel <- pcrelate(iterator, pcs = pcs$vectors[,1:2],
                       training.set = pcs$unrels,
                       BPPARAM = BiocParallel::MulticoreParam(workers = 16))

showfile.gds(closeall=TRUE)
save(mypcrel,file = "/path/to/grm/mypcrel.Rdata") # EDIT the path to save the .Rdata file for this session. It is required for fitting the null model.
