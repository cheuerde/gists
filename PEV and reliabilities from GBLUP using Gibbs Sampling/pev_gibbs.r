# Claas Heuer, 2015

library(cpgen)
library(pedigreemm)
library(MCMCglmm)


setwd("/home/claas/kaki/Analysedaten")
X<-cscanx("Xa")

pheno<-read.table("Y")
header<-scan("header",what=character(0))
colnames(pheno)<-header

trait = "ydfpr"

folds = 40
reps = 1

##################
#### Pedigree ####
##################

ped<-read.table("ped_komplett",header=T)

ped[ped[,1]==0,1] <- NA
ped[ped[,2]==0,2] <- NA
ped[ped[,3]==0,3] <- NA

P<-editPed(sire=ped$sire,dam=ped$dam,label=ped$tiere)

PED <- pedigree(sire=P$sire,dam=P$dam,label=P$label)
A <- getA(PED)

#########

y <- pheno[,trait]
M <- X[!is.na(y),]
A <- A[match(ped$tiere,PED@label),match(ped$tiere,PED@label)]
A <- A[!is.na(y),!is.na(y)]
y <- y[!is.na(y)]

G <- cgrm(M,lambda=0.01)
L <- t(chol(A))
LG <- t(chol(G))

id <- 1:length(y)
ctrain <- sample(id,length(y)/5*4,replace=F)
ctest <- id[-ctrain]
y2 <- y
y2[ctest] <- NA

#### run model

niter=60000
burnin=30000

set_num_threads(1)
mod <- clmm(y2,random=list(LG),beta_posterior=T,use_BLAS=T,niter=niter,burnin=burnin)
pred <- LG %*% t(mod$Effect_1$posterior$estimates[(burnin+1):niter,])

mean_pred <- rowMeans(pred)
var_pred <- apply(pred,1,var)

### get reliabilities
### Hayes et al., 2009: 1 - (PEV/var_a)
### or: REL = (Var(True Values) − Var(P E))/(Var(True Values) (L.R.Schaeffer)

rel <- 1 - (var_pred / mod$Effect_1$posterior$variance_mean)

