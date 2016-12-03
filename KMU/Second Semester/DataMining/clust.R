# Required packages
install.packages("cluster")
install.packages("NbClust") 
install.packages("kohonen")
install.packages("ggplot2")
install.packages("gridExtra")
install.packages("scales")
library(cluster)
library(NbClust)
library(kohonen)
library(ggplot2)
library(gridExtra)
library(scales)

# Read Data
cdata <- read.delim("Cluster.txt", stringsAsFactors=FALSE)
head(cdata)

##### K-means Clustering with R

# 군집수를 4로 하는 k-means clustering
set.seed(1)
km <- kmeans(subset(cdata, select=-c(ID)), centers=4)
str(km)
km

# 군집의 반경과 관계를 2차원으로 도식
clusplot(subset(cdata, select=-c(ID)), km$cluster)

# 군집의 분포를 도식
cdata$cluster <- as.factor(km$cluster)
qplot(MONEY, VISIT, colour=cluster, data=cdata)
plot(subset(cdata, select=-c(ID,cluster)), col=km$cluster)

# 군집별로 각 군집화변수의 밀도를 도식: 방법1
p1 <- qplot(MONEY, fill=cluster, alpha=.5, data=cdata, geom="density") + scale_alpha(guide="none")
p2 <- qplot(VISIT, fill=cluster, alpha=.5, data=cdata, geom="density") + theme(legend.position="none")
p3 <- qplot(CROSS, fill=cluster, alpha=.5, data=cdata, geom="density") + theme(legend.position="none")
p4 <- qplot(API, fill=cluster, alpha=.5, data=cdata, geom="density") + theme(legend.position="none")
grid.arrange(p1, p2, p3, p4, ncol=2, nrow=2)

# 군집별로 각 군집화변수의 밀도를 도식: 방법2
p1 <- ggplot(cdata, aes(MONEY)) + geom_density(fill='deeppink3', adjust=1) + facet_grid(. ~ cluster) + scale_x_continuous(breaks=NULL) + scale_y_continuous("", breaks=NULL)
p2 <- ggplot(cdata, aes(VISIT)) + geom_density(fill='deeppink3', adjust=1) + facet_grid(. ~ cluster) + scale_x_continuous(breaks=NULL) + scale_y_continuous("", breaks=NULL) + theme(strip.text.x=element_blank())
p3 <- ggplot(cdata, aes(CROSS)) + geom_density(fill='deeppink3', adjust=1) + facet_grid(. ~ cluster) + scale_x_continuous(breaks=NULL) + scale_y_continuous("", breaks=NULL) + theme(strip.text.x=element_blank())
p4 <- ggplot(cdata, aes(API)) + geom_density(fill='deeppink3', adjust=1) + facet_grid(. ~ cluster) + scale_x_continuous(breaks=NULL) + scale_y_continuous("", breaks=NULL) + theme(strip.text.x=element_blank())
grid.arrange(p1, p2, p3, p4, ncol=1, nrow=4)

# 군집의 크기를 도식
x <- ggplot(cdata, aes(x=factor(1), fill=cluster))
x + geom_bar(width=1) + coord_polar(theta="y")

# 최적의 군집 수 찾기: 방법1
set.seed(1)
sd <- cdata[sample(1:nrow(cdata),100),-1]
d <- dist(sd, method = "euclidean")
fit <- hclust(d, method="ave")
plot(fit)
rect.hclust(fit, k=4, border = "red")


# 최적의 군집 수 찾기: 방법2
wss <- 0; set.seed(1)
for(i in 1:15) wss[i] <- kmeans(subset(cdata, select=-c(ID)), centers=i)$tot.withinss
plot(1:15, wss, type="b", xlab="# of clusters", ylab="Within group sum of squares")

# 최적의 군집 수 찾기: 방법3
nc = NbClust(subset(cdata, select=-c(ID,cluster)), min.nc=2, max.nc=15, method='kmeans')
barplot(table(nc$Best.nc[1,]), xlab="# of clusters", ylab="# of criteria", main="Number of clusters chosen by 26 criteria")


##### SOM Clustering with R

cdata <- read.delim("Cluster.txt", stringsAsFactors=FALSE)

# 데이터 정규화
cdata.n <- scale(subset(cdata, select=-c(ID)))

# 그리드를  3 x 3으로 하는 SOM clustering
set.seed(1)
sm <- som(data = cdata.n, grid = somgrid(3, 3, "rectangular"))
str(sm)

# SOM 시각화
plot(sm, main = "feature distribution")
plot(sm, type="counts", main = "cluster size")
plot(sm, type="quality", main = "mapping quality")

coolBlueHotRed <- function(n, alpha = 1) {
  rainbow(n, end=4/6, alpha=alpha)[n:1]
}
for (i in 1:ncol(sm$data))
  plot(sm, type="property", property=sm$codes[,i], main=dimnames(sm$data)[[2]][i], palette.name=coolBlueHotRed)

# ggplot2 패키지를 이용하여 SPSS Modeler와 유사한 Grid 도식
cdata$clusterX <- sm$grid$pts[sm$unit.classif,"x"]
cdata$clusterY <- sm$grid$pts[sm$unit.classif,"y"]
p <- ggplot(cdata, aes(clusterX, clusterY))
p + geom_jitter(position = position_jitter(width=.2, height=.2))
