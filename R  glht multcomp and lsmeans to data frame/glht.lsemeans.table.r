# Claas Heuer, September 2015

glht.table <- function(x) {

# I took this from somewehre, but cant remember the source (probably SO))
  pq <- summary(x)$test
  mtests <- cbind(pq$coefficients, pq$sigma, pq$tstat, pq$pvalues)
  error <- attr(pq$pvalues, "error")
  pname <- switch(x$alternativ, less = paste("Pr(<", ifelse(x$df ==0, "z", "t"), ")", sep = ""), 
  greater = paste("Pr(>", ifelse(x$df == 0, "z", "t"), ")", sep = ""), two.sided = paste("Pr(>|",ifelse(x$df == 0, "z", "t"), "|)", sep = ""))
  colnames(mtests) <- c("Estimate", "Std. Error", ifelse(x$df ==0, "z value", "t value"), pname)
  return(mtests)

}


lsmeans.table <- function(x) {

 slm <- summary(x)
 slm_dat <- as.data.frame(slm[])
 return(slm_dat)

}

