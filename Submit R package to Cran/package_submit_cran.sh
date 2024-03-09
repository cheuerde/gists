# Claas Heuer, September 2015
#

# First check your package on your machine ('cpgen' is the package folder)

R CMD check --as-cran cpgen

# Nothing is allowed, not even 'NOTES' (but probably depends, one or two notes might be ok)

# then check again using 'devtools'

R

library(devtools)

# check the package
check("cpgen", cran = TRUE)

# Next check whether it works on Windows.
# Go to: http://win-builder.r-project.org/
# submit the package (http://win-builder.r-project.org/upload.aspx)  and wait for email.
# The mail will be sent to the address mentioned in the DESCRIPTION file

########################################################################
### Check package with R-devel version.                              ###
### This is what they actually do at CRAN when they receive packages ###
########################################################################

# Compile R-devel
# see: https://gist.github.com/04a19c535e75ae4b324e

R-devel

# check the package
check("cpgen", cran = TRUE)



############################
### update a git package ###
### Git - Command Line   ###
############################
# Get a repository:

git clone https://github.com/cheuerde/cpgen

# add something/everything

git add *

# submit changes

git commit -m "what I changed"

# or if that fails:

git commit -a -m "what I changed"

# send to master branch

git push origin master








