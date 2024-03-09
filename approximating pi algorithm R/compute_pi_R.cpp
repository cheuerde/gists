#include <stdint.h>
#include <Rinternals.h>

#ifdef _OPENMP
  #include <omp.h>
#else 
  #define omp_set_num_threads(x) 1
#endif

// template for estimating pi based on
// radius of circle (rR) and number of
// intersections for the grid (nR) which
// will define the precision of approximation.

template<typename T_float,typename T_int>
SEXP get_pi(SEXP nR, SEXP rR)

{

T_float r = *REAL(rR);
T_float rsq = r*r;
T_int n = *REAL(nR);
T_float n_doub = static_cast<T_float>(n);
T_int circle = 0;

T_float * x = new T_float[n];
T_float * xsq = new T_float[n];
T_float steps = r / (n_doub - 1);



// make steps
x[0] = 0;
x[n-1] = r;

for(T_int i=1;i<(n-1);++i) { x[i] = x[i-1] + steps; }

// get squared values and diagonals inside circle
#pragma omp parallel for reduction(+:circle) 
for(T_int i=0;i<n;++i) { 

  xsq[i] = x[i] * x[i]; 
  if((xsq[i] + xsq[i]) <= rsq) circle++;

}


// get offdiagonals inside circle
for(T_int i=0;i<(n-1);++i) {

#pragma omp parallel for reduction(+:circle) 
  for(T_int j=(i+1);j<n;++j) {

    if((xsq[i] + xsq[j]) <= rsq) circle += 2;
 
  }

}


T_float circle_doub = static_cast<T_float>(circle);

T_float area_circle = (rsq * (circle_doub/(n_doub * n_doub))) * 4.0;
T_float pi = area_circle / rsq;

delete[] x;
delete[] xsq;

SEXP ans = PROTECT(allocVector(REALSXP, 1));
REAL(ans)[0] = pi;
UNPROTECT(1);

return(ans);

};


// function that uses 'get_pi' template.
// returns estimate of 'pi' as SEXP,
extern "C" {

  SEXP cpi(SEXP nR, SEXP rR, SEXP threadsR) {

  omp_set_num_threads(*INTEGER(threadsR));
  return get_pi<double, uint64_t>(nR,rR);

  }

}


