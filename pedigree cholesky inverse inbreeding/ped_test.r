library(pedigreemm)

data <- 
"Animal Sire Dam
    1    0   0
    2    1   0
    3    1   0
    4    1   0
    5    3   2
    6    3   4
    7    5   6 
    8    7   6
    9    8   6
    10   9   6
    11   10  6"

# selfing

data <- 
"Animal Sire Dam
    1    0   0
    2    1   1
    3    2   2
    4    3   3
    5    4   4
    6    5   5
    7    6   6 
    8    7   7
    9    8   8
    10   9   9
    11   10  10"

ped <- read.table(textConnection(data), header=T)
for(i in 1:ncol(ped)) ped[ped[,i]==0,i] <- NA
ped <- editPed(label=ped[,1],sire=ped[,2],dam=ped[,3])
PED <- pedigreemm::pedigree(label=ped$labe, sire=ped$sire, dam=ped$dam)


####

A <- getA(PED)
Ainv <- getAInv(PED)
L <- relfactor(PED)

founders <- (1:length(PED@label))[is.na(PED@sire) & is.na(PED@dam)]

sub1 <- sample((1:length(PED@label))[-founders], 3, replace=FALSE)
#sub1 <- c(sub1,1)
#sub1 <- 1:100
#sub1 <- (length(PED@label) - 99) : length(PED@label)
sub2 <- (1:length(PED@label))[-sub1]


A11 <- A[sub1,sub1]
A22 <- A[sub2,sub2]
A12 <- A[sub1,sub2]
A21 <- A[sub2,sub1]


E <- A11 - (A12 %*% solve(A22,A21))

# check 

summary(as.vector(solve(solve(A)[sub1,sub1])))
summary(as.vector(E))

#L11 <- chol(A)[sub1,sub1]
L11 <- L[sub1,sub1]

a <- as(E,"matrix")
b <- as(crossprod(L11),"matrix")
c <- as(solve(Ainv[sub1,sub1]),"matrix")

all.equal(matrix(a),matrix(b))
cor(as.vector(a),as.vector(b))






