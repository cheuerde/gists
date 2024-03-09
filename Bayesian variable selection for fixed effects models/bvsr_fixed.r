# Claas Heuer, 2015
#
# Inspired from: https://darrenjw.wordpress.com/2012/11/20/getting-started-with-bayesian-variable-selection-using-jags-and-rjags/

#############################################
### BVSR for fixed effects model in rjags ###
#############################################

library(rjags)

data(airquality)
y = airquality$Ozone

X <- model.matrix(Ozone~ -1 + ., data=airquality)

hasNA <- apply(airquality,1,anyNA)
y <- y[!hasNA]

n = length(y)
p=ncol(X)

data=list(y=y,X=X,n=n,p=p)
init=list(alpha=0, betaT=rep(0,p), pind=0, ind=rep(0,p), resid=1)
load.module("glm")



modelstring="

  model {

    for (i in 1:n) {

      y[i] ~ dnorm(alpha + inprod(X[i,],beta), resid)

    }

    for (j in 1:p) {

      ind[j] ~ dbern(pind)
      betaT[j] ~ dnorm(0,0.0001)
      beta[j] <- ind[j] * betaT[j]

    }

    pind ~ dunif(0,1)
    resid ~ dgamma(1,0.001)
    alpha ~ dnorm(0,0.0001)
    e <- 1/resid

  }

"


model=jags.model(textConnection(modelstring),
                data=data,inits=init)

update(model,n.iter=50000)

output<-coda.samples(model=model,
        variable.names=c("alpha","betaT", "beta","ind","pind","resid","e"),
        n.iter=100000,thin=1)

print(summary(output))
#plot(output)


### standard linear model 

mod <- lm(Ozone~ ., data=airquality)

