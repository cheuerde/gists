# Claas Heuer, September 2015
#
# Simple and stupid pedigree simulation. just for software tests


ped_sim <- function(n = 1000, n_founders = 100, generations  = 5) {

  ped <- data.frame(id = 1:n, sire = as.integer(NA), dam = as.integer(NA), sex = as.integer(NA), gen = as.integer(NA))

# the founders
  ped[1:n_founders, "sex"] <- sample(x = c(0,1), size = n_founders, prob = c(0.5,0.5), replace = TRUE)
  ped[1:n_founders, "gen"] <- 0

# in every generation an equal number of residual animals
  gen_size <- rep((n - n_founders) / (generations - 1), generations - 1)
  if(sum(gen_size) < (n - n_founders)) gen_size[(length(gen_size) - 1)] <- gen_size[(length(gen_size) - 1)] + ((n - n_founders) - sum(gen_size))

# assign parents
  end <- n_founders
  gen <- 0
  for(i in 1:(generations - 1)) {

    gen <- gen + 1
    start <- end + 1
    end <- ifelse(i == (generations - 1), n, end + gen_size[i])

    ped[start:end, "sire"] <- sample(x = (1:(start-1))[ped[(1:(start-1)),"sex"] == 0], size = length(start:end), replace = TRUE)
    ped[start:end, "dam"] <- sample(x = (1:(start-1))[ped[(1:(start-1)),"sex"] == 1], size = length(start:end), replace = TRUE)
    ped[start:end, "sex"] <- sample(x = c(0,1), size = length(start:end), replace = TRUE)

#   ped[start:end, "dam"] <- sample(x = ped[ped$sex == 1 & ped$gen == (gen - 1),"id"], size = length(start:end), replace = TRUE)

    sire_gen <- ped[ped[start:end,"sire"],"gen"]
    dam_gen <- ped[ped[start:end,"dam"],"gen"]
    max_gen <- apply(cbind(sire_gen,dam_gen),1,max)
    ped[start:end, "gen"] <- max_gen + 1

  }


  return(ped)

}



editPed_fast <- function(sire, dam, label, verbose = FALSE)
{

    library(cpgen)
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

    .Call("get_generation", pede$sire, pede$dam, pede$id, pede$gene, as.integer(verbose), package="cpgen")    

    ord<- order(pede$gene)
    ans<-data.frame(label=labelOl, sire=sireOl, dam=damOl, gene=pede$gene,
                    stringsAsFactors =F)
    ans[ord,]
}


# this is fast and memory efficient because the diagonal is sparse
getAInv_fast <- function(ped) {

  T_Inv <- as(ped, "sparseMatrix")
  D_Inv <- Diagonal(x=1/Dmat(ped))
  Ainv<-t(T_Inv) %*% D_Inv %*% T_Inv
  dimnames(Ainv)[[1]]<-dimnames(Ainv)[[2]] <-ped@label
  Ainv <- as(Ainv, "dgCMatrix")
  return(Ainv)

}


# run
#ped <- ped_sim(n = 1000000, n_founders = 1000, generations = 10)

# library(pedigreemm)
#PED <- editPed_fast(label = ped$id, sire = ped$sire, dam=ped$dam)
#PED <- pedigreemm::pedigree(label = PED$label, sire = PED$sire, dam = PED$dam)





