# from the Rfroge manual:

install.packages("mypackage", repos = c("http://R-Forge.R-project.org",
"http://your.nearest.CRAN.mirror.org"), dep = TRUE)

# for example

install.packages("cgenpp", repos=c("http://R-Forge.R-project.org",
"http://cran.at.r-project.org"),dependencies=TRUE)
