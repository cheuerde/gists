# https://github.com/rasmusab/bayesian_first_aid
# http://www.sumsar.net/blog/2014/01/bayesian-first-aid/

# get package
library(devtools)
devtools::install_github("rasmusab/bayesian_first_aid")

library(BayesianFirstAid)
# t-test

n <- 100
x <- rnorm(n, mean = 10)
y <- rnorm(n, mean = -20)

mod <- bayes.t.test(x,y)


