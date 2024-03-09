
#include <iostream>
#include <string>
#include <vector>
#include <stdint.h>
#include <stdlib.h>  
#include "/home/claas/Eigen-devel/Eigen"
#include <Rcpp.h>

// [[Rcpp::depends(Rcpp)]]
// [[Rcpp::export]]
SEXP test2(SEXP XR, SEXP YR) {

// get arguments from R
//  Eigen::Map<Eigen::MatrixXd> X = Rcpp::as<Eigen::Map<Eigen::MatrixXd> >(XR);
//  Eigen::Map<Eigen::MatrixXd> Y = Rcpp::as<Eigen::Map<Eigen::MatrixXd> >(YR);

  Rcpp::NumericMatrix X(XR);
  Rcpp::NumericMatrix Y(YR);

  Eigen::Map<Eigen::MatrixXd> X2(X.begin(),X.rows(),X.cols());
  Eigen::Map<Eigen::MatrixXd> Y2(Y.begin(),Y.rows(),Y.cols());

  Rcpp::NumericMatrix W_out(X2.rows(),Y2.cols());
  Eigen::Map<Eigen::MatrixXd> W(W_out.begin(),W_out.rows(),W_out.cols());
  

  W = X2*Y2;

  return W_out;

}