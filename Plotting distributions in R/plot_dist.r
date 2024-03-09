# Claas Heuer, 2015

# plotting distributions (or any function) 
# is straightforward using the 'curve' function

# lets plot the pdf of a normal distribution with mean=0 and sd=1

curve(dnorm(x,0,1),from = -10, to = 10, n = 100)

# 'curve' evaluates the function given as first argument with one unknown over
# a sequence of values flanked by 'from' and 'to'

# plot some function

func <- function(x) x**2
curve(func, from = -100, to = 100, n = 100)

# plot some more distributions

# beta
curve(dbeta(x,2,5),from = 0, to = 1.5, n = 100)

# poisson 
curve(dpois(x,4),from = 0, to = 20, n = 21)

# inv-chi-square
library(LaplacesDemon) # if not available: install_github("ecbrown/LaplacesDemon")
df = 5
scale = 3
curve(dinvchisq(x, df, scale, log=FALSE), from = 0.000001, to = 20, n = 100)

# binomial
curve(dbinom(x,100,0.5),from=0, to = 100, n = 101)



