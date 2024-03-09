# Claas Heuer, February 2016
#
# Fast version of editPed form pedigreemm package

if (!require("pacman")) install.packages("pacman")
pacman::p_load(Rcpp, pedigreemm)

sourceCpp("EditPedFast.cpp")

EditPedFast <- function(sire, dam, label, verbose = FALSE) {

	nped <- length(sire)
	if (nped != length(dam))  stop("sire and dam have to be of the same length")
	if (nped != length(label)) stop("label has to be of the same length than sire and dam")
	tmp <- unique(sort(c(as.character(sire), as.character(dam))))

	missingP <-NULL
	if(any(completeId <- ! tmp %in% as.character(label))) missingP <- tmp[completeId]
	labelOl <- c(as.character(missingP),as.character(label))
	sireOl <- c(rep(NA, times=length(missingP)),as.character(sire))
	damOl  <- c(rep(NA, times=length(missingP)),as.character(dam))
	sire <- as.integer(factor(sireOl, levels = labelOl))
	dam  <- as.integer(factor(damOl, levels = labelOl))
	nped <-length(labelOl)
	label <-1:nped
	sire[!is.na(sire) & (sire<1 | sire>nped)] <- NA
	dam[!is.na(dam) & (dam < 1 | dam > nped)] <- NA
	pede <- data.frame(id= label, sire= sire, dam= dam, gene=rep(NA, times=nped))
	noParents <- (is.na(pede$sire) & is.na(pede$dam))
	pede$gene[noParents] <- 0
	pede$gene<-as.integer(pede$gene)

	# new version that calls the C-function "get_generation"
	# Note: there is no return value, the R-objects are directly being changed
	GetGeneration(pede$sire, pede$dam, pede$id, pede$gene, as.integer(verbose))

	ord<- order(pede$gene)
	ans<-data.frame(label=labelOl, sire=sireOl, dam=damOl, gene=pede$gene,
			stringsAsFactors =F)
	ans[ord,]

}
