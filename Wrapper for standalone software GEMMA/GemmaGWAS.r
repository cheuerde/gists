# Claas Heuer, August 2016
#
# Wrapper for standalone software "GEMMA"
# http://www.xzlab.org/software.html
# NOTE: the binary executable "gemma" must be
# in $PATH (e.g.: sudo cp gemma /usr/bin/)

# Y is a matrix of phenotypes (each column one trait).
# Z is the matrix of marker covariates.
# G is a genomic relationship matrix, may be NULL (then GEMMA will compute it).
# tempfolder is needed to store results.
GemmaGWAS <- function(Y, Z, G = NULL, tempFolder = tempdir()) {

	folder = tempFolder
	dir.create(folder, recursive = TRUE, showWarnings = FALSE)
	if(!dir.exists(folder)) stop("cannot write in tempFolder")
	oldwd <- getwd()
	setwd(folder)

	if(is.vector(Y)) Y <- array(Y, dim = c(length(Y), 1))

	if(nrow(Y) != nrow(Z)) stop("Y and Z must have same number of rows")

	# prepare the data in the way gemma wants it
	# NOTE: gemma would also accept plink files
	tZ <- t(Z)

	id <- seq(1,ncol(Z))
	if(!is.null(colnames(Z))) id <- colnames(Z)

	Gs <- rep("G",ncol(Z))
	C <- rep("C",ncol(Z))
	tZ <- cbind(id,Gs,C,tZ)

	write.table(file="Z", tZ, col.names=FALSE, row.names=FALSE, quote=FALSE, sep=",")
	write.table(file="Y", Y, col.names=FALSE, row.names=FALSE, quote=FALSE, sep=",")

	rm(tZ)
	gc()

	# we can either let gemma compute G or provide our own
	if(is.null(G)) {

		makeg=paste("gemma -g ", folder, "/Z ", "-p ", folder, "/Y ", "-gk 2 -o G",sep="")
		system(makeg)  

	} else {

		write.table(file = "G.sXX.txt", G, col.names=FALSE, row.names=FALSE, quote=FALSE)

	}

	##################################
	#########  Start GWAS ############
	##################################

	# will hold the results, one element per phenotype
	res <- list()

	# gemma will throw away markers if there are monomorphic or
	# close to that. Have to check manual
	notinlist <- list()

	## supposed to run over ceveral different phenotypes stored in 
	## 'Y' with colnames 'traits' 
	traits <- 1:ncol(Y)
	if(!is.null(colnames(Y))) traits <- colnames(Y)

	for(i in 1:length(traits)) {

		trait <- traits[i]
		y <- Y[,i]
		write.table(file = "y", y, quote = FALSE, row.names = FALSE, col.names = FALSE)
		print(trait)

		##########  GEMMA  #############
		# GWAS
		# -lmm 4 performs 4 different tests, lmm -1 for wald only
		gwas<-paste("gemma -g ", folder, "/Z ", "-p ", folder, "/y ", "-k ", folder,
			    "/output/G.sXX.txt ", "-lmm 1 -miss 1 -maf 0 -o ", trait, "_lmm", sep="")
		system(gwas)

		## Read Data
		res[[i]] <- read.table(paste(folder,"/output/",trait,"_lmm.assoc.txt", sep=""),stringsAsFactors=F,header=T)
		notin<-which(!(seq(1:ncol(Z)) %in% res[[i]][,2]))
		notinlist[[i]]<-notin

	}

	names(res)<-traits
	names(notinlist)<-traits

	setwd(oldwd)

	# FIXME: "notinlist" is ignored
	return(res)

}

