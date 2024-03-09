#' @name GetNRM
#' @title Constructing numerator relationship matrix using full pedigree or sire and MGS
#' @author Claas Heuer
#' @details April 2016
#' @usage 
#' GetNRM(ped, mgs = FALSE)
#' @description
#' Construct numerator relationship matrix based on regular pedigree file
#' or using sire and maternal grandsire information.
#' @param ped 
#' \code{data.frame} with three columns: \code{id}, \code{sire} and \code{dam/mgs}
#' @param mgs 
#' Indicate whether third column of \code{ped} is the maternal grandsire rather than the dam
#' @return Numerator Relationship Matrix as \code{dgCMatrix}
#' @examples
#'
#' A <- GetNRM(ped, mgs = FALSE)

if (!require("pacman")) install.packages("pacman")
pacman::p_load(pedigreemm)

source("EditPedFast.r")

#' @export
GetNRM <- function(ped, mgs = FALSE) {

	if(!is.data.frame(ped)) stop("ped must be a data.frame")

	colnames(ped)[1:3] <- c("id", "sire", "dam")
	if(mgs) colnames(ped)[3] <- "mgs"

	pednew <- ped

	# if dam is replaced by mgs we expand pedigree with pseudo dams
	if(mgs) {

		damped <- data.frame(id = paste("PseudoDam_", 1:nrow(ped), sep = ""), 
				     sire = ped$mgs, dam = NA, stringsAsFactors = FALSE)

		# fill dam column with pseudodams
		pednew <- data.frame(id = ped$id, sire = ped$sire, dam = damped$id, stringsAsFactors = FALSE)

		# add dams to pedigree
		pednew <- rbind(damped, pednew)

	}

	# add founders
	PEDtemp <- EditPedFast(label = pednew$id, sire = pednew$sire, dam = pednew$dam)
	PED <- pedigreemm::pedigree(label = PEDtemp$label, dam = PEDtemp$dam,
				    sire = PEDtemp$sire)

	# get A without pseudodams
	L <- t(relfactor(PED))

	if(mgs) {

		A <- tcrossprod(L[!PED@label %in% damped$id,])
		ids <- PED@label[!PED@label %in% damped$id]

	} else {

		A <- tcrossprod(L)
		ids <- PED@label

	}

	A <- as(A, "dgCMatrix")
	rownames(A) <- ids
	colnames(A) <- ids

	return(A)

}
