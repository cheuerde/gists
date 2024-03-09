# this is the conditional model, but does not seem to work well
library(BGLR)

data(wheat)
L <- t(chol(wheat.A))
y <- wheat.Y[,1]

# regression


X <- matrix(1,length(y),1)
Z <- L


lik <- function(par, y, X, Z) {

 b <- matrix(c(par[3:(2+ncol(X))]), ncol=1)
 u <- matrix(c(par[(3+ncol(X)):length(par)]), ncol=1)
 mu <- X %*% b + Z %*% u

# lambda = tau/var_a
 
# optim minimizes
 -(sum(dnorm(y,mu ,par[1], log=TRUE))+ sum(dnorm(u,0,par[2], log=TRUE)))

}



# from here: http://stackoverflow.com/a/7573077/2748031


getp <- function(X, Z, b = 0.1, u= 0.1, var_e=1 ,var_a = 1) {
  p <- c(var_e, var_a, rep(b, ncol(X)), rep(u, ncol(Z)))
  names(p) <- c("var_e", "var_a", paste("b", 0:(ncol(X)-1), sep=""),paste("u", 1:(ncol(Z)), sep=""))
  p
}



methods = c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN","Brent")
a <- optim(getp(X,Z), lik, X=X, Z=Z, y=y, method = methods[4])

#solve(crossprod(X),crossprod(X,y))


library(rrBLUP)
mod <- mixed.solve(y=y, X=X, Z=Z)
