# Claas Heuer, October 2015
#
# This is a multivariate extension of the approach described in 
# Kang et.al (2008) and implemented by Zhou and Stephens (2014)
# in 'GEMMA'. The diagonalization of V in a mixed model with 
# one (!) random effect can easily be extended to the multivariate 
# case using Asreml or MCMCglmm.
# This paper made me do this again: http://biorxiv.org/content/biorxiv/early/2015/09/18/027201.full.pdf 
# In that paper they made a kind of unfair comparison to Asreml by not using the
# transformed model, which has de facto nothing to do with Asreml. Here I show how
# easily the exact same model can be implemented in Asreml and I bet it would perform 
# just as efficient as GEMMA or their software ('MTG2')

###############################
###############################

# Using transformed model for efficient GBLUP
#
# X = Incidence matrix for fixed effects
# G = Genomic relationship matrix
# y = vector of phenotypes
# id = vector of ids

# if asreml is not available, use MCMCglmm
asreml = FALSE
library(asreml)
library(MCMCglmm)

# the data is taken from BGLR 
library (BGLR)
library(cpgen)

data(wheat) 
A <- wheat.A
M <- wheat.X
G <- cgrm(M, lambda=0.01)
Y <- wheat.Y

y1 <- Y[,1]
y2 <- Y[,2]

# prepare transformations
n=length(y1)

# just in case there are no ids
id<-1:n

# get the decomposition: G = UDU'
UD<-eigen(G)
U<-UD$vectors

# This will be our new 'relationship-matrix'
D<-UD$values

# here: only one fixed effect (intercept)
X<-array(1,dim=c(n,1))

# premultiply X and y by U'
UX<-t(U)%*%X
#Uy<-t(U)%*%y

# multivariate
UY <- t(U) %*% Y

# prepare sparse Ginverse object for asreml
# Ginverse of the transformed model is diagonal
# and simply 1/D
Ginv<-array(0,dim=c(n,3))
Ginv[,1]<-1:n

# fill the object, only diagonal elemets needed
Ginv[,1]<-1:n
Ginv[,2]<-1:n
Ginv[,3]<-1/D

# make asreml happy
colnames(Ginv)<-c("row","column","value")
attributes(Ginv)$rowNames=id
attributes(Ginv)$colNames=id

# for MCMCglmm we can simply construct Ginv as dgCMatrix
if(!asreml) { 

  Ginv <- as(diag(1/D),"dgCMatrix")
  rownames(Ginv) <- colnames(Ginv) <- rownames(A)

}

# prepare dataset for asreml-call
data<-data.frame(id = rownames(A) ,y1 = UY[,1], y2 = UY[,2], UX =UX)
data$id<-as.character(data$id)


# run model
if(asreml) { 

  model <- asreml(cbind(y1,y2) ~ -1 + trait:UX, random = ~us(trait):ped(id), rcov = units:us(trait), ginverse = list(id=Ginv), data=dat)

# get breeding values:
# in order to get them on the original scale
# we have to backtransform them.
# so:  blups_original = U blups_transformed

# get transformed blups, with var(a) = D var(a)
#  blups_transformed = model$coefficients$random

# backtransform sor var(a) = var(Ua) = UDU' var(a) = G var(a)
#  blups = U%*%blups_transformed

} else {

    model <- MCMCglmm(cbind(y1,y2) ~ -1 + trait:UX, random = ~ us(trait):id, ginverse = list(id = Ginv), rcov= ~us(trait):units, data=data, family=c("gaussian","gaussian"))
    V <- model$VCV
    Cgen <- posterior.cor(V[,1:4])
    Cres <- posterior.cor(V[,5:8])

# the genetic and residual correlations
    colMeans(Cgen)
    colMeans(Cres)

  }



