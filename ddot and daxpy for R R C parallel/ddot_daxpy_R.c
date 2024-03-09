### using ddot and daxpy
# system("curl -O -s https://gist.githubusercontent.com/cheuerde/2f59dd5087e201daee78/raw/1222222c5b4b38c04c55571138da7a962a74f4d0/ddot_daxpy_R.c ")
# system("R CMD SHLIB ddot_daxpy_R.c")
# dyn.load("ddot_daxpy_R.so")
#
# in R:
#
# ddot:
# .Call("ddot",x,y)
#
# daxpy:
# .Call("daxpy",x,y,alpha)
#

#include <Rinternals.h>
#include <R_ext/Lapack.h>

SEXP ddot(SEXP xR, SEXP yR){

  double * x = REAL(xR);
  double * y = REAL(yR);
  int n = LENGTH(xR);
  int inc = 1;
  SEXP ans = PROTECT(allocVector(REALSXP, 1));

  REAL(ans)[0] = F77_NAME(ddot)(&n,x,&inc,y,&inc);

  UNPROTECT(1);
  return ans;
          
} 


SEXP daxpy(SEXP xR, SEXP yR, SEXP bR){

  double * x = REAL(xR);
  double * y = REAL(yR);
  int n = LENGTH(xR);
  double b = *REAL(bR);
  int inc = 1;

  F77_NAME(daxpy)(&n, &b, x, &inc, y, &inc);
     
}
