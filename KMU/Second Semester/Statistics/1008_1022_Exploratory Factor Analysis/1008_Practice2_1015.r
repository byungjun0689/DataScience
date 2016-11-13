
library(psych)
library(dplyr)

bulls <- read.csv("../0924_1001/bulls.csv", stringsAsFactors = F)
#bulls$Breed <- as.factor(bulls$Breed)
#bulls$Frame <- as.factor(bulls$Frame)
str(bulls)

head(bulls,3)

pairs.panels(bulls[,-c(1,2)])

bulls_pca <- prcomp(bulls[,-c(1,2)], scale. = TRUE)

summary(bulls_pca)

bulls_pca$sdev^2

sum(bulls_pca$sdev^2) # 총 분산의 합은 변수가 7개 이므로 7이 된다. 

# 1. 방법
data.frame("고유값"=bulls_pca$sdev^2, row.names =c("PC1","PC2","PC3","PC4","PC5","PC6","PC7"))

# 2. 고유 성징을 이용한 고유값 추출
apply(bulls_pca$x,2,var)

bulls_pca$rotation

summary(bulls_pca) # 현재는 PC2~PC3에서 선택하면 될 것으로 판단됩니다. 

options(repr.plot.width = 5, repr.plot.height=4)
plot(bulls_pca,type="l") 

bulls_pca$rotation[,1:3]

options(repr.plot.width=5, repr.plot.height=5)
biplot(bulls_pca,cex=0.6)

biplot(bulls_pca,cex=0.6, c(2,3))

library(RColorBrewer)
library(ggthemes)
library(ggplot2)

DF <- data.frame(PC1 = bulls_pca$x[,1], PC2= bulls_pca$x[,2], Breed = as.numeric(bulls$Breed))
DF$Breed <- as.factor(DF$Breed)
head(DF)

unique(DF$Breed)

summary(bulls)

bulls[rownames(DF[DF$PC1 < -6,]),]
bulls[rownames(DF[DF$PC2 >3.5,]),]

ggplot(DF, aes(x=PC1,y=PC2)) + geom_point(aes(colour=Breed,shape=Breed))

qqnorm(bulls_pca$x[,1])
qqline(bulls_pca$x[,1])
