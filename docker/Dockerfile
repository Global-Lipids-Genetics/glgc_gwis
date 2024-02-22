# FROM ubuntu:22.04
FROM rocker/tidyverse:4.3.0
ENV DEBIAN_FRONTEND=noninteractive

# Install

RUN \
  apt update && \
  apt install -y \
  build-essential \
  python3-dev \
  python3-pip \
  cmake \
  git \
  vim \
  wget \
  curl \
  unzip \
  openjdk-8-jre-headless \
  libbz2-dev \
  liblzma-dev \
  zlib1g-dev \
  libfontconfig1-dev \
  libssl-dev \
  libxml2-dev \
  libcurl4-openssl-dev \
  bcftools

# Install R

ARG R_VERSION=4.2.3
ARG OS_IDENTIFIER=ubuntu-2204

RUN \
  wget https://cdn.posit.co/r/${OS_IDENTIFIER}/pkgs/r-${R_VERSION}_1_amd64.deb && \
  apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -f -y ./r-${R_VERSION}_1_amd64.deb && \
  ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \
  ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript && \
  ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R && \
  rm r-${R_VERSION}_1_amd64.deb && \
  rm -rf /var/lib/apt/lists/*

# Install htslib

WORKDIR /glgc/

RUN \
  wget https://github.com/samtools/htslib/releases/download/1.17/htslib-1.17.tar.bz2 && \
  tar -xf htslib-1.17.tar.bz2 && \
  cd htslib-1.17 && \
  ./configure --prefix=/local/ && \
  make && make install

# Install MAGEE

RUN Rscript -e 'install.packages("devtools", repos="http://cran.us.r-project.org")'
RUN Rscript -e 'install.packages("R.utils", repos="http://cran.us.r-project.org")'
RUN Rscript -e 'install.packages(c("devtools", "RcppArmadillo", "CompQuadForm", "doMC", "foreach", "Matrix", "GMMAT", "BiocManager", "testthat", "data.table"), repos = "https://cran.r-project.org/")'
RUN Rscript -e 'BiocManager::install(c("SeqArray", "SeqVarTools"))'
RUN Rscript -e 'devtools::install_github("https://github.com/large-scale-gxe-methods/MAGEE")'

# Install GEM

WORKDIR /glgc/GEM

RUN wget https://github.com/large-scale-gxe-methods/GEM/releases/download/v1.5.2/GEM_1.5.2_Intel && \
chmod 755 GEM_1.5.2_Intel && \
mv GEM_1.5.2_Intel /local/bin/GEM

# Install PLINK1.9/PLINK2.0

WORKDIR /glgc/plink

RUN wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20230116.zip && \
  unzip plink_linux_x86_64_20230116.zip && \
  chmod 755 plink && \
  mv plink /local/bin

RUN wget https://s3.amazonaws.com/plink2-assets/alpha5/plink2_linux_avx2_20240105.zip && \
  unzip plink2_linux_avx2_20240105.zip && \
  chmod 755 plink2 && \
  mv plink2 /local/bin

# Install QCtool

WORKDIR /glgc/qctool

RUN \
  wget https://code.enkre.net/qctool/zip/release/qctool.tgz && \
  unzip qctool.tgz && \
  cd qctool && \
  python3 ./waf configure --prefix=/local && \
  python3 ./waf && \
  python3 ./waf install

RUN \
  ln -n /local/bin/qctool_v2.2.0 /local/bin/qctool

# Install bgenix (require gcc-9/g++-9)

WORKDIR /glgc/bgenix

RUN apt update && \
  apt install software-properties-common -y && \
  add-apt-repository ppa:ubuntu-toolchain-r/ppa -y  && \
  apt install gcc-9 g++-9 -y


RUN wget http://code.enkre.net/bgen/tarball/release/bgen.tgz && \
  tar -xf bgen.tgz

WORKDIR /glgc/bgenix/bgen.tgz

RUN CC=gcc-9 CXX=g++-9 python3 ./waf configure --prefix=/local

RUN CC=gcc-9 CXX=g++-9 python3 ./waf

RUN CC=gcc-9 CXX=g++-9 python3 ./waf install

# Enviornment

ENV PATH=/local/bin/:${PATH}
WORKDIR /glgc/

