# from here: http://doingbayesiandataanalysis.blogspot.com/2012/06/mixture-of-normal-distributions.html

library(rjags)

modelstring <- "
model {
    # Likelihood:
    for( i in 1 : N ) {
      y[i] ~ dnorm( mu[i] , tau[i] ) 
      mu[i] <- muOfClust[ clust[i] ]
      tau[i] <- tauOfClust[clust[i]]
      clust[i] ~ dcat( pClust[1:Nclust] )
    }
    # Prior:
    for ( clustIdx in 1: Nclust ) {
    
      muOfClust[clustIdx] ~ dnorm( 0 , 1.0E-10 )
      tauOfClust[clustIdx] ~ dgamma( 0.01 , 0.01 )
      
    }
    pClust[1:Nclust] ~ ddirch( onesRepNclust )
}
"


# Generate random data from known parameter values:
set.seed(47405)
trueM1 = 100
N1 = 200
trueM2 = 145 # 145 for first example below; 130 for second example
N2 = 200
trueSD = 15
effsz = abs( trueM2 - trueM1 ) / trueSD
y1 = rnorm( N1 ) 
y1 = (y1-mean(y1))/sd(y1) * trueSD + trueM1
y2 = rnorm( N2 ) 
y2 = (y2-mean(y2))/sd(y2) * trueSD + trueM2
y = c( y1 , y2 ) 
N = length(y)

# Must have at least one data point with fixed assignment 
# to each cluster, otherwise some clusters will end up empty:
Nclust = 2
clust = rep(NA,N) 
clust[which.min(y)]=1 # smallest value assigned to cluster 1
clust[which.max(y)]=2 # highest value assigned to cluster 2 
dataList = list(
    y = y ,
    N = N ,
    Nclust = Nclust ,
    clust = clust ,
    onesRepNclust = rep(1,Nclust) 
)


model=jags.model(textConnection(modelstring), data=dataList)

update(model,n.iter=1000)

output=coda.samples(model=model,
        variable.names=c("muOfClust","tau","clust","pClust" ),
        n.iter=1000,thin=1)