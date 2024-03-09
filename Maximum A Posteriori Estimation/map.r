# Claas Heuer, October 2015
#
# Maximum A Posteriori Estimation 
#
# Estimate mean and variance of normal iid variables
# with a normal prior on the mean

# the likelihood function = L(y;.) = y ~ N(mu, sigma) * mu ~ N(0,16)
lik <- function(par, y) {

# the likelihood of y
   L1 <- dnorm(x = y,mean = par[1] ,sd = par[2], log=TRUE)

# the prior = likelihood of mu
   L2 <- dnorm(x = par[1], mean = 0, sd = 4, log=TRUE)
   
# the joint likelihood
  return(-sum(L1 + L2))

}



# those are the optimizers available 
methods = c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN","Brent")

p <- c(0,1)
names(p) <- c("mu","sigma")

# Get the Maximum Likelihood estimates for our unknowns
ML <- optim(p, lik, y=y, method = methods[1])




