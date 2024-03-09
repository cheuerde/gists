##########################
# Claas Heuer, Oct. 2014 #
# Approximating pi       #
##########################


# compile C-function
setwd("/home/user/temp")
# clean up
#system("rm -rf *")
# get source file
system("curl -O -s https://gist.githubusercontent.com/cheuerde/54a33c329c02634dd965/raw/6c4cfaab88bd115e5e6851c040149b1d7f1d63cf/compute_pi_R.cpp")
# compile shlib for R 
# note: in order to use OpenMP the file: $HOME/.R/Makevars
# should contain this line: CXXFLAGS = -O2 -fopenmp
system("R CMD SHLIB compute_pi_R.cpp")
dyn.load("compute_pi_R.so")

###################################################
#### Approximating pi by Monte Carlo simulation ###
###################################################
# idea taken from: http://en.wikipedia.org/wiki/Monte_Carlo_method

# radius
r = 5.323

# number of samples
n = 10000

# sample both coordinates from uniform(-r,r)
x = runif(min=-r,max=r,n=n)
y = runif(min=-r,max=r,n=n)

# pythagoras to define whether point lies inside the circle
inside <- (x^2+y^2) <= r^2
circle = sum(inside)
# area of the circle 
area_circle = (2*r)^2 * (circle/n)
area_circle
# estimate of pi from simulation
pi_mc <- area_circle/(r^2)

# plot square with circle in it
plot(x[inside] ~ y[inside],col="black")
points(x[!inside] ~ y[!inside],col="grey")

#################################################
### Approximating pi by numerical integration ###
#################################################

# radius (not too useful here)
r = 1
# how densely shall the interval between 0 and r be populated
interval_density = 10000
# number of threads to use
threads <- as.integer(4)
# estimate pi using the C-function
.Call("cpi",interval_density, r, threads)


