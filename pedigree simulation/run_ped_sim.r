# Claas Heuer, September 2015
#
# Simple and stupid pedigree simulation. just for software tests

library(cpgen)

# load the function
library(devtools)

# this is from devtools - the argument is the GIST ID
source_gist("a1003eb8644050b40139")

# run
ped <- ped_sim(n = 1000000, n_founders = 1000, generations = 10)

PED <- editPed_fast(label = ped$id, sire = ped$sire, dam=ped$dam)
PED <- pedigreemm::pedigree(label = PED$label, sire = PED$sire, dam = PED$dam)

Ainv <- getAInv_fast(PED)

