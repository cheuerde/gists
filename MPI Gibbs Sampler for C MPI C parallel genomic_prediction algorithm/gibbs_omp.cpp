// Claas Heuer, 2014
// Gibbs Sampler using only OpenMP / Pthreads in OpenBlas

#include <iostream>
#include <chrono>
#include <cblas.h>
#include <Eigen/Eigen>
#include "mt_sampler.h"
#include <omp.h>

//
// compile
// OPENBLAS_PATH=/sfs/fs3/work-sh1/suatt361/opt/OpenBLAS
// EIGEN_INCLUDE=/sfs/fs3/work-sh1/suatt361
// . /opt/intel/impi/4.1.1.036/intel64/bin/mpivars.sh
// export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${OPENBLAS_PATH}/lib
// module load gcc_4.8.2
//
// MPI:
// g++ -std=c++11 -fopenmp -O2 -I${OPENBLAS_PATH}/include -I${EIGEN_INCLUDE} -L${OPENBLAS_PATH}/lib -lopenblas -lpthread -lgfortran gibbs_function_omp.cpp -o gibbs_function_omp.o
//

// prototype for the sampling of regression coefficients
inline void sample_effects(Eigen::VectorXd &b,      // solution vector
                           Eigen::MatrixXd &X,      // Design Matrix
                           Eigen::VectorXd &XtX,    // diag(X'X)
                           Eigen::VectorXd &ycorr,  // current residuals
                           double var_e,            // residual variance
                           double var_b,            // Effect variance
                           sampler &RNG);           // MPI communicator

int main(int argc, char* argv[])
{


// The program expects 5 arguments: n = number of rows,
//                                  p = number of columns,
//                                  niter = number of iterations
//                                  verbose = verbose
//                                  omp_threads = number of omp/posix-threads to use
  if(argc!=6) {

    std::cout << std::endl << " Stop: 5 arguments required" << std::endl << std::endl;
    exit(0);
 
  }

  uint64_t n = atoi(argv[1]);
  uint64_t length = n; 
  uint64_t p = atoi(argv[2]);
  uint64_t niter = atoi(argv[3]);
  bool verbose = atoi(argv[4]);
  uint64_t omp_threads = atoi(argv[5]);

// set number of openmp/posix threads
//  omp_set_num_threads(omp_threads);
  openblas_set_num_threads(omp_threads);


// set number of columns for X and M
  uint64_t p_X = p / 10;
  if(p_X < 1) p_X = 1;
  uint64_t p_M = p;
  if(p_M < 1) p_M = 1;

// MCMC parameters
  uint64_t burnin = niter / 2;
  uint64_t thin = 1;
  uint64_t effiter = (niter - burnin) / thin;
  if(effiter < 1) effiter = 1;
  uint64_t effiter_count = 0;

// This is very important:
// Every MPI process gets the same seed for the random
// number generator, so they will all produce the same results.
// This saves us some MPI_Scatter/Broadcast
  sampler RNG("my_seed");

// Design Matrices
  Eigen::VectorXd y = Eigen::VectorXd::Random(length);
  Eigen::MatrixXd X = Eigen::MatrixXd::Random(length,p_X);
  Eigen::MatrixXd M = Eigen::MatrixXd::Random(length,p_M);

  Eigen::VectorXd XtX = X.colwise().squaredNorm();
  Eigen::VectorXd MtM = M.colwise().squaredNorm();

// residual vector
  Eigen::VectorXd ycorr(y);

// get mean and variance
  double mu = y.sum();
  mu = mu / n;
  double var_y = (y.array() - mu).matrix().squaredNorm();
  var_y = var_y / (n-1);


// solution Vectors
  Eigen::VectorXd b = Eigen::VectorXd::Zero(p_X);
  Eigen::VectorXd a = Eigen::VectorXd::Zero(p_M);

  double var_a;
  double var_e;

  Eigen::VectorXd var_a_vec(effiter);
  Eigen::VectorXd var_e_vec(effiter);

  Eigen::VectorXd b_mu = Eigen::VectorXd::Zero(p_X);
  Eigen::VectorXd a_mu = Eigen::VectorXd::Zero(p_M);
  double var_e_mu = 0;
  double var_a_mu = 0;

// priors
  double scale_a = 0;
  double df_a = -2;
  double scale_e = 0;
  double df_e = -2;

  double var_b = var_y * 1000;

// initial values for variance components
  var_a = var_y * 0.3;
  var_e = var_y - var_a;

// RSS
  double ete;
  double ata;

// timing (http://en.cppreference.com/w/cpp/chrono/duration/duration_cast)
  std::chrono::high_resolution_clock::time_point t0;
  std::chrono::high_resolution_clock::time_point t1;
//  auto t0 = std::chrono::high_resolution_clock::now();
//  auto t1 = std::chrono::high_resolution_clock::now();

////////////////////
// Gibss Sampling //
////////////////////

  for (uint64_t iter=0; iter<niter;iter++) {

// get time
    if(verbose) t0 = std::chrono::high_resolution_clock::now();

// fixed effects
    sample_effects(b, X, XtX, ycorr, var_e, var_b, RNG);

// Marker effects
    sample_effects(a, M, MtM, ycorr, var_e, var_a, RNG);

// sample variances
    ata = cblas_ddot(a.size(), a.data(), 1, a.data(), 1);
    var_a = (scale_a * df_a + ata) / RNG.rchisq(p_M + df_a); 
    ete = cblas_ddot(ycorr.size(), ycorr.data(), 1, ycorr.data(), 1);   
    var_e = (ete + scale_e * df_e) / RNG.rchisq(n + df_e);

// posterior
    if(iter >= burnin) {

      if((iter%thin) == 0) {

        b_mu += b;
        a_mu += a;
        var_e_mu += var_e;
        var_a_mu += var_a;
        var_a_vec(effiter_count) = var_a;
        var_e_vec(effiter_count) = var_e;
        effiter_count++;

      }

    }

// verbose
    if(verbose) {

      t1 = std::chrono::high_resolution_clock::now();
                        std::cout << std::endl 
                                  << " Iteration: |" << iter + 1 
                                  << "|  var_e: |" << var_e  
                                  << "|  secs/iter: |" << std::chrono::duration_cast<std::chrono::milliseconds>(t1-t0).count() / 1000.0 
                                  << "|" << std::endl;

    }

  }


               
};



// this functions samples regression coefficients using
// MPI through the communicator 'comm'
inline void sample_effects(Eigen::VectorXd &b,      // solution vector
                           Eigen::MatrixXd &X,      // Design Matrix
                           Eigen::VectorXd &XtX,    // diag(X'X)
                           Eigen::VectorXd &ycorr,  // current residuals
                           double var_e,            // residual variance
                           double var_b,            // Effect variance
                           sampler &RNG) {        // MPI communicator

  for (uint64_t i=0;i<X.cols();i++) {

      double temp = b(i);
// here we (can) make use of OpenMp/Pthread through the OpenBlas function 'ddot'
      double rhs = cblas_ddot(ycorr.size(), &X(0,i), 1, ycorr.data(), 1);  
//      double rhs = 0;
// reduction of rhs to all processes
      rhs += XtX(i) * temp;
      double lhs = XtX(i) + var_e / var_b;
      double inv_lhs = 1.0 / lhs;
      double mean = inv_lhs*rhs;
      b(i) = RNG.rnorm(mean,sqrt(inv_lhs * var_e));
// here we (can) make use of OpenMp/Pthread through the OpenBlas function 'daxpy'
// Note: we don't have to communicate here, ass 'ycorr' is being updated chunkwise 
// by the MPI processes anyways
      cblas_daxpy(ycorr.size(), temp - b(i), &X(0,i), 1, ycorr.data(), 1);  

  }

}











