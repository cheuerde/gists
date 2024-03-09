# Claas Heuer, 2015
#
# How to run LMM-GWAS in R with 'pedigreemm'
# [Single marker regression with polygenic effect to account for population structure]

# get packages (only have to be done once)

#install.packages('kinship2')
#install.packages('pedigreemm')
#install.packages('car')

# load packages

library(kinship2)
library(pedigreemm)
library(car)

# load example dataset from kinship2 package

data(sample.ped)

# extract pedigree

ped_temp <- sample.ped[,c(2,3,4)]

# convert missing sire/dam (0) to NA

ped_temp[ped_temp[,2]==0,2] <- NA
ped_temp[ped_temp[,3]==0,3] <- NA

# make pedigreemm - pedigree object

PED <- editPed(label = ped_temp[,1], sire = ped_temp[,2], dam = ped_temp[,3])
PED <- pedigreemm::pedigree(label = PED$label, sire = PED$sire, dam = PED$dam) 

# Numerator Relationship matrix (A) and its inverse (A_inv)  can now
# be obtained easily

A <- getA(PED)
A_inv <- getAInv(PED)

# make some data

dat <- sample.ped
dat$y <- rnorm(nrow(dat))

# number of individuals
n <- nrow(dat)

# add some polygenic noise from sires
dat$father[dat$father==0] <- NA
u <- rnorm(length(unique(dat$father))-1)
dat$y[!is.na(dat$father)] <- dat$y[!is.na(dat$father)] + as.numeric(model.matrix(~-1 + factor(father),data=dat) %*% u) 

# make some markers

# number of markers
p <- 100

# marker matrix
X <- matrix(sample(c(0,1,2), size=n*p,prob=c(0.25,0.5,0.25),replace=T),n,p)

# create one qtl with effect size of 1.5 phenotypic standard deviations 

qtl_pos <- sample(1:p,1)
add_effect <- 1.5 * sd(dat$y)

# add qtl effect to phenotype
dat$y <- dat$y + X[,qtl_pos] * add_effect

# add a column for a marker to dataframe

dat$add <- X[,qtl_pos]

# run model and include 'sex' as fixed effect

# this is necessary because lmer is a pussy
controller = lmerControl(check.nobs.vs.nlev = "ignore",check.nobs.vs.nRE="ignore",sparseX=TRUE)

# run the model without marker
mod <- pedigreemm(y ~ sex + (1|id), pedigree=list(id=PED), data=dat, control=controller)

# check variance components
summary(mod)


################
### Run GWAS ###
################

# object to store our results (p-value, regression coefficient and standard error)
out <- array(0,dim=c(ncol(X),3))
colnames(out) <- c("p_value","beta","se")

# loop over all markers

for(i in 1:ncol(X)) {

print(i)

# change column in dataframe to the i-th marker
dat$add <- X[,i]

# this is essentially 'lmer'. 'pedigreemm' is a wrapper
# function that allows us to include an animal effect
# based on a numerator relationship matrix.
# therefor this model is equivalent to what we have done before with Asreml


# run the full model with our marker ('add')

mod <- pedigreemm(y ~ add + sex + (1|id), pedigree=list(id=PED), data=dat, control=controller)

# extract coefficient

coeff <- summary(mod)$coefficients[2,]

# get p-value

amod <- Anova(mod, type='III')
out[i,1] <- amod[[3]][2]
out[i,2] <- coeff[1]
out[i,3] <- coeff[2]


}


# plot results
plot(-log10(out[,1]))



