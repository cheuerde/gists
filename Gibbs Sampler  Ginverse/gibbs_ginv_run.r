# Claas Heuer, September 2015

library(BGLR)

# get example data
data(wheat)
A <- wheat.A
Ainv <- solve(A)

y <- wheat.Y[,1]

# load the function
library(devtools)

# this is from devtools - the argument is the GIST ID
source_gist("c6aea0ea614ad29d3349")

# run a model
mod <- gibbs_ginv(y,Ainv)

# the same model using cpgen::clmm
mod2 <- clmm(y = y, Z = list(as(diag(length(y)),"dgCMatrix")), ginverse = list(Ainv))



