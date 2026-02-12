#!/usr/bin/env bash


# Install R
apt-get install -y libxml2-dev libcurl4-openssl-dev libssl-dev
apt-get install -y r-base

# Install required packages
Rscript -e "install.packages('gradeR')" 
Rscript -e "install.packages('stringr')" 
