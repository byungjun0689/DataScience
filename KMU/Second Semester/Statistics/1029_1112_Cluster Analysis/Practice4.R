
#Clustering Practice : 자료 보면서확인

# 22개 미국 전투기에 대한 6개 변수값이 jet.csv에 저장되어 있다. 각 변수는 아래와 같다.
# -    FFD: 처음 비행 날짜
# -    SPR: 단위무게 당 출력에 비례하는 특정한 출력
# -    RGF: 비행범위 요인
# -    PLF: 비행기의 총 무게의 일부분으로서의 탑재량
# -    SLF: 일관된 무게 요인
# -    CAR: 비행기가 항공모함에 착륙 가능여부
# 1.    계층적군집분석
# # A.    FFD와 CAR를 제외한 변수를 표준화 한 후 계층적 군집화를 시행하고 덴드로그램을 그리시오.
# # B.    A의 결과를 사용해 두 개의 집단으로 관측치를 분류하고 각 집단의 특징을 원변수 관점에서 비교하시오.
# # C.    두 집단을 주성분을 이용해 2차원 산점도로 표현하시오. (즉, 제1 주성분과 제2 주성분을 사용한 산점도에서 두 개의 집단을 서로 다른 마크와 색으로 표현하시오.)
# 2.    비계층적군집분석
# # A.    군집 개수 1~5까지를 사용해 k-means clustering을 시행하고 얻은 within-group sum of squares를 저장하고 그래프로 표현하여 적절한 군집 개수를 판단하시오.
# # B.    K-means clustering을 이용해 2개의 집단으로 군집화하고 그 결과를 1번의 B, C와 같이 탐색하시오.
# 3.    모형기반 군집화를 통해 최적의 군집 개수를 찾고 그 결과를 1번의 B, C와 같이 탐색하시오.
#


# cluster 별로 묶인 데이터 분석 ####
# Group1 : 출력이 적고 비행 범위가 적은 경비행기 또는 단거리 비행기로 판단됩니다.
# Group2 : 출력이 크고 비행범위가 넓으며 무게도 Group1에 비해 많이 나갑니다.( 크기가 크다고 판단.)
# 하지만 적재량이 비슷한 것으로 보아 수송기가 아닌 다른 비행기로 판단됨.
# 조사 결과 전체 전투기를 띄고 있습니다.

library(reshape2)
library(dplyr)
library(psych)
library(ggplot2)
require(gridExtra)

library(RColorBrewer)
library(ggfortify)
library(cluster)

jet = read.csv("jet.csv")
str(jet)
head(jet)

jet_tmp <- jet[,-c(1,2,7)]
rownames(jet_tmp) <- jet[,1]

pairs.panels(jet_tmp)

# scale을 하지 않는다면 sd가 큰 변수에 대해서 영향도가 높아진다.
jet_tmp_s <- as.data.frame(scale(jet_tmp))

round(dist(jet_tmp_s)) # euclidean 거리 측정으로 기본 측정
round(dist(jet_tmp_s, method = "manhattan")) # manhanttan

df <- melt(as.matrix(round(dist(jet_tmp_s))), varnames = c("row", "col"))
df2 <- melt(as.matrix(round(dist(jet_tmp_s, method = "manhattan"))), varnames = c("row", "col"))
df$value2 <- df2$value
df$mean <- (abs(df$value-df$value2)/2)
par(mfrow=c(1,3))
for(i in 3:5){
  boxplot(df[,i], las=2, main=colnames(df[i]), ylim=c(0,10))
}

plot(df$value,df$value2)

man <- as.data.frame(mahalanobis(jet_tmp_s, colMeans(jet_tmp_s), cov(jet_tmp_s)))
# 열의 중심에서 얼마나 떨어져있냐? 공분산 행렬을 통해서
colnames(man) <- "distFromcenter"

# A. 계층적 군집화 수행 ####

par(mfrow=c(1,4))
hc1 <- hclust(dist(jet_tmp_s),method="single")
plot(hc1, main="single")
hc2 <- hclust(dist(jet_tmp_s),method="complete")
plot(hc2, main="complete")
hc3 <- hclust(dist(jet_tmp_s),method="average")
plot(hc3, main="average")
hc4 <- hclust(dist(jet_tmp_s),method="ward.D")
plot(hc4, main="ward.D")
par(mfrow=c(1,1))

# 현재까지는 Complete가 가장 좋은듯. => scale하지 않았다면
# scale 후 ward.D 가 가장 좋은 모델로 판단된다.

# B. 2개의 군집으로 나누어 분석하려면 Complete 모형이 좋다고 판단. (좌우 대칭형이다.) ####

hc2_result <- cutree(hc2,k=2)
hc2_result

jet_tmp_s$cluster <- hc2_result

pairs(jet_tmp_s,col=hc2_result,pch=hc2_result)

tab <- describeBy(jet_tmp_s,group=jet_tmp_s$cluster, mat=T)

gg1 <- ggplot(tab[c(1,2),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SPR") + ylim(c(-2,2))
gg2 <- ggplot(tab[c(3,4),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("RGF") + ylim(c(-2,2))
gg3 <- ggplot(tab[c(5,6),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("PLF") + ylim(c(-2,2))
gg4 <- ggplot(tab[c(7,8),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SLF") + ylim(c(-2,2))

grid.arrange(gg1, gg2,gg3,gg4,ncol=4)

plot(jet_tmp_s$SPR,jet_tmp_s$SLF,pch=jet_tmp_s$cluster,col=jet_tmp_s$cluster,main="계층적 군집분석")
text(jet_tmp_s$SPR,jet_tmp_s$SLF,labels=rownames(jet_tmp_s),cex=0.8,adj=0,pos=4,col=jet_tmp_s$cluster)


# 두 집단을 주성분을 이용해 2차원 산점도로 표현하시오.
# 즉 ( 제 1 주성분과 제2 주성분을 사용한 산점도에서 두 개의 집달을 서로 다른 마크와 색으로 표현)
# PCA 이후 Clustering 한번 더
pca <- prcomp(jet_tmp_s[,-5]) #이미 표준화를 하였기 때문에 scale=T를 수행 할 필요가 없다.
plot(pca,type="l")
table(hc2_result) # 1 : 12, 2:10
summary(pca) # PC2까지 89%를 설명가능하므로 2개를 사용하여도 충분할것으로 판단.

par(mfrow=c(1,2))
qqnorm(pca$x[,1]) # 둘다 정규화
qqline(pca$x[,1])
qqnorm(pca$x[,2])
qqline(pca$x[,2])

par(mfrow=c(1,1))

pca$rotation[,c(1,2)]
# PC1은 RLF을 제외한 나머지 모든 부분에서 영향을 받는다,
# PC2는 PLF에 큰 영향을받고 나머지에는 큰 영향이 없다.
biplot(pca,cex=0.8)

par(mfrow=c(1,2))
barplot(pca$rotation[,1], ylim=c(-1,1))
barplot(pca$rotation[,2], ylim=c(-1,1))
par(mfrow=c(1,1))

#PCA1, PCA2로 DF생성. Row name은 그대로 주고.
jet_pca <- data.frame(PC1 = pca$x[,1], PC2= pca$x[,2])
rownames(jet_pca) <- rownames(jet_tmp_s)

# 여전히 2개의 군집으로 자를때는 complete 형태가 나은 거 같다.
par(mfrow=c(1,4))
hc1 <- hclust(dist(jet_pca),method="single")
plot(hc1, main="single")
hc2 <- hclust(dist(jet_pca),method="complete")
plot(hc2, main="complete")
hc3 <- hclust(dist(jet_pca),method="average")
plot(hc3, main="average")
hc4 <- hclust(dist(jet_pca),method="ward.D")
plot(hc4, main="ward.D")
par(mfrow=c(1,1))

hc2_result <- cutree(hc2,k=2) # 다소 군집이 바뀐형태다.

jet_pca$cluster <- factor(hc2_result)

palette(alpha(brewer.pal(9,'Set1'), 0.5))

plot(jet_pca[,-3], col=as.numeric(jet_pca$cluster), pch=as.numeric(jet_pca$cluster),main="PCA Ploting with clustering")
legend("topright",c("gruop1","group2"), pch=c(1,2), col=c(1,2))
text(jet_pca$PC1,jet_pca$PC2,row.names(jet_pca),cex=0.6,col=as.numeric(jet_pca$cluster),pos=1)

#DF <- data.frame(PC1 = pca$x[,1], PC2= pca$x[,2], Cluster = factor(hc2_result))
ggplot(jet_pca, aes(x=PC1,y=PC2,label = rownames(jet_pca))) + geom_point(aes(colour=jet_pca$cluster,shape=jet_pca$cluster)) + geom_text(nudge_y = 0.5, colour=jet_pca$cluster)

# https://cran.r-project.org/web/packages/ggfortify/vignettes/plot_pca.html
# kmean cluster도 사용가능하다.
autoplot(pca,data=jet_tmp_s,colour='cluster',label=T,shape='cluster', loadings=T,loadings.label = T,loadings.label.size = 3)
#autoplot(fanny(jet_tmp_s[,-5], 2), frame = TRUE)
#autoplot(pam(jet_tmp_s[,-5], 2), frame = TRUE, frame.type = 'norm')


# 2. 비계층적군집분석 ####
# A. 군집개수 1~5개 이용 within-group_sum of squares 를 저장. 그래프로 표현하여 적절한것 찾기. ####

jet_tmp_s <- jet_tmp_s[,-5] # cluster 제외.

result <- c()
for(i in 1:5){
  km <- kmeans(jet_tmp_s,i)
  result[i] <- sum(km$withinss)
}

plot(result,type = "l") # 2개아니면 4개로 표현.
points(result)

# 계층적 군집 분석의 내용으로 보면 complete : 2   ward.D :4개로 표현되면 좋을 것으로 판단된다.
par(mfrow=c(1,4))
hc1 <- hclust(dist(jet_tmp_s),method="single")
plot(hc1, main="single")
hc2 <- hclust(dist(jet_tmp_s),method="complete")
plot(hc2, main="complete")
hc3 <- hclust(dist(jet_tmp_s),method="average")
plot(hc3, main="average")
hc4 <- hclust(dist(jet_tmp_s),method="ward.D")
plot(hc4, main="ward.D")
par(mfrow=c(1,1))

km <- kmeans(jet_tmp_s,2)
jet_tmp_s$cluster <- km$cluster
pairs(jet_tmp_s,col=km$cluster,pch=km$cluster)


tab <- describeBy(jet_tmp_s,group=jet_tmp_s$cluster, mat=T)
gg1 <- ggplot(tab[c(1,2),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SPR") + ylim(c(-2.5,2))
gg2 <- ggplot(tab[c(3,4),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("RGF") + ylim(c(-2.5,2))
gg3 <- ggplot(tab[c(5,6),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("PLF") + ylim(c(-2.5,2))
gg4 <- ggplot(tab[c(7,8),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SLF") + ylim(c(-2.5,2))

grid.arrange(gg1, gg2,gg3,gg4,ncol=4)

plot(jet_tmp_s$RGF,jet_tmp_s$SLF,pch=km$cluster,col=km$cluster,main="Kmean Method")
text(jet_tmp_s$RGF,jet_tmp_s$SLF,labels=rownames(jet_tmp_s),cex=0.8,adj=0,pos=4,col=km$cluster)
points(km$centers[,c(1,2)],col=1:2,pch=4,cex=2)


DF <- data.frame(PC1 = pca$x[,1], PC2= pca$x[,2], Cluster = factor(km$cluster))
ggplot(DF, aes(x=PC1,y=PC2)) + geom_point(aes(colour=Cluster,shape=Cluster))

jet_tmp_s$cluster <- factor(jet_tmp_s$cluster)

autoplot(pca,data=jet_tmp_s,colour='cluster',label=T,shape='cluster', loadings=T,loadings.label = T,loadings.label.size = 3)

# kmeans clustering with pca ####
kmean_pca <- prcomp(jet_tmp_s[,-5],2)
biplot(kmean_pca)


# 3. 모형기반 군집화를 통해 최적의 군집 개수를 찾고
# 그 결과를 1번의 B,C와 같이 탐색하시오 ####

library(mclust)
jet_tmp
mc = Mclust(jet_tmp)
plot(mc)
summary(mc)

#plot모양과 summary() 를 바탕으로 최적의 cluster를 3개로 판단.
mc <- Mclust(jet_tmp,3)
plot(mc)

mc$classification
par(mfrow=c(2,2))
for(i in 1:4){
  boxplot(jet_tmp[,i]~mc$classification, main=names(jet_tmp)[i])
}

par(mfrow=c(1,3))
for(i in 1:3){
  boxplot(jet_tmp[mc$classification==i,],ylim=c(0,10),xlab=paste(i,"Cluster"))
}

tab <- describeBy(jet_tmp,group=mc$classification, mat=T)

gg1 <- ggplot(tab[c(1,2,3),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SPR") + ylim(c(-1,7))
gg2 <- ggplot(tab[c(4,5,6),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("RGF") + ylim(c(-1,7))
gg3 <- ggplot(tab[c(7,8,9),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("PLF") + ylim(c(-1,7))
gg4 <- ggplot(tab[c(10,11,12),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SLF") + ylim(c(-1,7))

grid.arrange(gg1, gg2,gg3,gg4,ncol=4)


#### ======== 정리 지점 ======== ####

# -    SPR: 단위무게 당 출력에 비례하는 특정한 출력
# -    RGF: 비행범위 요인
# -    PLF: 비행기의 총 무게의 일부분으로서의 탑재량
# -    SLF: 일관된 무게 요인


#### 1-A 계층적 군집분석. ####

jet = read.csv("jet.csv")
str(jet)
head(jet)

# 정규화 : 값을 0~1 값으로 가지고 오기 위해서
normalize <- function (x) {
  normalized = (x - min(x)) / (max(x) - min(x))
  return(normalized)
}

jet_tmp <- jet[,-c(1,2,7)]

#jet_s <- sapply(jet_tmp, normalize)
#jet_s <- as.data.frame(jet_s)

jet_s <- scale(jet_tmp)
rownames(jet_s) <- jet[,1]
jet_s <- as.data.frame(jet_s)

pairs(jet_s)
str(jet_s)

par(mfrow=c(1,4))
hc1 <- hclust(dist(jet_s),method="single")
plot(hc1, main="single")
hc2 <- hclust(dist(jet_s),method="complete")
plot(hc2, main="complete")
hc3 <- hclust(dist(jet_s),method="average")
plot(hc3, main="average")
hc4 <- hclust(dist(jet_s),method="ward.D")
plot(hc4, main="ward.D")
par(mfrow=c(1,1))

# 현재까지는 Complete가 가장 좋은듯. => scale하지 않았다면
# scale 후 ward.D 가 가장 좋은 모델로 판단된다.

# 1-B A의 결과를 사용해 두개의 집단으로 관측치를 분류 -> 각 집단의 특징을 원변수 관점에서 비교 . ####
# B. 2개의 군집으로 나누어 분석하려면 Complete 모형이 좋다고 판단. (좌우 대칭형이다.)

hc2_result <- cutree(hc2,k=2)
hc2_result

jet_s$cluster <- hc2_result

tab <- describeBy(jet_s,group=jet_s$cluster,mat=T)

gg1 <- ggplot(tab[c(1,2),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SPR") + ylim(c(-2,2))
gg2 <- ggplot(tab[c(3,4),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("RGF") + ylim(c(-2,2))
gg3 <- ggplot(tab[c(5,6),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("PLF") + ylim(c(-2,2))
gg4 <- ggplot(tab[c(7,8),],aes(x=group1,y=mean)) + geom_bar(position = position_dodge(), stat="identity") + geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se, width=0.1)) + xlab("SLF") + ylim(c(-2,2))

grid.arrange(gg1, gg2,gg3,gg4,ncol=4)

pairs(jet_s[,-5],col=jet_s$cluster,pch=jet_s$cluster)

# 설명 한글로 추가할 것.

# 1-C 두 집단을 주성분을 이용해 2차원 산점도를 표현. ####
# 즉, 제1 주성분과 제 2 주성분을 사용한 산점도에서 두 개의 집단을 서로 다른 마크와 색으로 표현하시오.

jet_pca <- prcomp(jet_s[,-5])
df_pca <- data.frame(PC1 = jet_pca$x[,1], PC2= jet_pca$x[,2], cluster=as.factor(jet_s$cluster))

plot(df_pca[,-3], col=as.numeric(df_pca$cluster), pch=as.numeric(df_pca$cluster),main="PCA Ploting with clustering")
legend("bottomright",c("gruop1","group2"), pch=c(1,2), col=c(1,2))
text(df_pca$PC1,df_pca$PC2,row.names(df_pca),cex=0.6,col=as.numeric(df_pca$cluster),pos=1)
abline(h=0,col="black")
abline(v=0,col="red")

ggplot(df_pca, aes(x=PC1,y=PC2,label = rownames(df_pca))) + geom_point(aes(colour=df_pca$cluster,shape=df_pca$cluster)) + geom_text(nudge_y = 0.5, colour=df_pca$cluster)

autoplot(pca,data=df_pca,colour='cluster',label=T,shape='cluster', loadings=T,loadings.label = T,loadings.label.size = 3)
