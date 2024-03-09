###############################################
### How to link R against OpenBLAS on a Mac ###
###############################################


# this will install brew to /usr/local
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew doctor

# install needed software
brew install wget

# gnu compiler (version 4.9.1 (oct. 2014))
# note: if gnu compiler >= 4.7.1 already exists, you can skip this step
# check with: gcc -v

# brew install gcc --no-multiarch
brew install gcc 

##########################
### Compiling OpenBLAS ###
##########################

# set default installation directory:
INSTDIR=$HOME/opt
 
# place to store the source packages
SOURCES=$HOME/sourcebuilds

# make dirs (if they dont exist)
mkdir $INSTDIR
mkdir $SOURCES
cd $SOURCES
 
# make sure current GNU compiler is being used
export CC=gcc-4.9 
export CXX=g++-4.9
export FC=gfortran-4.9
 
# download tarball
wget http://github.com/xianyi/OpenBLAS/tarball/v0.2.11
 
# extract tarball
mv v0.2.11 v0.2.11.tar.gz
tar -xf v0.2.11.tar.gz
rm v0.2.11.tar.gz
 
# change to openblas directory and compile
cd xianyi-OpenBLAS-ea8d4e3
 
# make with multiple threads (option: -j[num_threads], e.g.: "make -j4" to compile with 
# four threads at the same time; Option 'USE_THREAD=1' forces OpenBLAS to compile threaded library
 
# compile
make -j4 USE_THREAD=1 
 
# install
make PREFIX=${INSTDIR}/OpenBLAS install

# remove temp folders
cd
rm -rf $SOURCES

##################################
### Linking R against OpenBlas ###
##################################

# here we replace the symbolic link located in R's library folder
# with a link to our newly compiled OpenBlas

ln -sf ${HOME}/opt/OpenBLAS/lib/libopenblas.dylib /Library/Frameworks/R.framework/Resources/lib/libRblas.dylib

# R is now linked against OpenBlas
