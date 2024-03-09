####################################################
### Claas Heuer, Sep. 2014                       ###
### Example of performing Gauss-Seidel with      ###
### residual updating using NetCDF stored data.  ###
### Algorithm adopted from: de los Campos (2012) ###
####################################################


# this library allows us to read/write NetCDF files in R
# Note: for compiling (on linux) the netcdf headers are required:
# sudo apt-get install libnetcdf-dev netcdf-bin
# install.packages('ncdf4')
library(ncdf4)

### using ddot and daxpy
# system("curl -O -s https://gist.githubusercontent.com/cheuerde/2f59dd5087e201daee78/raw/1222222c5b4b38c04c55571138da7a962a74f4d0/ddot_daxpy_R.c ")
# system("R CMD SHLIB ddot_daxpy_R.c")
# dyn.load("ddot_daxpy_R.so")


############################################
### Generate data and create NetCDF file ###
############################################

n<-10000
p<-500

# generate some random data (first column intercept)
M <- cbind(1,matrix(rnorm(n*(p-1)),n,(p-1)))
y <- rnorm(n)

# define NetCDF object
dim1 <- ncdim_def("ID","",seq(1,n))
dim2 <- ncdim_def("Marker","",seq(1,p))
varz <- ncvar_def("coefficients","",list(dim1,dim2),missval=-99999999,prec='double')

# create file
netcdf_data <- nc_create("coefficients.nc",varz)
nc_close(netcdf_data)

# fill netcdf file with our Matrix 'M'
netcdf_data <- nc_open("coefficients.nc",write=T)

for(i in 1:p){

  ncvar_put(netcdf_data,"coefficients",start=c(1,i),count=c(-1,1),vals=M[,i])

}

# close connection
nc_close(netcdf_data)

#########################
### Iterative solving ###
#########################

# open netcdf connection 
netcdf_data <- nc_open("coefficients.nc")

# get dimensions
dim <- netcdf_data$var[[1]]$varsize
n <- dim[1]
p <- dim[2]

# iterate over every column in M to get diag(crossprod(M)) and sum of column variances.
# leaving out intercept column
MSx <- 0
xtx <- rep(NA,p)

# intercept
xtx[1] <- n

for(i in 2:p){ 

# read in i-th column
  x = ncvar_get(netcdf_data,start=c(1,i),count=c(-1,1)) 
  xtx[i] <- crossprod(x)
  MSx = MSx + var(x)

}

# get lambda
h2 <- 0.5
var_y <- var(y)
var_e <- (1-h2) * var_y
var_a <- h2 * var_y
lambda <- var_e / (var_a / MSx)

# add lambda to diagonals of M'M (except intercept)
xtx2 <- xtx
xtx2[2:p] <- xtx2[2:p] + lambda

# solution vector
b <- rep(0,p)
b[1] <- mean(y)

# residuals
e <- y - mean(y)

# starting gauss seidel iteration
niter <- 10
verbose = TRUE
for(i in 1:niter){

  for(j in 1:p){

# read the j-th column from netcdf file
    x = ncvar_get(netcdf_data,start=c(1,j),count=c(-1,1))
    tmp.b <- b[j]
#    rhs <- .Call("ddot",x,e) + (xtx[j] * tmp.b)
    rhs <- crossprod(x,e) + (xtx[j] * tmp.b)
    b[j] <- rhs / xtx2[j]
#    .Call("daxpy",x,e,(tmp.b-b[j]))
    e <- e + (x * (tmp.b - b[j]))

  }

if(verbose) print(i)

}

# close connection
nc_close(netcdf_data)


### Get direct solution

XtX <- crossprod(M)
for(i in 2:ncol(XtX)) { XtX[i,i] <- XtX[i,i] + lambda }

b2 <- solve(XtX,crossprod(M,y))[,1]


#########################
### Function for GSRU ###
#########################

# X might be a 'ncdf4' or 'matrix' object.
# lambda (shrinkage) must contain as many items as ncol(X)

cGSRU <- function(y, X=NULL, lambda=NULL, niter=10, verbose=TRUE) {

if(sum(is.numeric(y),is.vector(y)) != 2) stop("y must be a numeric vector")
n=length(y)

if(is.null(X)) X = matrix(1,n,1)
if(!class(X) %in% c("ncdf4","matrix")) stop("'X' must be of class 'ncdf4' or 'matrix'")

# get dimensions and set function for grabbing columns
if(class(X)=="ncdf4"){

  dim <- X$var[[1]]$varsize
  get_x <- function(Xin,column) { return(ncvar_get(Xin,start=c(1,column),count=c(-1,1))) }

} else {

    dim <- dim(X)
    get_x <- function(Xin,column) { return(Xin[,column]) }

  }

nX <- dim[1]
p <- dim[2]

if(nX!=n) stop("'X' must contain as many rows as y")

# lambda
if(!is.null(lambda)) {

  if(length(lambda)!=p) stop("'lambda' must be of same length as ncol(X)'")

} else {

    lambda = rep(0,p)

  }

# computing diagonal of X'X
xtx <- rep(NA,p)

for(i in 1:p){ 

  xtx[i] <- crossprod(get_x(X,i)

}

# add lambda
xtx2 <- xtx + lambda

# solution vector
b <- rep(0,p)

# residuals
e <- y 

#########################
### Iterative solving ###
#########################

niter <- niter
verbose = TRUE
for(i in 1:niter){

  for(j in 1:p){

# read the j-th column from netcdf file
    x = get_x(X,j)
    tmp.b <- b[j]
#    rhs <- .Call("ddot",x,e) + (xtx[j] * tmp.b)
    rhs <- crossprod(x,e) + (xtx[j] * tmp.b)
    b[j] <- rhs / xtx2[j]
#    .Call("daxpy",x,e,(tmp.b-b[j]))
    e <- e + (x * (tmp.b - b[j]))

  }

if(verbose) print(i)

}

return(b)

}