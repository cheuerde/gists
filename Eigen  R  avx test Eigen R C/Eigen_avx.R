# Claas Heuer, 2015

# set the directory where the files are stored
workDir <- "/home/test"
setwd(workDir)


library(pedigreemm)
library(Rcpp)

Sys.setenv("PKG_CXXFLAGS"=paste("-fopenmp -O2 -mavx"))
sourceCpp(paste(workDir,"/test.cpp",sep=""))
sourceCpp(paste(workDir,"/test2.cpp",sep=""))


