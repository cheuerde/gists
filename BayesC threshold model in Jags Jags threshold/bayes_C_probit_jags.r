# Claas Heuer, 2015
# 
# Inspired from: https://darrenjw.wordpress.com/2012/11/20/getting-started-with-bayesian-variable-selection-using-jags-and-rjags/

library(rjags)

# some random data
n = 100
p = 20
y <- rbinom(n,1,0.4)
Z <- matrix(rnorm(n*p),n,p)
 


data=list(y=y, X=Z ,n=n,p=p)
init=list(alpha=0, betaT=rep(0,p), pind=0, ind=rep(0,p), tau=1)
load.module("glm")



modelstring="

  model {

    for (i in 1:n) {

      y[i] ~ dbern(prob[i])
      probit(prob[i]) <- alpha + inprod(X[i,],beta)

    }

    for (j in 1:p) {

      ind[j] ~ dbern(pind)
      betaT[j] ~ dnorm(0,tau)
      beta[j] <- ind[j] * betaT[j]

    }

    tau ~ dgamma(1,0.001)
    alpha ~ dnorm(0,0.0001)
    pind ~ dunif(0,1)

  }

"


model=jags.model(textConnection(modelstring),
                data=data,inits=init)

update(model,n.iter=1000)

output=coda.samples(model=model,
        variable.names=c("alpha","betaT","ind","pind","tau"),
        n.iter=5000,thin=1)
