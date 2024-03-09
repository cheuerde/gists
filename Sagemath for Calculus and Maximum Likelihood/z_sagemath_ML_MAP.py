# Maximum A Posteriori Estimation 

x, y, z, mu, sigma, prior_mu, prior_sigma = var('x y z mu sigma prior_mu prior_sigma')

# the likelihood
L1 = (1/(sqrt(2*pi*sigma^2))) * exp(-(x - mu)^2 / (2*sigma^2))
L2 = (1/(sqrt(2*pi*sigma^2))) * exp(-(y - mu)^2 / (2*sigma^2))
L3 = (1/(sqrt(2*pi*sigma^2))) * exp(-(z - mu)^2 / (2*sigma^2))

# the prior for mu
L_prior_mu = (1/(sqrt(2*pi*sigma^2))) * exp(-(mu - 3.2)^2 / (2*4**2))

# 
# the joint likelihood = prod(L1,L2,L3)
L3 = L1*L2*L3*L_prior_mu

# the log likelihood
log_L3 = log(L3)

# We take the partial derivative with respect to our
# parameters and set equal to zero (solve).
#
# the maximum likelihood estimator for mu:
solve(diff(log_L3,mu),mu)
