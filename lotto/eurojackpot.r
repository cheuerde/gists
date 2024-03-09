# Claas Heuer, September 2015

# first time
first_date <- as.POSIXct(strptime("2015-09-18","%Y-%m-%d"))

# today (we sample again for every new day)
today <- as.POSIXct(strptime(Sys.Date(),"%Y-%m-%d"))

rounds <- as.integer(difftime(today,first_date)) / 7 + 1

seed <- "27092016"

set.seed(seed)

for(i in 1:rounds) five_outof_fifty <- sample(1:50,5,replace=FALSE)

for(i in 1:rounds) two_out_of_10 <- sample(1:10,2,replace=FALSE)


five_outof_fifty

two_out_of_10