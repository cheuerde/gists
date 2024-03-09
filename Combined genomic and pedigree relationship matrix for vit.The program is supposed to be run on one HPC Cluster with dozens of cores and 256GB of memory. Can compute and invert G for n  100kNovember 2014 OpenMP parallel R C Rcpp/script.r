###############################################################
# Claas Heuer, November 2014
# R script to compute: G*= wG + (1-w)A22
# All the expensive operations are performed in
# the C++ program 'vit_ginv.cpp'
# We use OpenBlas, RcppEigen and Rcpp in C++.
# In R we need the packages: RcppEigen, Rcpp and pedigreemm
################################################################

# set the directory where the files are stored
workDir <- "/work_f1/suatt361/vit_11_11_2014"
setwd(workDir)

# if not done yet: install needed packages:
# install.packages('Rcpp')
# install.packages('RcppEigen')
# install.packages('pedigreemm')

library(pedigreemm)
library(Rcpp)

# the path to openblas
openblas_path = "${HOME}/opt/OpenBLAS"
# set compiler flags for inclusion of openblas
Sys.setenv("PKG_CFLAGS"=paste("-std=gnu99 -fopenmp -O2"," -I",openblas_path,"/include",sep=""))
Sys.setenv("PKG_CXXFLAGS"=paste("-fopenmp -O2"," -I",openblas_path,"/include",sep=""))
Sys.setenv("PKG_LIBS"=paste("-L",openblas_path,"/lib ","-lopenblas -llapack -lpthread -lgfortran",sep=""))
# compile the c++ program 'vit_ginv.cpp' and make it available in R
sourceCpp(paste(workDir,"/vit_ginv.cpp",sep=""))

# get ids from marker file
# note: this will fail if the ids contain characters such das 'DE'
M.ids <- as.character(as.numeric(system("cat ITERmgdatGA22sort4GRELappr.ALL.1312 | awk '{print substr($0,0,10)}' | more",intern=TRUE)))

# Allele frequencies
mafs <- read.table("allelefreq.txt")[,2]

# pedigree
widths <- c(8,8,8,1,4,1)

ped <- read.fwf("ped4geGA22sort4GRELappr.ALL.1312.s",widths=widths, stringsAsFactors=FALSE)
colnames(ped) <- c("id","sire","dam","genotyped","birthyear","sex")

# sires or dams with id 0 get NA

ped$sire[ped$sire==0] <- NA
ped$dam[ped$dam==0] <- NA

# sort pedigree from oldest to youngest.
# note: this function might be very slow but you
# can substitute the original 'pedigreemm' package 
# with a modified one. To install it do this:
#
# install.packages('devtools')
# library(devtools)
# install_github("cheuerde/pedigreemm", ref = "master", build_vignettes=FALSE)
# library(pedigreemm)
#
# 'editPed' is then very fast
PED <- editPed(label=ped$id,sire=ped$sire,dam=ped$dam)

# make pedigree object
PED <- pedigreemm::pedigree(label=PED$label,sire=PED$sire,dam=PED$dam)

# this gets the uper cholesky factorization of A, already with inbreeding 
# and stores it as a column major compressed sparse matrix

L <- as(t(relfactor(PED)),"dgCMatrix")


### prepare everything for the C++ - function Call


n_marker = length(mafs)  # get the number of markers f
skip = 23                # how many lines shall be skipped - markers start at postion 24 here
stop_at  = 30000        # how many individuals (=rows) shall be read from the geno-file
# this next line will get you the number of rows in the file = all individuals
# stop_at = as.numeric(system(paste("wc -l < ",workDir,"/ITERmgdatGA22sort4GRELappr.ALL.1312",sep=""),intern=TRUE)) 
weight = 0.9             # weighting for G*= wG + (1-w)A22
lambda = 0.01            # shrinkage parameter - G* will definately be singular, so in order to get an inverse
                         # we must do something. Here we do: G* = (1-lambda) G* + I_lambda


# we only need the genotyped individuals
# we previously stored their ids in 'M.ids'.
# 'L_genotyped' will be ordered as the marker matrix!
L_genotyped <- L[match(M.ids[1:stop_at],PED@label),]

gc()

# this is the call to our C++ function.
# It will compute G*= wG + (1-w)A22 and its inverse and write it to file.
# It returns the diagonal of G*inverse
ginv_diag <- vit_ginv(markerfileR = paste(workDir,"/ITERmgdatGA22sort4GRELappr.ALL.1312",sep=""),     # big marker file 
                      na_intR = 9,                  # coding for NA
                      n_markerR = n_marker,         # how many markers shall be read
                      skip_elementsR = skip,        # how many lines skipped until we reach markers
                      stop_atR = stop_at,           # how many individuals (=rows) shall be read
                      LR = L_genotyped,             # this is: L_2 (A22 = L_2 L_2')
                      mafsR = mafs[1:n_marker],     # allele frequency of counted allele
                      compute_mafsR = TRUE,         # shall the allele freqeuncies be estimated from data or taken from file?
                      weightR = weight,             # weighting for G*= wG + (1-w)A22
                      lambdaR = lambda,             # shrinkage of G*
                      save_pathR = workDir,         # in which folder shall G* and G*inv be saved?
                      add_A22R = TRUE,              # shall A22 be added or omitted
                      omp_threadsR = 16,            # number of threads to be used - parallel!
                      verboseR = TRUE)              # print progress to the screen


# read_binary() is a function included in 'vit_ginv.cpp'.
# it has the following form:
# read_binary(file,  # complete path to the file
#             rows,  # number of rows of the matrix stored in 'file'
#             cols)  # number of columns of the matrix stored in 'file'

G <- read_binary(paste(workDir,"/G.bin",sep=""),stop_at,stop_at)
Ginv <- read_binary(paste(workDir,"/Ginv.bin",sep=""),stop_at,stop_at)



