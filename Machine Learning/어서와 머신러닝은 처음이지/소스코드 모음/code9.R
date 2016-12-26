build <- read.csv("building.csv" , header = T)
build[is.na(build)] <- 0  
build <- build[-1]
build 

library(arules) 
trans <- as.matrix(build , "Transaction")
rules1 <- apriori(trans , parameter = list(supp=0.2 , conf = 0.6 , target = "rules"))
rules1 

inspect(sort(rules1))

rules2 <- subset(rules1 , subset = lhs %pin% '보습학원' & confidence > 0.7)
inspect(sort(rules2)) 

rules3 <- subset(rules1 , subset = rhs %pin% '편의점' & confidence > 0.7)
rules3
inspect(sort(rules3)) 

#visualization
b2 <- t(as.matrix(build)) %*% as.matrix(build) 
library(sna)
library(rgl)
b2.w <- b2 - diag(diag(b2))
#rownames(b2.w) 
#colnames(b2.w) 
gplot(b2.w , displaylabel=T , vertex.cex=sqrt(diag(b2)) , vertex.col = "green" , edge.col="blue" , boxed.labels=F , arrowhead.cex = .3 , label.pos = 3 , edge.lwd = b2.w*2) 


