# Claas Heuer, September 2015
#
# Extremely good vignette for mixtools: https://cran.r-project.org/web/packages/mixtools/vignettes/mixtools.pdf

library(mixtools)
library(ks)

########################
### Gaussian Mixture ###
########################

# some random data
set.seed(100)
N <- 1000
theta <- 0.3
mu1 <- -10
mu2 <- 10
sd1 <- 1
sd2 <- 20
y <- ifelse(runif(N) < theta, rnorm(N, mu1, sd1), rnorm(N, mu2, sd2))
 
dat = list(N=length(y),y=y, k=2)

# run the model
mod <- normalmixEM(y)

# plot data and estimated densities
plot(mod, which = 2)
