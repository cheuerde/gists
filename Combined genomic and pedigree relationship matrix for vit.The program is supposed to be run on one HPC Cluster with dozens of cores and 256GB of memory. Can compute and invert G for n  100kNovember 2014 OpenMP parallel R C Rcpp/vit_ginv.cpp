/* Claas Heuer November 2014
Function to compute the inverse of a marker derived
Relationship Matrix. Main functions used here are 'dgemm'
for computing G = MM' and 'dgesv' for inverting G.
*/

#include <iostream>
#include <fstream> 
#include <sstream> 
#include <string>
#include <vector>
#include <stdint.h>
#include <stdlib.h>  
#include <RcppEigen.h>
#include <cblas.h>

/* DGESV prototype */


extern "C" { void dgesv_(int* n, int* nrhs, double* a, int* lda, int* ipiv, double* b, int* ldb, int* info); }

void save_to_file(std::string file_path, Eigen::MatrixXd& Out, bool binary, bool verbose);

// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::export]]
SEXP vit_ginv(SEXP markerfileR, SEXP na_intR, SEXP n_markerR, SEXP skip_elementsR, SEXP stop_atR, SEXP LR, SEXP mafsR, SEXP compute_mafsR, SEXP weightR, SEXP lambdaR, SEXP save_pathR, SEXP add_A22R, SEXP omp_threadsR, SEXP verboseR) {

// get arguments from R
  std::string c_path = Rcpp::as<std::string>(markerfileR);
  std::string save_path = Rcpp::as<std::string>(save_pathR);
  uint64_t cols = Rcpp::as<uint64_t>(n_markerR);
  uint64_t stop_at = Rcpp::as<uint64_t>(stop_atR);
  Eigen::SparseMatrix<double> L = Rcpp::as<Eigen::SparseMatrix<double> >(LR);
  Eigen::RowVectorXd mafs = Rcpp::as<Eigen::RowVectorXd>(mafsR);
  double weight = Rcpp::as<double>(weightR);
  double lambda = Rcpp::as<double>(lambdaR);
  double na_int = Rcpp::as<double>(na_intR);
  bool compute_mafs = Rcpp::as<bool>(compute_mafsR);
  bool add_A22 = Rcpp::as<bool>(add_A22R);
  int omp_threads = Rcpp::as<int>(omp_threadsR);
  bool verbose = Rcpp::as<bool>(verboseR);
  uint64_t rows = 0;
  int skip_elements = Rcpp::as<int>(skip_elementsR);

// set number of openmp/posix threads
  openblas_set_num_threads(omp_threads);

  if(!compute_mafs & mafs.size() != cols) Rcpp::stop("provided mafs have not the same length as cols");

  std::string line;
  std::ifstream f(c_path.c_str());
  if (!f.is_open()) { Rcpp::stop(("error while opening file " + c_path).c_str()); }


// read in the marker matrix
  std::vector<double> X;
  std::string buf;

  if(verbose) Rcpp::Rcout << std::endl << "Reading genotype File" << std::endl << "Individuals read:";

  while(getline(f, line) && (rows < stop_at)) {

    std::stringstream t(line);	
    rows++;
    if(verbose) if((rows % 1000) == 0) Rcpp::Rcout << std::endl << rows;

    for(int i = (skip_elements);i < (cols + skip_elements);++i) {
      buf = line.at(i); 
      X.push_back(atof(buf.c_str())); 
    }
  }

  if(verbose) Rcpp::Rcout << std::endl << "Read " << rows << " Individuals"<< std::endl;

// this is our marker matrix wrapped into an Eigen Object
  Eigen::Map<Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> > M(X.data(),rows,cols);

// compute markerwise means for centering
  Eigen::RowVectorXd mus = Eigen::RowVectorXd::Zero(M.cols());
  Eigen::ArrayXd vars = Eigen::ArrayXd::Zero(M.cols());
  Eigen::ArrayXd not_NA = Eigen::ArrayXd::Zero(M.cols());

  for(int i=0;i<M.cols();++i) {

// compute colwise means
    for(int j=0;j<M.rows();++j) {

      if(M(j,i) != na_int) { 
 
        mus(i) += M(j,i);
        not_NA(i)++;

      }
        
    }

    mus(i) = compute_mafs ? (mus(i) / not_NA(i)) : (mafs(i) * 2);

// impute NAs with mean
    for(int j=0;j<M.rows();++j) {

      if(M(j,i) == na_int) {

        M(j,i) = mus(i);

      } else {

          vars(i) += (M(j,i) - mus(i)) * (M(j,i) - mus(i));

        }

    }

  }


// get variances
  if(compute_mafs) {

    vars /= (not_NA - 1); 

  } else {

      vars = (2*mafs.array()*(1-mafs.array()));

    }

// center
  M.rowwise() -= mus;

// compute A
// this is the matrix to store the genomic relationship matrix (must be initialized with zeros, as it is part of dgemm)
  if(verbose) Rcpp::Rcout << std::endl << "Allocating G" << std::endl;
  Eigen::MatrixXd G;
 
  if(add_A22) {

    if(verbose) Rcpp::Rcout << std::endl << "Computing A22" << std::endl;
    G = Eigen::SparseMatrix<double>(L * L.transpose());

  } else {

      if(verbose) Rcpp::Rcout << std::endl << "A22 omitted, w set to 1.0" << std::endl;
      G = Eigen::MatrixXd::Zero(rows,rows);
      weight=1;

    } 


///////////
// dgemm // Dense Matrix Multiplication: C := alpha*op( A )*op( B ) + beta*C
///////////

// cblas_dgemm doku: http://www.psatellite.com/matrixlib/api/lapack.html & http://docs.oracle.com/cd/E19422-01/819-3691/dgemm.html

// Note: the stride indicates the distance between two elements of adjacent rows/columns,
// so this should be equal to rows(X) for columnmajor

  if(verbose) Rcpp::Rcout << std::endl << "Computing: G* = w(MM') + (1-w)A22" << std::endl;
// compute G
  cblas_dgemm(CblasRowMajor,        // storage order
	      CblasNoTrans,         // first matrix transpose?
	      CblasTrans,           // second matrix transpose?
	      M.rows(),             // The number of rows in the A matrix. Note: the transpose argument matters here!
	      M.rows(),             // The number of columns in the B matrix. Note: the transpose argument matters here!
	      M.cols(),	            // The number of columns in the A matrix.
// We multiply MM' by w and devide by the sum of 2pq
	      weight / vars.sum(),	            // A scalar to multiply by during computation.
              M.data(),             // The data array for the A matrix.
              M.outerStride(),      // The major stride for the A matrix. 
              M.data(),	            // The data array for the B matrix.
              M.outerStride(),	    // The major stride for the B matrix.
              (1-weight),	            // A scalar to multiply C by during the computation.
              G.data(),             // The data array for the C matrix (output).
              G.outerStride());     // The major stride for the C matrix.

// saving G to file:
  save_to_file(save_path + "/G", G, true, verbose);


// compute Ginv
  if(verbose) Rcpp::Rcout << std::endl << "Allocating G*-Inverse" << std::endl;
// this is the matrix to store the inverse of the genomic relationship matrix.
  Eigen::MatrixXd Ginv = Eigen::MatrixXd::Identity(rows,rows);

// shrinkage for G*
  G.array() *= (1.0 - lambda);
  G.diagonal().array() += lambda;
 
  int log;
  int lda = G.rows();
  int nG = G.rows();
  int nrhs = Ginv.cols();
  int * ipiv = new int[G.rows()];

  if(verbose) Rcpp::Rcout << std::endl << "Computing G*-Inverse" << std::endl;

// inverting G*
  dgesv_(&nG,         // order of C
        &nrhs,        // number of RHS
        G.data(),     // symmetric matrix to invert, this becomes the LU factorization
        &lda,         // leading dimension of C
        ipiv,         // verbose
        Ginv.data(),  // RHS, this becomes the solution matrix
        &lda,         // leading dimension RHS
        &log);
       
  delete[] ipiv;


// saving Ginv to file:
  save_to_file(save_path + "/Ginv", Ginv, true, verbose);

// returning the diagonal elements of Ginv
  return Rcpp::wrap(Ginv.diagonal());


}


void save_to_file(std::string file_path, Eigen::MatrixXd& Out, bool binary, bool verbose) {

    if(!binary) {

    if(verbose) Rcpp::Rcout << std::endl << "Saving to file: " << file_path << ".txt" << std::endl;
    std::ofstream file ((file_path + ".txt").c_str());
    if (!file.is_open()) Rcpp::stop("Could not save file to destination");

    file << Out;
    file.close();

    } else {

      if(verbose) Rcpp::Rcout << std::endl << "Saving to file: " << file_path << ".bin" << std::endl;
      std::ofstream file((file_path + ".bin").c_str(), std::ios::out | std::ios::binary);
      if (!file.is_open()) Rcpp::stop("Could not save file to destination");

      std::streampos size = Out.size() * sizeof(Out.data());
      file.write((char *) Out.data(), size);
      file.close();

    }

}



// [[Rcpp::export]]
SEXP read_binary(SEXP file_pathR, SEXP rowsR, SEXP colsR) {

  std::string file_path = Rcpp::as<std::string>(file_pathR);
  uint64_t rows = Rcpp::as<uint64_t>(rowsR);
  uint64_t cols = Rcpp::as<uint64_t>(colsR);
  uint64_t size_in = rows*cols;

  Rcpp::NumericMatrix In(rows,cols);
// read file
  std::ifstream file(file_path.c_str(), std::ios::in | std::ios::binary);
  if (!file.is_open()) Rcpp::stop("Could not save file to destination");
  std::streampos size = size_in * sizeof(In.begin());
  file.seekg (0, std::ios::beg);
  file.read((char *) In.begin(), size);
  file.close();

  return In;


}











