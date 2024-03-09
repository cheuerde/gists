# Claas Heuer, October 2015
#
# Variance Component Estimation using Maximum Likelihood in R - Animal Model
#
# Inspired from:
# http://stackoverflow.com/q/7572260/2748031
# http://www.r-bloggers.com/fitting-a-model-by-maximum-likelihood/
# http://www.johnmyleswhite.com/notebook/2010/04/21/doing-maximum-likelihood-estimation-by-hand-in-r/

# this is needed for the PDF of a multivariate normal distribution
library(mvtnorm)

# we use the BGLR data
library(BGLR)
data(wheat)

# the numerator relationship matrix
A <- wheat.A

# the cholesky of that (only used here to make the
# funcion operate more generally
L <- t(chol(wheat.A))

# the phenotype
y <- wheat.Y[,1]

# design matrices for the model: y = Xb + Zu + e, with e ~ N(0,var_e) and
# u ~ MVN(0,ZZ'var_a).
# above formulation was for the conditional model p(y|u) and p(u|.),
# but here we use: y = Xb + e, with e ~ MVN(0, ZZ' var_a + I var_e)
X <- matrix(1,length(y),1)
Z <- L

# the likelihood function = L(y;.) = prod(PDF(y, E(y) = Xb, var(y) = ZZ' var_a + I var_e))
lik <- function(par, y, X, Z) {

# it has to be this awkward because 'optim' only wants one vector of parameters
 b <- matrix(c(par[3:(2+ncol(X))]), ncol=1)

# this is ZZ' var_a
 A <- tcrossprod(Z) * par[2]

# this is I var_e
 R <- diag(length(y)) * par[1]

 V = A + R

# E(y)
 mu <- X %*% b

# optim minimizes - therefor we need the negative product of
# likelihoods for every i.i.d. random variable in y given the model
# and parameters.
# Instead of taking the products over the likelihoods we take
# the sum over log(L) for numerical stability
 -(sum(dmvnorm(x = y,mean = mu ,sigma = V, log=TRUE)))

}


# This is only necessary because 'optim' wants one parameter vector
# from here: http://stackoverflow.com/a/7573077/2748031
getp <- function(X, Z = NULL, b = 0.1, u= 0.1, var_e=1 ,var_a = 1) {

  if(is.null(Z)) { 

    p <- c(var_e, var_a, rep(b, ncol(X)))
    names(p) <- c("var_e", "var_a", paste("b", 0:(ncol(X)-1), sep=""))

  } else {

        p <- c(var_e, var_a, rep(b, ncol(X)), rep(u, ncol(Z)))
        names(p) <- c("var_e", "var_a", paste("b", 0:(ncol(X)-1), sep=""),paste("u", 1:(ncol(Z)), sep=""))

      }

  p

}


# those are the optimizers available 
methods = c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN","Brent")

# Get the Maximum Likelihood estimates for our unknowns
ML <- optim(getp(X), lik, X=X, Z=Z, y=y, method = methods[1])

# compare (NOTE: mixed.solve does REML not ML)
library(rrBLUP)
mod <- mixed.solve(y=y, X=X, Z=Z)

