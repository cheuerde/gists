# Claas Heuer, 2015

## This shows how snooping in variable selection can generate
## substantial prediction accuracies even for random data.
## This has been called "best case scenario" in
## "A comparison of principal component regression and genomic REML for genomic prediction across populations" 
## Genetics Selection Evolution 2014, 46:60 

library(rrBLUP)
library(cpgen)

n=500
p=5000

# generate random data - there is no connection between X and y
X <- matrix(rnorm(n*p),n,p)
y <- rnorm(n)
A <- tcrossprod(X)
E <- eigen(A)
str(E)

id <- 1:n
ctrain<-sample(id,n/5*4,replace=FALSE)
ctest <- id[-ctrain]
y2 <- y
y2[ctest] <- NA
cors_train <- cor(E$vectors[ctrain,],y[ctrain])**2
cors_snoop <- cor(E$vectors,y)**2

# set "cors <- cors_train" to get the actual prediction accuracy (will be 0)
cors <- cors_snoop
#cors <- cors_train

# select a subset of the 100 most important pcs
pcs <- order(cors,decreasing=TRUE)[1:100]
beta <- solve(crossprod(E$vectors[ctrain,pcs]),crossprod(E$vectors[ctrain,pcs],y[ctrain]))
str(beta)

# predict test data
u <- E$vectors[ctest,pcs] %*% beta

# get prediction accuracy
cor(u,y[ctest])

# plot the range

pcs_ordered <- order(cors,decreasing=TRUE)
ns <- round(seq(1,length(cors), length = 200), digits=0)
cors_cv <- rep(as.numeric(NA), length(ns))

count = 1

for(i in ns) {
 
 print(i)
 u <- mixed.solve(y[ctrain], Z=E$vectors[ctrain,pcs_ordered[1:i]])$u
 
 cors_cv[count] <- cor(as.vector(E$vectors[ctest,pcs_ordered[1:i]] %c% u), y[ctest])
 count = count+1

}



plot(cors_cv ~ ns)


