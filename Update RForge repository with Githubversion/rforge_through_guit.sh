# Claas Heuer, July 2015

# first get svn
sudo apt-get install subversion

# get the r-forge project:
mkdir project
cd project

svn checkout svn+ssh://cheuer@r-forge.r-project.org/svnroot/cgen/

# get the git version
mkdir git_project
cd git_project

git clone https://github.com/cheuerde/cpgen

# remove r-forge project
svn rm ../cgen/pkg/cpgen

# move git version there
cp -r ./cpgen ../cgen/pkg/

# delete the .git folder
rm -r ./pkg/cpgen/.git

# update the r-forge repository
cd ..
cd cgen

# add all files in one (http://stackoverflow.com/questions/1071857/how-do-i-svn-add-all-unversioned-files-to-svn)
svn add --force * --auto-props --parents --depth infinity -q

# update
svn update

# upload
svn commit -m "git-update"



# upload
svn commit -m "git-folder-remove"


# install the package from R-forge
install.packages("cpgen", repos=c("http://R-Forge.R-project.org",
"http://cran.at.r-project.org"),dependencies=TRUE)





