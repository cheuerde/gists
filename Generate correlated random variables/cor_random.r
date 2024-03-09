# Claas Heuer, 2015
# 
# Generating 2 random vectors 
# that have some given correlation
#

# actually, this is a covariance
cor = 0.98

# sample size
n=100000

# for variables with mean zero and a variance of
# one the covariance is equal to the correlation
y <- scale(rnorm(n))
x <- scale(rnorm(n))

# Multivariate data
Z <- cbind(y,x)

# the covariance matrix
C <- matrix(c(1,cor,cor,1),2,2)

# the correlated data
Z_cor <- Z %*% chol(C)

# extract the correlated vectors
y2 <- Z_cor[,1]
x2 <- Z_cor[,2]

# look at data
plot(y2 ~ x2)
summary(lm(y2~x2))

# rank correaltion
cor(x2,y2,method="pearson")

# overlap in the top 1%
top_n = as.integer(0.01 * n)
sum(order(y2)[1:top_n] %in% order(x2)[1:top_n])/top_n

