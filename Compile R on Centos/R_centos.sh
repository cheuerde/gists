# get dependencies

# X11 stuff
sudo yum install libXt-devel
sudo yum install libX11-devel

# readline
sudo yum install readline-devel

# get R
wget http://cran.revolutionanalytics.com/src/base/R-3/R-3.2.0.tar.gz
tar -xf R-3.2.0.tar.gz
cd R-3.2.0

./configure --enable-BLAS-shlib --with-cairo

make -j4

sudo make install


