# Claas Heuer, March 2016
#
# Very simple improvement of pedigreemm::getAInv.
# Replaced dense diagonal by sparse one

GetAinvFast <- function(ped) {

	stopifnot(is(ped, "pedigree"))    
	T_Inv <- as(ped, "sparseMatrix")
	D_Inv <- Diagonal(x=1/Dmat(ped))
	aiMx<-t(T_Inv) %*% D_Inv %*% T_Inv
	dimnames(aiMx)[[1]]<-dimnames(aiMx)[[2]] <-ped@label
	aiMx

}
