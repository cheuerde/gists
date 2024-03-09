# Claas Heuer, 2015

# Gnumeric can handle excel files just fine.
# it comes with a command line tool to convert excel files to csv files:

ssconvert test.xlsx test.csv


# in R the package 'gdata' can read in excel files for example

library(gdata)
dat <- read.xls("test.xlsx",1,stringsAsFactors=FALSE)

