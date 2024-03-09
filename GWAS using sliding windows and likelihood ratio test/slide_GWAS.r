# Claas Heuer, September 2015

#####################################################
### Likelihood ratio test for multiple regression ###
#####################################################

slide_GWAS <- function(y, M, X = NULL, verbose = TRUE, sliding_window=TRUE, window_size = 10) {

  library(lmtest)

  if(!is.vector(y) | !is.numeric(y)) stop("y must be a numeric vector")
  if(anyNA(y)) stop("No NAs allowed in y")
  if(class(M)!= "matrix") stop("M must be an object of class 'matrix'")
  if(anyNA(M)) stop("No NAs allowed in M")

  n <- length(y)
  
  if(is.null(X)) X = array(1,dim=c(n,1))
  if(class(X)!= "matrix") stop("X must be an object of class 'matrix'")
  if(anyNA(X)) stop("No NAs allowed in X")

  if(n != nrow(M) | n != nrow(X)) stop("y, M and X must have same length/number of rows")

# this is the null-model
  mod_intercept <- lm(y ~ 1)

# set the windows
  window_size <- as.integer(window_size)

# we run multiple regression in a fixed effects model, so p must be < n
  if(window_size >= (n-1)) {

    window_size = n - 2
    print(paste("window_size was set above available DF, new window_size is: ", window_size,sep=""))

  }


# get the number of windows
  start <- 0
  n_windows = ifelse(sliding_window, as.integer(ncol(M) - window_size + 1), as.integer(ncol(M) / window_size))

# array to store the results	
  res = array(0, dim=c(n_windows,4))		
  colnames(res) <- c("window","start","end","p")		
  end=0	

  res <- as.data.frame(res)
	
  count = 0
		
  for(i in 1:n_windows) {		
	
    count = count + 1	
    if(verbose) print(paste("window: ", i, " out of ", n_windows,sep=""))		

    if(sliding_window) {

      start = count
      end = count + window_size - 1

    } else {

        start = end + 1		
        end = end + window_size		
        if(i == n_windows) end = ncol(M) 

      }
 						
    X <- cbind(1,M[,start:end])
    mod <- lm(y ~ X)
    lr <- lrtest(mod_intercept,mod)		

    res[i,"window"] <- i	
	
    res[i,"start"] <- start		
    res[i,"end"] <- end		
    res[i,"p"] <- lr[2,5]
		
  }

  return(res)

}


