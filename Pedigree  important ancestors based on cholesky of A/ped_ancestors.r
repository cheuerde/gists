# Claas Heuer, July 2015
# adopted from: http://www.r-bloggers.com/setup-up-the-inverse-of-additive-relationship-matrix-in-r/


ped <- data.frame( id=c(  1,   2,   3,   4,   5,   6,   7,   8,   9,  10),
                  fid=c( NA,  NA,   2,   2,   4,   2,   5,   5,  NA,   8),
                  mid=c( NA,  NA,   1,  NA,   3,   3,   6,   6,  NA,   9))



library(package="pedigreemm")
 
ped2 <- with(ped, pedigree(sire=fid, dam=mid, label=id))
 
U <- relfactor(ped2)
A <- crossprod(U)

library(bdsmatrix)
tmp <- gchol(as.matrix(A))
D <- diag(tmp)
T <- as(as.matrix(tmp), "dtCMatrix")


# get A = TDT' (the inverse of it)
TInv <- as(ped2, "sparseMatrix")
DInv <- Diagonal(x=1/Dmat(ped2))

# plot the pedigree

## source("http://www.bioconductor.org/biocLite.R")
## biocLite(pkgs=c("graph", "Rgraphviz"))

library(package="graph")
library(package="Rgraphviz")
g <- as(t(TInv), "graph")
plot(g)

## install.packages(pkgs="igraph")
library(package="igraph")
i <- igraph.from.graphNEL(graphNEL=g)
V(i)$label <- 1:10
plot(i)


####################################
### Get most important ancestors ###
####################################

# got that idea from: 
# Identification of key ancestors of modern germplasm in a breeding program of maize, Technow et al., 2014

# the design matrix for the animal effect can
# be regarded as a gene-flow matrix with columns representing animals = features
# and rows representing observations.
# we will use the column-sums as indicator for importance, because that tells us 'how often'
# that animal is represented in the pedigree

L <- as(t(relfactor(ped2)),"dgCMatrix")

w <- colSums(L)

dat <- data.frame(label = ped2@label, w=w, stringsAsFactors=FALSE)

plot(dat)

# get fractions of single animals of total
total <- sum(L@x)

dat$fraction <- dat$w/total
plot(dat$fraction)

###################################
### Look at some key ancesotors ###
###################################

dat2 <- dat[order(dat$w, decreasing=TRUE),]
dat2$cumsum <- cumsum(dat2[,3])

plot(dat2$cumsum)


######################################################################
### Goddard and Hayes (2009) approach of identifying key ancestors ###
######################################################################

PED <- ped2
A <- getA(PED)

# test 'key ancestors'
key <- c(1,2,4,9)

# A for key ancestors
A22 <- A[key,key]

# A for key with res
A12 <- A[-key,key]

# what hayes and goddard say is: find the subset of ancestors that
# maximize 1’b, b = A_22^-1 c, and c = average relationship of key with -key

# get c
c <- colMeans(A12)

# the vector of gene contributions for the key ancestors
b <- solve(A22,c)

# the expected average breeding value for the current population given the
# ancestors will be : g11 = b'g_22

# make breeding values
g <- rnorm(length(PED@label))

g11_mean <- t(b) %*% g[key]

# this is equivalent to taking the average of the BLP:
g11 <- A12 %*% solve(A22,g[key])

mean(g11)

## or: 

# get the column-wise means
ones <- array(1,dim=c(nrow(A12),1))

# those are simply the OLS means for every column
c <- solve(crossprod(ones),crossprod(ones,A12))

# we can also get b by this
b <- colMeans(A12 %*% solve(A22))

# use Rohans shortcut
Ainv <- getAInv(PED)

b <- colMeans(solve(Ainv[-key,-key],(-Ainv[-key,key])))

# so we want to find a subset of n key-ancestors, that maximize sum(b_n)



























