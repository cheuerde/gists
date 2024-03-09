# cuBLAS/cuBLAS-xt is a full CUDA implementation of BLAS 1-3
# ACML is AMD's BLAS 1-3 optimized for AMD GPUs and fma4-CPUs

### cuBLAS
#
# get cuBLAS (note: non-free, closed source) 
https://developer.nvidia.com/cuda-downloads

# example of how to use: http://devblogs.nvidia.com/parallelforall/drop-in-acceleration-gnu-octave/

# for R do something like:
LD_PRELOAD=libnvblas.so R

### AMD's ACML
#
# get ACML (acml-5-3-1-gfortran-64bit.tgz should work on most systems)
http://developer.amd.com/tools-and-sdks/cpu-development/amd-core-math-library-acml/acml-downloads-resources/

# unpack and use installer-script
# The libraries are located in: /ACML/gfortran64_mp/lib
# Or, if you have an fma4 capable CPU: /ACML/gfortran64_fma4_mp/lib

# invoke R with ACML
LD_PRELOAD=/ACML/gfortran64_mp/lib/libacml_mp.so R






