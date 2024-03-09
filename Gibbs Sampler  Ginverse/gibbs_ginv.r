# Claas Heuer, September 2015
#
# References: 
# 1) Rohan Fernando, personal communication (2013)
# 2) Wang, Rutledge and Gianola, 1993 GSE
# 3) Linear Models for the Prediction of Animal Breeding Values, Mrode


'gibbs_ginv' <-function(y, Z = NULL, Ainv, scale_a = 0, df_a = -2, scale_e = 0, df_e = -2, niter = 1000, burnin = 500, h2 = 0.3) {

  n = length(y)
  if(is.null(Z)) Z <- diag(n)

# for block sampling
  x <- rep(0, ncol(Z))

# the breeding values
  u = rep(0,ncol(Z))
  mu <- mean(y)

  mean_mu = rep(0,niter)
  mean_var_a = rep(0,niter)
  mean_var_e = rep(0,niter)
  mean_u = array(0,dim=c(niter,ncol(Z)))

  var_a <- var(y)*h2
  var_e <- var(y)-var_a
          
  Ai11 <- Ainv   
  ztz <- diag(crossprod(Z))
  p <- ncol(Ainv)

# gibbs sampling
  for (iter in 1:niter) {
	
# sample intercept
    mu_ratio = 0
    mu = rnorm(1,sum(y - Z %*% u)/(n+mu_ratio),sqrt(var_e/(n+mu_ratio)))
    mean_mu[iter]<-mu
	
# sample u in one block
	
#L <- chol(var_e*chol2inv(chol((I+(var_e/var_a)*Ainv))))
#temp<-as.vector(solve(L)%*%(y-mu))
#for(i in 1:n){x[i]<-rnorm(1,temp[i],1)}
#u<-as.vector(L%*%x)

    ratio <- var_e/var_a

    for (i in 1:ncol(Z)){

      u[i] = 0.0
      rhs = drop(Z[,i] %*% (y- mu)) - drop(Ai11[,i] %*% (u * ratio))
      lhs <- ztz[i] + Ainv[i,i] * (var_e/var_a)
      inv_lhs <- 1.0 / lhs
      mean <- inv_lhs*rhs
      u[i] <- rnorm(1,mean, sqrt(inv_lhs * var_e))
      mean_u[iter,i] <- u[i]

    }


#sample var_a	
    var_a = as.numeric((t(u)%*%Ainv%*%u + df_a*scale_a)/rchisq(1,p + df_a))
    mean_var_a[iter]=var_a

#sample var_e
    ycorr <- y - mu - Z %*% u
    var_e = as.numeric((t(ycorr)%*%ycorr + df_e*scale_e)/rchisq(1,n + df_e))
    mean_var_e[iter]=var_e

    if(iter%%100==0){print(paste("iter: ",iter,"    var_a: ",var_a,"   var_e: ",var_e))}

  }

  return(list(vara = mean(mean_var_a[burnin:niter]), 
              vare = mean(mean_var_e[burnin:niter]), 
              vara_post=mean_var_a,
              vare_post=mean_var_e,
              mu=mean(mean_mu[burnin:niter]),  
              u = apply(mean_u,2,function(x)mean(x[(burnin+1):niter])), 
              mu_post = mean_mu,
              u_post = mean_u)
         )

}


