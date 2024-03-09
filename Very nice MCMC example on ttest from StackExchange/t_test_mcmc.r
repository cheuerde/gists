# taken from here:
# http://stats.stackexchange.com/a/135725/90936

set.seed(7)

#create samples
sample.1 <- rnorm(8, 100, 3)
sample.2 <- rnorm(10, 103, 7)

#we need a pooled data set for estimating parameters in the prior.
pooled <- c(sample.1, sample.2)
par(mfrow=c(1, 2))

hist(sample.1)
hist(sample.2)


likelihood <- function(parameters){
  mu1=parameters[1]; sig1=parameters[2]; mu2=parameters[3]; sig2=parameters[4]
  prod(dnorm(sample.1, mu1, sig1)) * prod(dnorm(sample.2, mu2, sig2))
}

prior <- function(parameters){
  mu1=parameters[1]; sig1=parameters[2]; mu2=parameters[3]; sig2=parameters[4]
  dnorm(mu1, mean(pooled), 1000*sd(pooled)) * dnorm(mu2, mean(pooled), 1000*sd(pooled)) * dexp(sig1, rate=0.1) * dexp(sig2, 0.1)
}

posterior <- function(parameters) likelihood(parameters) * prior(parameters)


#starting values
mu1 = 100; sig1 = 10; mu2 = 100; sig2 = 10
parameters <- c(mu1, sig1, mu2, sig2)

#this is the MCMC /w Metropolis method
n.iter <- 10000
results <- matrix(0, nrow=n.iter, ncol=4)
results[1, ] <- parameters
for (iteration in 2:n.iter){
  candidate <- parameters + rnorm(4, sd=0.5)
  ratio <- posterior(candidate)/posterior(parameters)
  if (runif(1) < ratio) parameters <- candidate #Metropolis modification
  results[iteration, ] <- parameters
}



#burn-in
results <- results[500:n.iter,]


mu1 <- results[,1]
mu2 <- results[,3]

hist(mu1 - mu2)


mean(mu1 - mu2 < 0)
mean(mu2 - mu1 > 5)
