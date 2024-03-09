! Claas Heuer, 10.11.2014
! Single Site Gibbs Sampler with scalar updating
! for a fixed and a random effect (Ridge Regression).
! Parallelized using MPI

Program gibbs
 
! https://sukhbinder.wordpress.com/fortran-random-number-generation/
! make random.mod module by: f95 -c rand.f90
! compile this program using: gfortran rand.f90  test.f90 -o test.o
! compile main program with MPI:
! you will need mpi: sudo apt-get install mpi-default-dev
! mpif90 rand.f90  gibbs.f90 -o gibbs_fortran.o
! run:  mpirun -n 2 ./gibbs_fortran.o 60000 100 200 1 1

 use rdistributions
 use mpi
 implicit none

! define double precision (parameter = const)
 integer, parameter :: c_dp = 8
 integer n,p,niter,burnin,thin, verbose, omp_threads,iter, effiter_count, effiter
 integer mpi_rank, mpi_size,  totalSize, batchSize, start_mpi, end_mpi, length
 integer :: i,j, status, ierr, seed_size
 integer, dimension(:), allocatable :: seed, sendcount, displacements

 REAL(kind=c_dp) :: mu , sd , mean_y, var_y, var_e, var_a, var_b, ata, ete, scale_a, df_a, scale_e, df_e, var_e_mu , var_a_mu 
 REAL :: start, finish
! define dynamic arrays
 REAL(kind=c_dp), dimension(:,:), allocatable :: M, X
 REAL(kind=c_dp), dimension(:), allocatable :: y, XtX, MtM, ycorr, b, a, b_mu, a_mu, var_a_vec, var_e_vec, y_all

 CHARACTER(len=32) :: arg 

 call MPI_Init ( ierr )
 call MPI_Comm_rank ( MPI_COMM_WORLD, mpi_rank, ierr )
 call MPI_Comm_size ( MPI_COMM_WORLD, mpi_size, ierr )

! arguments
 call getarg(1, arg)
 read (arg, *) n           ! number of observations
 call getarg(2, arg)
 read (arg, *) p           ! number of markers
 call getarg(3, arg)
 read (arg, *) niter       ! number of iterations
 call getarg(4, arg)
 read (arg, *) verbose     ! print timings
 call getarg(5, arg)
 read (arg, *) omp_threads ! number of OpenMP threads

! seed = ichar(arg)     

! Credit: Hao Cheng (ISU)
  totalSize = n
  batchSize = n / mpi_size;
  start_mpi = (mpi_rank) * batchSize + 1
  if((mpi_rank+1)==mpi_size) then 
    end_mpi = totalSize 
    else
      end_mpi = start_mpi + batchSize - 1
  endif 
  length  = end_mpi - start_mpi + 1   

! this is for scattering data from the different processes
! we need to know the start (displacement) and lenghth (receivecount) for every process
 allocate(sendcount(1:mpi_size), stat=status)
 allocate(displacements(1:mpi_size), stat=status)

 call MPI_Allgather(length,1,MPI_INTEGER,sendcount,1,MPI_INTEGER, MPI_COMM_WORLD, ierr);
 call MPI_Allgather(start_mpi,1,MPI_INTEGER,displacements,1,MPI_INTEGER, MPI_COMM_WORLD, ierr);

! if(mpi_rank==0) write(*,*) displacements

! write(*,*) 'start ', start_mpi
! write(*,*) 'length ', length

! dynamically allocate arrays
 burnin = niter / 2
 if(burnin < 1) burnin = 1
 thin = 1
 effiter = (niter - burnin) / thin
 if(effiter < 1) effiter = 1
 effiter_count = 0

 allocate(X(1:length,1), stat=status)
 allocate(M(1:length,1:p), stat=status)
 allocate(y(1:length), stat=status)

 allocate(XtX(1:1), stat=status)
 allocate(MtM(1:p), stat=status)

 allocate(a(1:p), stat=status)
 allocate(a_mu(1:p), stat=status)
 allocate(b(1:1), stat=status)
 allocate(b_mu(1:1), stat=status)

 allocate(var_a_vec(1:effiter), stat=status)
 allocate(var_e_vec(1:effiter), stat=status)

 a_mu = 0
 b_mu = 0

 var_e_mu = 0
 var_a_mu = 0

 mu = 0
 sd = 1

! set seed, not sure exactly how this works
!CALL init_random_seed()
 CALL RANDOM_SEED(size=seed_size)
 ALLOCATE( seed(1:seed_size) )
! CALL RANDOM_SEED(get=seed)
 seed = (/(i, i=1,seed_size, 1)/)
 CALL RANDOM_SEED(PUT=seed)

! put some random values into Z
  do i = 1, length   
    do j= 1, p 
      M(i,j) = rand_normal(mu,sd)
    end do 
  end do

! random phenotype vector
! we let only the root process generate this vector
! and then we send the chunks to the other processes
 allocate(y_all(1:n),stat=status)

 if(mpi_rank == 0) then
   do i = 1, SIZE(y_all)
     y_all(i) = rand_normal(mu,sd)
   end do
 endif

! send chunks of y to the processes
! note: for MPI the first value of an array is indexed with 0 !! that is why 'displacements -1'
! note2: Scatter operations like this split a dataset simply by continous memory.
! so if we want to split a matrix by rows, then this matrix must be stored as rowmajor!!
 call MPI_Scatterv(y_all, sendcount, displacements - 1, MPI_DOUBLE_PRECISION, y, &
 length, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr) 
!write(*,*) y
 ycorr = y
 X = 1

! compute diag(X'X) and diag(M'M)

 do i = 1, SIZE(X,2)
   XtX(i) = sum(X(:,i)**2)
 end do

 do i = 1, SIZE(M,2)
   MtM(i) = sum(M(:,i)**2)
 end do

 call MPI_Allreduce(MPI_IN_PLACE, XtX, SIZE(XtX), MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr);
 call MPI_Allreduce(MPI_IN_PLACE, MtM, SIZE(MtM), MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr);


! compute variances and set initial values
 b = 0
 a = 0

 mean_y = sum(y)
 call MPI_Allreduce(MPI_IN_PLACE, mean_y, 1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr);
 mean_y = mean_y / n

 var_y = sum((y-mean_y)**2)
 call MPI_Allreduce(MPI_IN_PLACE, var_y, 1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr);
 var_y = var_y / (n-1)

 var_a = 0.3 * var_y
 var_e = var_y - var_a
 var_b = var_y * 1000.0

! write(*,*) 'mean(y) ', mean_y
! write(*,*) 'var(y) ', var_y

! priors
 scale_a = 0.003
 df_a = 5;
 scale_e = 1;
 df_e = 5;

! gibbs samling
 do iter = 1, niter

   if(verbose==1) call cpu_time(start)

! fixed effects
   call sample_effects(b, X, XtX, ycorr, var_e, var_b, size(ycorr), size(XtX)) 

! random effects
   call sample_effects(a, M, MtM, ycorr, var_e, var_a, size(ycorr), size(MtM)) 

! sample variances
   ata = sum(a**2)
   var_a = (scale_a * df_a + ata) / rand_chi_square(p + df_a)
   ete = sum(ycorr**2)  
   call MPI_Allreduce(MPI_IN_PLACE, ete, 1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
   var_e = (scale_e * df_e + ete) / rand_chi_square(n + df_e);

! posterior
   if(iter > burnin) then

     if(mod(iter,thin) == 0) then

        effiter_count = effiter_count + 1
        b_mu = b_mu + b;
        a_mu = a_mu + a;
        var_e_mu = var_e_mu + var_e;
        var_a_mu = var_a_mu + var_a;
        var_a_vec(effiter_count) = var_a;
        var_e_vec(effiter_count) = var_e;

      endif

    endif

! verbose
   if(verbose==1 .and. mpi_rank == 0) then

     call cpu_time(finish)
     write(*,*) ' Iteration: |',  iter , '|  var_e: |', var_e,  '|  secs/iter: |', finish-start, '|'

   endif

 end do


! free memory
!deallocate(y, XtX, MtM, ycorr, M, X, stat=status)

call MPI_Finalize ( ierr )

end Program gibbs


! sample effects function
SUBROUTINE sample_effects(b, X, XtX, ycorr, var_e, var_b, n, p) 
  ! Deklaration der formalen Parameter
  use rdistributions
  use mpi
  implicit none 
  INTEGER, intent(in) :: n,p
  REAL(kind=8), intent(in)  :: X(n,p) , XtX(p), var_e, var_b    
  REAL(kind=8), intent(inout) :: b(p), ycorr(n)

! local variables 
  REAL(kind=8) :: temp, rhs, lhs, inv_lhs, mean
  integer i, ierr

! iterate over columns
  do i = 1, SIZE(X,2)  
    temp = b(i)
    rhs = sum(ycorr * X(:,i))
!    rhs = call ddot(size(ycorr), X(:,i), 1, ycorr, 1)  
! reduction of rhs to all processes
    call MPI_Allreduce(MPI_IN_PLACE, rhs, 1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
    rhs = rhs + XtX(i) * temp
    lhs = XtX(i) + var_e / var_b
    inv_lhs = 1.0 / lhs
    mean = inv_lhs*rhs
    b(i) = rand_normal(mean,sqrt(inv_lhs * var_e))
! here we (can) make use of OpenMp/Pthread through the OpenBlas function 'daxpy'
! Note: we don't have to communicate here, ass 'ycorr' is being updated chunkwise 
! by the MPI processes anyways
!    call daxpy(size(ycorr), temp - b(i), X(:,i), 1, ycorr, 1)  
    ycorr = ycorr + X(:,i) * (temp - b(i))
  end do

  return   
end SUBROUTINE sample_effects




















