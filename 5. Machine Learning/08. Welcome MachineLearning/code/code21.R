require(graphics)
hdata <- read.csv("catalogCrossSell.csv", stringsAsFactors=FALSE)
hdata2 <-subset(hdata, select=-c(CID,Health))
head(hdata2)

h_pca2 = prcomp(hdata2)
barplot(sapply(hdata2, var), horiz=T, las=1, cex.names=0.8)
summary(h_pca2)

biplot(h_pca2 , scale = TRUE , col = "black")
plot(h_pca2 , type = "l")
h_pca2

comp <- data.frame(h_pca2$x[,c(1:4)])
plot(comp, pch=16, col="blue")

library(rgl)
# Multi 3D plot
plot3d(comp$PC1, comp$PC2, comp$PC3)
plot3d(comp$PC1, comp$PC2, comp$PC4)

# Determine number of clusters
wss <- (nrow(comp)-1)*sum(apply(comp,2,var))

for (i in 2:15) wss[i] <- sum(kmeans(comp,centers=i)$withinss)

plot(1:15, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

# From scree plot elbow occurs at k = 3~6
# Apply k-means with k=3~6
k <- kmeans(comp, 4, nstart=25, iter.max=1000)
library(RColorBrewer)
library(scales)
palette(alpha(brewer.pal(9,'Set1'), 0.5))
plot(comp, col=k$clust, pch=16)

# 3D plot
plot3d(comp$PC1, comp$PC2, comp$PC3, col=k$clust)
plot3d(comp$PC1, comp$PC3, comp$PC4, col=k$clust)

# Cluster sizes
sort(table(k$clust))
clust <- names(sort(table(k$clust)))
clust

# First cluster
c1 <- row.names(comp[k$clust==clust[1],])
# Second Cluster
c2 <- row.names(comp[k$clust==clust[2],])
# Third Cluster
c3 <- row.names(comp[k$clust==clust[3],])
# Fourth Cluster
c4 <- row.names(comp[k$clust==clust[4],])

a <- apply(hdata2[c1,] , 2 , sum) 
b <- apply(hdata2[c2,] , 2 , sum) 
c <- apply(hdata2[c3,] , 2 , sum) 
d <- apply(hdata2[c4,] , 2 , sum) 
a;b;c;d

 

 