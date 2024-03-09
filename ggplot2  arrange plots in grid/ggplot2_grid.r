library(ggplot2)
library(reshape2)
library(gridExtra)

dat <- read.csv("dat.csv",header=TRUE,stringsAsFactors=FALSE)

# make flat file
D <- melt(dat, id.vars=c("Reg.No.Id"),measure.vars=c("Tpi","Pl","Dpr"))

# make the graphs
# we have to do split plots

p1 <- ggplot(D[D$variable=="Tpi",],aes(value)) 
p1 <- p1 + geom_histogram(binwidth=3) + facet_wrap(~ variable)

p2 <- ggplot(D[D$variable=="Pl",],aes(value)) 
p2 <- p2 + geom_histogram(binwidth=0.1) + facet_wrap(~ variable)

p3 <- ggplot(D[D$variable=="Dpr",],aes(value)) 
p3 <- p3 + geom_histogram(binwidth=0.1) + facet_wrap(~ variable)
 

pdf("densities.pdf", width=12,height=8)
grid.arrange(p1,p2,p3,ncol=3)
dev.off()
