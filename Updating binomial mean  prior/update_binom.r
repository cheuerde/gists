# Claas Heuer, 2015

library(rjags)

# some data
n = 1296
p_success <- 0.94
x <- as.integer(p_success*n)
y <- c(rep(1,x),rep(0,n-x))

# priors
# we will use a beta prior for 'p'.
# the beta distribution has mean: a / (a+b).
# we can control the confidence through 'a'.

mu <- 0.9
a <- 500
b <- (a - mu * a) / mu

# take a look at the distribution
w <- rbeta(1000,a,b)
hist(w,breaks=100)

# plot pdf
curve(dbeta(x, a, b), from=0, to = 1.5)


data=list(y=y ,n=n, a=a, b=b)
init=list(p=0.1)
load.module("glm")



modelstring="

  model {

    for (i in 1:n) {

      y[i] ~ dbern(p)

    }

    p ~ dbeta(a,b)

  }

"


model=jags.model(textConnection(modelstring),
                data=data,inits=init)

update(model,n.iter=1000)

output=coda.samples(model=model,
        variable.names=c("p"),
        n.iter=5000,thin=1)


summary(output)
plot(output)
summary(as(output[[1]],"matrix")[,1])











