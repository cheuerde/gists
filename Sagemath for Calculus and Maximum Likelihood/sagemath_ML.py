# Claas Heuer, October 2015
#
# Using Sagemath (http://www.sagemath.org/) for calculus
# and analytical maximum likelihood solutions
#
# Examples taken from: https://en.wikipedia.org/wiki/Maximum_likelihood

#########
### a binomial example
#########

n,p,k,L = var('n p k L')

# the likelihood
L = p^k * (1-p)^(n-k)

# first partial derivative with respect to p
derivative(p^k * (1-p)^(n-k),p)

# get the maximum likelihood estimates for p
solve(derivative(p^k * (1-p)^(n-k),p,1),p)

# for n and p we provide actual data now as in: https://en.wikipedia.org/wiki/Maximum_likelihood
n = 80
k = 49

# solve with our data
solve(derivative(p^k * (1-p)^(n-k),p,1),p)

########
### vector of iid random variables from same normal distribution.
### here we use 3 variables
########

x, y, z, mu, sigma = var('x y z mu sigma')

L1 = (1/(sqrt(2*pi*sigma^2))) * exp(-(x - mu)^2 / (2*sigma^2))
L2 = (1/(sqrt(2*pi*sigma^2))) * exp(-(y - mu)^2 / (2*sigma^2))
L3 = (1/(sqrt(2*pi*sigma^2))) * exp(-(z - mu)^2 / (2*sigma^2))

# the joint likelihood = prod(L1,L2,L3)
L3 = L1*L2*L3

# the log likelihood
log_L3 = log(L3)

# We take the partial derivative with respect to our
# parameters and set equal to zero (solve).
#
# the maximum likelihood estimator for mu:
solve(diff(log_L3,mu),mu)

# the maximum likelihood estimator for sigma:
# Note: we can rule out possible solutions by common sense
solve(diff(log_L3,sigma),sigma)

# put possible solutions in dictionary
sol_mu = solve(diff(log_L3,mu),mu,solution_dict=true)

# show one
sol[0][mu]

# sigma
sol_sigma = solve(diff(log_L3,sigma),sigma,solution_dict=true)

# this is our solution
sol_sigma[1][sigma]


# nice latex pdf of functions
view(simplify(L3))
view(simplify(log((L1*L2)).diff(mu)))
view(sol_sigma[1][sigma])




