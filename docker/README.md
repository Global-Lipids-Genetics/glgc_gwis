## The docker file for basic analysis for GLGC2024 meta-analysis

#### Docker example

Pull image

```docker pull skoyamamd/glgc```

Test GEM

```docker run skoyamamd/glgc GEM```

Test MAGEE

```docker run skoyamamd/glgc Rscript -e "library(MAGEE); sessionInfo()"```

#### Singularity example

Download image

```singularity pull glgc.sif docker://skoyamamd/glgc```

Test GEM

```singularity exec glgc.sif GEM```

Test MAGEE

```singularity exec glgc.sif Rscript -e "library(MAGEE); sessionInfo()"```

## Other available softwares

bcftools, bgzip/tabix, plink, plink2
