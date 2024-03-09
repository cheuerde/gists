# Claas Heuer, 2015

#####################################
### including PCAs in BVSR - STAN ###
#####################################


## does not work - stan cant handle indicator variables

# some random data
n = 100
p = 20
y <- rbinom(n,1,0.4)
Z <- matrix(rnorm(n*p),n,p)
X <- matrix(1,n,1)
 
dat = list(N=length(y),Px = ncol(X), Pz = ncol(Z), Z=Z,y=y,X=X)

library(rstan)

hcode = 
"

data { 

  int<lower=0> Px;
  int<lower=0> Pz;
  int<lower=0> N;
  matrix[N,Px] X;
  matrix[N,Pz] Z;
# binomial phenotype
  int<lower=0,upper=1> y[N];

}

parameters {

  vector[Px] beta; // flat prior 
  vector[Pz] u; 
// this gives the lower bound for the variance component
  real<lower=0> tau;

// inclusion probability parameter
  real<lower=0,upper=1> pind; // uniform prior between 0 and 1
  int<lower=0,upper=1> include[Pz];

}


model {

# sample inclusion paramter
  for (k in 1:Pz)
    include[k] ~ bernoulli(pind);

  for (k in 1:Pz)
    u[k] ~ normal(0,tau);

  for (i in 1:N)
    y[i] ~ bernoulli(Phi(X[i] * beta + Z[i] * (u * include)));

  tau ~ cauchy(0,5);

}

"


hlm = stan(model_name="Hierarchical Linear Model", model_code = hcode, data=dat , iter = 10000, verbose = FALSE, chains=1)


