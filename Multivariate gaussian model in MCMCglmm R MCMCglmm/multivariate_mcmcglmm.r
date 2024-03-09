library(MCMCglmm)

n = 10000

x <- rnorm(n)
y <- rnorm(n)

dat <- data.frame(x=x,y=y)
model <- MCMCglmm(cbind(y,x)~ -1 + trait,rcov= ~us(trait):units, data=dat, family=c("gaussian","gaussian"))

# get phenotypic covariance and correlation
V <- model$VCV
cors <- posterior.cor(V[,1:4])

means <- apply(cors,2,mean)
sds <- apply(cors,2,sd)


