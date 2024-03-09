### Download the most recent source package
curl -L -o master.zip https://github.com/cheuerde/cpgen/archive/master.zip

# Extract source package
unzip master.zip
mv cpgen-master cpgen

HAS_MV=true
# check if Makevars-file exists
if [ ! -e ${HOME}/.R/Makevars ];then mkdir ${HOME}/.R; 
touch ${HOME}/.R/Makevars ; HAS_MV=false; fi
cat ${HOME}/.R/Makevars > Makevars_temp

# set flags for default compiler to gcc/g++
echo CC=gcc > ${HOME}/.R/Makevars 
echo CXX=g++ >> ${HOME}/.R/Makevars 

# paste flags into Makevars-file
PL='PKG_LIBS = -fopenmp -lgomp `$(R_HOME)/bin/Rscript -e '
PL=${PL}'"Rcpp:::LdFlags()"`'
PCF='PKG_CXXFLAGS = -std=c++11 -fopenmp '
PCF=${PCF}'`$(R_HOME)/bin/Rscript -e "Rcpp:::CxxFlags()"`'  
echo $PL > cpgen/src/Makevars
echo $PCF >> cpgen/src/Makevars 

# remove c++11 system requirement
sed -e 's/C++11/ /g' cpgen/DESCRIPTION > temp
cat temp > cpgen/DESCRIPTION
rm temp

# Build and install the package
R CMD build cpgen
R CMD INSTALL cpgen_0.1.tar.gz

# restore old Makevars-file
if $HAS_MV; then
  cat Makevars_temp > ${HOME}/.R/Makevars
    else
      rm ${HOME}/.R/Makevars
            fi
rm Makevars_temp
rm -r cpgen
rm master.zip
