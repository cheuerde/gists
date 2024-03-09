// Claas Heuer, 2015

#include <iostream>
#include <string>
#include <vector>
#include <stdint.h>
#include <stdlib.h>  
#include <RcppEigen.h>


// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::export]]
SEXP test(SEXP XR, SEXP YR) {

// get arguments from R

  Eigen::Map<Eigen::MatrixXd> X = Rcpp::as<Eigen::Map<Eigen::MatrixXd> >(XR);
  Eigen::Map<Eigen::MatrixXd> Y = Rcpp::as<Eigen::Map<Eigen::MatrixXd> >(YR);

  Rcpp::NumericMatrix W_out(X.rows(),Y.cols());
  Eigen::Map<Eigen::MatrixXd> W(W_out.begin(),W_out.rows(),W_out.cols());

  W = X*Y;

  return W_out;

}