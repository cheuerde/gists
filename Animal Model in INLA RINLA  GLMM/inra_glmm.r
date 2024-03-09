# Claas Heuer, November 2015

# install the package
install.packages("INLA", repos="http://www.math.ntnu.no/inla/R/stable")

# run a test on BGLR data
library(INLA)
library(BGLR)
data(wheat)

y <- wheat.Y[,1]
Ainv <- solve(wheat.A)
dat <- data.frame(id=1:length(y), y = y)

# run the animal model
mod <- inla(y ~ 1 + f(id, model = "generic2", Cmatrix = Ainv), data = dat)

# extract random effects
u_list <- mod$summary.random

# the random effects also include the residuals
u <- u_list[[1]]$mean[1:length(y)]

# the strength of inla are sparse GLMMs, perfect for that purpose.
# a binomial probit model could look like this
mod_inla <- inla(y ~ 1 + fixed_covariate + fixed_factor + f(id_one, model = "iid") + f(id_two, model = "iid") + f(id_three, model = "iid"), 
		         data = dat, family = "binomial", verbose = FALSE, 
		         control.family = list(link = "probit"), control.predictor = list(compute = TRUE))












