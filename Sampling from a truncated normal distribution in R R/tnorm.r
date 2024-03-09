# Claas Heuer, 2015
# Sampling from a truncated normal
# by simply only accepting normal samples 
# in the boundaries given by 'a' and 'b'

tnorm <- function(x = 1, a = -Inf, b = Inf, mean=0, sd=1) {

  y <- rep(0,x)

  for(i in 1:x) {
 
    repeat {
     
      u <- rnorm(1,mean,sd)

      if(u >= a & u <= b) break

    }

    y[i] <- u

  }

  return(y)

}

