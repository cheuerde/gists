# Claas Heuer, 2014
###############################
###############################

# Using transformed model for efficient GBLUP
#
# X = Incidence matrix for fixed effects
# G = Genomic relationship matrix
# y = vector of phenotypes
# id = vector of ids


library(asreml)
# prepare transformations

n=length(y)

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
Uy<-t(U)%*%y

# prepare sparse Ginverse object for asreml
# Ginverse of the transformed model is diagonal
# and simply 1/D
Ginv<-array(0,dim=c(n,3))
Ginv[,1]<-1:n

# fill the object, only diagonal elemets needed
n=length(y)
Ginv[,1]<-1:n
Ginv[,2]<-1:n
Ginv[,3]<-1/D

# make asreml happy
colnames(Ginv)<-c("row","column","value")
attributes(Ginv)$rowNames=id
attributes(Ginv)$colNames=id


# prepare dataset for asreml-call
data<-data.frame(id,Uy,UX)
data$id<-as.character(data$id)


# run model
model<-asreml(Uy~-1+UX,random=~ped(id),ginverse=list(id=Ginv),data=data)

# get breeding values:
# in order to get them on the original scale
# we have to backtransform them.
# so:  blups_original = U blups_transformed

# get transformed blups, with var(a) = D var(a)
blups_transformed = model$coefficients$random

# backtransform sor var(a) = var(Ua) = UDU' var(a) = G var(a)
blups = U%*%blups_transformed

######################
###################### 