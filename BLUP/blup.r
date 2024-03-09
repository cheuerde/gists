# modified from Marvin Gertz, 2015
#
# Custom BLUP ############
    blupLHS <- function (formula, ped, data, alpha, trim = FALSE)
    {
        colnames(ped)[1:3] <- c("ID", "SIRE", "DAM")
        if (any(!all.vars(formula) %in% colnames(ped)))
            stop("Formula has variables which are not present in the data.")
        ww <- match(all.vars(formula)[-1], colnames(ped))
        ped$b <- apply(ped, 1, function(x) !any(is.na(x[ww])))
        if (trim)
            ped <- ped[trimPed(ped, ped$b), ]
        ped$ID <- factor(ped$ID)
        ped$SIRE <- factor(ped$SIRE)
        ped$DAM <- factor(ped$DAM)

# Sparse model matrices
        X <- sparse.model.matrix(formula, ped)
        Y <- Matrix(model.frame(formula, ped)[, 1])
        Z <- sparse.model.matrix(ped[, all.vars(formula)[1]] ~ ped$ID)

        ped1 <- pedigreemm::pedigree(sire=ped$SIRE,dam=ped$DAM,label=ped$ID)

# getAInv
        stopifnot(is(ped1, "pedigree"))  
        T_Inv <- as(ped1, "sparseMatrix")
        D_Inv <- Diagonal(x=1/Dmat(ped1))
        Ainv<-t(T_Inv) %*% D_Inv %*% T_Inv
        dimnames(Ainv)[[1]]<-dimnames(Ainv)[[2]] <-ped1@label
        gc(reset=T)

# MME parts
        xtx <- crossprod(X)
        xtz <- crossprod(X, Z)
        ztx <- crossprod(Z, X)
        ztzainv <- crossprod(Z) + alpha * Ainv
        gc(reset=T)

# Sparse LHS 
        LHS <- rbind(cbind(xtx,xtz),cbind(ztx,ztzainv))

# RHS remains dense (is just a vector)
        RHS <- c(crossprod(X,Y),crossprod(Z,Y))

# solve
        sol <- solve(LHS, RHS)
        row.names(sol) <- c(colnames(X), as.character(ped$ID))

# this could be the most critical part
        solution <- solve(LHS)
        gc(reset=T)
        pev <- diag(solution)[-c(1:dim(X)[2])]


        ZW <- cbind(as.data.frame(sol@x),c(rep(NA,dim(X)[2]),pev))
        colnames(ZW) <- c("blup","pev")
        rownames(ZW) <- rownames(sol)
        ZW
    }

###