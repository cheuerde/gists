# Centos 6.5 comes with very old packages
# first we need to get git

sudo yum install git

# then update binutils to build OpenBLAS 

# this is also needed 

sudo yum install texinfo

# remove old package (better not)

#sudo yum remove binutils

# get most recent binutils

git clone git://sourceware.org/git/binutils-gdb.git

cd binutils-gdb

./configure

make -j4

sudo make install

# Now get OpenBlas

git clone git://github.com/xianyi/OpenBLAS.git

cd OpenBLAS

make -j4 FC=gfortran USE_THREAD=1 

# install
#make PREFIX=${INSTDIR}/OpenBLAS install

sudo make install





