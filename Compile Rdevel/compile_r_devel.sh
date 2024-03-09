# Claas Heuer, September 2015

# set default installation directory:
INSTDIR=$HOME/opt

# place to store the source packages
SOURCES=$HOME/sourcebuilds

###################
### Compiling R ###
###################

cd $SOURCES

# downlad tarball 
wget https://stat.ethz.ch/R/daily/R-devel.tar.gz

# extract tarball
tar -xf R-devel.tar.gz

# change to source directory
cd R-devel

# configure with local prefix and shared-blas
./configure --prefix=${INSTDIR}/R-devel --with-cairo
# compile R as shared library
#./configure --prefix=${INSTDIR}/R_openblas --enable-BLAS-shlib --enable-R-shlib

# compile
make -j4

# install
make install

# create a symbolic link for R-devel

ln -s $INSTDIR/R-devel/bin/R /usr/bin/R-devel