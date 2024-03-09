#########################################
# Claas Heuer, Oct. 2014                #
# GWAS for metabolites using Karkendamm #
# dataset and new marker genotypes      #
#########################################

args=(commandArgs(TRUE))

trait_in <- as.character(args[1])

# we use BGLR here only for its plink-functions (read .bim,.bed,.fam)
library(BGLR)
# for the full model used for the new markers
library(pedigreemm)
# for EMMAX
library(cpgen)
# for Anova
library(car)

###################################
### prepare data sets and merge ###
###################################

set_num_threads(1)

setwd("/home/claas/Metabo_11_2013/new_data/meta")

animals<-scan("animals.csv",what=character(),sep=",")
animals<-as.integer(animals)

ped<-read.table("Pedigree.txt",header=T,stringsAsFactors=F)
a<-ped[,1]
b<-as.integer(substr(a,6,9))
ped$b <- b
sub_ped<-ped[ped$b%in%animals,]

id<-sub_ped$id
id2<-substr(id,6,nchar(id))
id3<-as.character(as.numeric(id2))

meta_tiere<-read.table("/home/claas/Metabo_neu/Metaboliten/tiere_int",stringsAsFactors=F)
geno_tiere<-as.numeric(read.table("/home/claas/Metabo_neu/Genotypen/geno_tiere_int",stringsAsFactors=F)[,1])

## Pedigree 
setwd("/home/claas/Metabo_neu")

widths=c(12,9,1,1,6,1,10,1,8,1,10,1,12,1,10,1,8,1,10,1,12,1,10,1,8,1,10,1,12,1,10,1,8,1,10)
W<-read.fwf(file("kuehe_2013.txt",encoding="latin1"),widths,stringsAsFactors=F,header=F)

ids=scan("kuehe_ped2_10.txt",what=numeric(0))

ped=cbind(ids,W[1:(nrow(W)-1),c(5,9)])

colnames(ped)<-c("id","sire","dam")

ped[,1]<-as.character(ped[,1])
ped[,2]<-as.character(ped[,2])
ped[,3]<-as.character(ped[,3])


## metabolytes
data<-read.table("/home/claas/Metabo_neu/Metaboliten/Milch-Metaboliten_Regensburg_an_Kiel_12Jan2011.csv",header=T,sep=",",stringsAsFactors=F)


## genotypes
X <- matrix(scan("/home/claas/Metabo_neu/Genotypen/Koeffizienten_add_dom", n = 794*106904), 794, 106904, byrow = TRUE)
map_all <- read.table("/home/claas/Metabo_neu/Genotypen/Marker",stringsAsFactors=FALSE)

### create add and dom arrays 
add<-array(0,dim=c(nrow(X),ncol(X)/2))
dom<-array(0,dim=c(nrow(X),ncol(X)/2))

for(i in 1:ncol(add))

{

add[,i]<-X[,i*2-1]
dom[,i]<-X[,i*2]

}

# we dont need dom
rm(dom,X)

gc()

###

data<-data[,c(1,12,14,15,24,25)]

id<-rep(0,nrow(data))
for(i in 1:length(id)){id[i]<-meta_tiere[meta_tiere[,3]==data[i,1],1]}

data[,1]<-id

# prepare data for analysis
dat<-data[data[,1]%in%id3,]

dat[,1] <- as.character(dat[,1])
dat$y <- dat$glycerophosphocholine

dat$add <- rep(0.0, nrow(dat))
dat$gpcpc <- dat$glycerophosphocholine / dat$phosphocholine
dat$lom2 <- dat$Tiercode


###############################
### build ped and run model ### 30.10.14
###############################

# Old way using Asreml - but our license expired ...
# Therefore we now use packages: lmer(pedigreemm) and cpgen
# that will do exactly the same

#A<-asreml.Ainverse(ped)

#mod<-asreml(y~add+Datum+Laktationsnr.+Laktationstag,random=~ped(Tiercode,var=T,init=1)+ide(Tiercode,var=T,init=1),ginverse=list(Tiercode=A$ginv),na.method.X="omit",data=dat,trace=F)

PED <- editPed(label=ped$id,sire=ped$sire,dam=ped$dam)
PED <- pedigreemm::pedigree(label=PED$label,sire=PED$sire,dam=PED$dam)

# this is L from: A = LL'
L <- as(t(relfactor(PED)),"dgCMatrix")

# this is the model matrix for the permanen environmental effect
Z <- sparse.model.matrix(~-1+Tiercode,data=dat)
Zids <- Z@Dimnames[[2]]
Zids <- gsub("Tiercode","",Zids)

# drop animals that are not in our dataset
L <- L[match(Zids,PED@label),]

# this is the model matrix for the additive genetic effect
ZL <- Z%*%L

# this is the model matrix for the fixed effects
X <- sparse.model.matrix(~ 1 + Datum + Laktationsnr. + Laktationstag,data=dat)

# the traits
traits <- c("glycerophosphocholine","phosphocholine","gpcpc")

### run loop over all phenotypes
#for(t in traits) {

trait = trait_in
print(trait)
y <- dat[,trait]

# run mixed model to get variance components (clmm is from package 'cpgen')
mod <- clmm(y=y, X=X, random = list(Z,ZL), niter=20000, burnin=10000)

# compute variance-covariance matrix of y for EMMAX
# V = PE + A + R
V = tcrossprod(Z) * mod$Effect_2$posterior$variance_mean + # permanent environmental variance
    tcrossprod(ZL) * mod$Effect_3$posterior$variance_mean + # additive genetic variance
    Diagonal(x=rep(mod$Residual_Variance$Posterior_Mean,nrow(dat))) # residual variance

# drop individuals that dont have phenotypes
V <- V[!is.na(y),!is.na(y)]
#Xgwa <- as(X[!is.na(y),],"matrix")
Xgwa <- model.matrix(~ 1 + Datum + Laktationsnr. + Laktationstag,data=dat[!is.na(dat[,trait]),])
ygwa <- y[!is.na(y)]

# this is the inverse square root of V.
# This is being used in 'cGWAS' for estimating
# GLS estimates of the fixed effects
V2inv <- as(V,"matrix")%**%-0.5

# get markers
geno_ids <- as.character(geno_tiere)

M <- add[match(dat[,1],geno_ids),]
#vars <- ccolmv(M,var=T)
mafs <- cmaf(M)

# drop non-polymorphic markers
#M <- M[!is.na(y),vars!=0]
M_all <- M[,mafs>=0.05]
M <- M[!is.na(y),mafs>=0.05]
my_map <- map_all[mafs>=0.05,]

################
### New Data ### 30.10.14
################

animals <- scan("/home/claas/Metabo_11_2013/new_data/meta/metabo_30.10.14/animals.txt",what=character(0))

animals <- gsub("DE","",animals)
animals <- gsub("LU","",animals)
animals <- gsub("NL","",animals)
animals <- gsub("FR","",animals)


Gen <- as(read.table("/home/claas/Metabo_11_2013/new_data/meta/metabo_30.10.14/genotypes.txt",stringsAsFactors=FALSE),"matrix")

map <- read.table("/home/claas/Metabo_11_2013/new_data/meta/metabo_30.10.14/map.txt",stringsAsFactors=FALSE)

# impute mean
mus <- colMeans(Gen,na.rm=T)

for(i in 1:ncol(Gen)) {

  Gen[is.na(Gen[,i]),i] <- mus[i]

}

# get correct ordering
M_new <- Gen[match(as.numeric(dat[,1]),as.numeric(animals)),]
M_model <- M_new[!is.na(y),]

# run gwas with EMMAX - this is not optimal, as our QTL contribute 
# substantially to the genetic variance. 
# We run a full model at the bottom of the script.
mod_gwa_new <- cGWAS(y=ygwa, X=Xgwa, M=M_model, V=V2inv, verbose=TRUE)


###########################################################
### GWAS for Chr 25 using top 3 markers as fixed effect ### 30.10.14
###########################################################

# get the top three markers from gwas
top_three <- order(mod_gwa_new$p_value)[1:3]

# get markers form 50k panel on chr 25
#M_25 <- add[match(dat[,1],geno_ids),map_all[,1]==25 & vars!=0]
M_25 <- add[match(dat[,1],geno_ids),map_all[,1]==25 & mafs>=0.05]
M_25 <- M_25[!is.na(y),]

# run gwas with one of the top three as fixed effect
for(w in 1:3) {

X_top_three <- cbind(Xgwa,M_model[,top_three[w]])

mod_25_fix <- cGWAS(y=ygwa, X=X_top_three, M=M_25, V=V2inv, verbose=TRUE)

### write out results
map_temp <- map_all[map_all[,1]==25 & mafs>=0.05,]
colnames(map_temp) <- c("chr","name","bla","position")

data_temp <- as.data.frame(mod_25_fix)
data_temp <- cbind(map_temp[,c(1,2,4)],data_temp)

write.table(data_temp,file=paste("/home/claas/Metabo_11_2013/new_data/meta/results_30.10.14/",trait,"_chr25_emmax_top_three_",w,"_fixed.txt",sep=""),col.names=TRUE,row.names=FALSE,quote=FALSE)

}

# and without the top three
mod_25_not_fix <- cGWAS(y=ygwa, X=Xgwa, M=M_25, V=V2inv, verbose=TRUE)

data_temp <- as.data.frame(mod_25_not_fix)
data_temp <- cbind(map_temp[,c(1,2,4)],data_temp)

write.table(data_temp,file=paste("/home/claas/Metabo_11_2013/new_data/meta/results_30.10.14/",trait,"_chr25_emmax_without_top_three_fixed.txt",sep=""),col.names=TRUE,row.names=FALSE,quote=FALSE)



#############################################
### GWAS for new markers using full model ### 30.10.14
#############################################

# the impact of the qtl is too big
# to assume that they dont't alter the
# variance components. therefore we run
# a full mixed model for every marker
# of the new set

out <- array(0,dim=c(ncol(M_new),3))
colnames(out) <- c("p_value","beta","se")

dat$y <- dat[,trait]

for(i in 1:ncol(M_new)) {

print(i)
dat$add <- M_new[,i]

# this is essentially 'lmer'. 'pedigreemm' is a wrapper
# function that allows us to include an animal effect
# based on a numerator relationship matrix.
# therefor this model is equivalent to what we have done before with Asreml
mod_full <- pedigreemm(y ~ 1 + add + Datum + Laktationsnr. + Laktationstag + (1|lom2) +(1|Tiercode),pedigree=list(Tiercode=PED) ,data=dat)

coeff <- summary(mod_full)$coefficients[2,]
amod <- Anova(mod_full, type='III')
out[i,1] <- amod[[3]][2]
out[i,2] <- coeff[1]
out[i,3] <- coeff[2]

}



write.table(out,file=paste("/home/claas/Metabo_11_2013/new_data/meta/results_30.10.14/",trait,"_full_model_new_marker.txt",sep=""),col.names=TRUE,row.names=FALSE,quote=FALSE)


#############################################
### GWAS for all markers using full model ### 30.10.14
#############################################

# the impact of the qtl is too big
# to assume that they dont't alter the
# variance components. therefore we run
# a full mixed model for every marker
# of the new set

out <- array(0,dim=c(ncol(M_all),6))
colnames(out) <- c("p_value","beta","se","chr","marker_name","position")

dat$y <- dat[,trait]

for(i in 1:ncol(M_all)) {

print(i)
dat$add <- M_all[,i]

# this is essentially 'lmer'. 'pedigreemm' is a wrapper
# function that allows us to include an animal effect
# based on a numerator relationship matrix.
# therefor this model is equivalent to what we have done before with Asreml
mod_full <- pedigreemm(y ~ 1 + add + Datum + Laktationsnr. + Laktationstag + (1|lom2) +(1|Tiercode),pedigree=list(Tiercode=PED) ,data=dat)

coeff <- summary(mod_full)$coefficients[2,]
amod <- Anova(mod_full, type='III')
out[i,1] <- amod[[3]][2]
out[i,2] <- coeff[1]
out[i,3] <- coeff[2]

out[i,4] <- my_map[i,1]
out[i,5] <- my_map[i,2]
out[i,6] <- my_map[i,4]

}



write.table(out,file=paste("/home/claas/Metabo_11_2013/new_data/meta/results_30.10.14/",trait,"_full_model_ALL_markers.txt",sep=""),col.names=TRUE,row.names=FALSE,quote=FALSE)










