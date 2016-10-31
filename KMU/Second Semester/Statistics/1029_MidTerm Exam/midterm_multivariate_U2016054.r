
library(psych)
library(ggplot2)
library(dplyr)

Cereal <- read.csv("cereal.csv", stringsAsFactors = F)
Cereal_s <- Cereal[,-1]
Cereal_s <- as.data.frame(Cereal_s)
rownames(Cereal_s) <- Cereal[,1]
Cereal_s <- rename(Cereal_s,Carbon=Carbonhydrates)
head(Cereal_s)

library(RColorBrewer)
matrix_Cereal <- as.matrix(Cereal_s[,-1])
heatmap(matrix_Cereal, scale="column", col=brewer.pal(9,"Blues"))

stars(Cereal_s[,-1],cex=0.7, key.loc=c(15,1.5),scale =T,draw.segments = TRUE)

pairs.panels(Cereal_s[,-1])

Cereal_s[Cereal_s$Fiber > 8, ]
which(Cereal_s$Fiber > 8)
Cereal_s[Cereal_s$Fat > 2.5, ]
which(Cereal_s$Fat > 2.5)
Cereal_s[Cereal_s$Carbon == 1, ]
which(Cereal_s$Carbon == 1)

clr=rep(1,dim(Cereal_s)[1])
clr[c(18,43,22)]=2
pairs(Cereal_s[,-1],col=clr,pch=clr)


Cereal_s2<-Cereal_s[-c(18,43,22),] # 이상치 제거 
pairs.panels(Cereal_s2[,-1])   # cor: 0.62

pca = prcomp(Cereal_s2[,-1],scale=T)  # 상관계수로 주성분 분석을 한다. scale된 변수로 (평균0 표편1)
summary(pca)

plot(pca, type="l")

rotation <- as.data.frame(pca$rotation[,1:4])
rotation

par(mfrow=c(4,1))
barplot(pca$rotation[,1], xlab="PC1") 
# 주성분 PC1은 단백질, 지방, 섬유소, 탄수화물, 칼륨을 기준으로 분류를 한다. 
# 단백질, 지방, 섬유소, 칼륨과는 음의 관계를 가진다. 
# 반면 탄수화물과는 양의 관계를 가진다. 

barplot(pca$rotation[,2], xlab="PC2") 
# 칼로리, 설탕과 강한 관계를 가지며 양의 관계를 가지고 있다.
# 지방, 나트륨과 도 관계는 있지만 약한 관계이며 또한 양의 관계를 가지고 있다.
# 단백질과 섬유소는 적은 관계와 음의 관계를 가진다.

barplot(pca$rotation[,3], xlab="PC3")
# 나트륨과 탄수화물에 강한 관계와 양의 관계를 가진다.
# 설탕과도 강한 관계를 가지지만 음의 관계를 가진다. 

barplot(pca$rotation[,4], xlab="PC4")
# 지방과 강한 음의 관계를 가지고 있다.
# 단백질과는 약한 음의 관계를 가지고, 섬유소, 설탕, 칼륨과는 약 양의 관계를 가진다. 

describe(Cereal_s2[,-1])

par(mfrow=c(4,1))
tmp <- Cereal_s2
tmp$shape <- ifelse(tmp$Potassium > 76,1,2) 
plot(pca$x[,1],pca$x[,2], col=tmp$shape, xlab="Potassium")
tmp$shape <- ifelse(tmp$Carbon >14.88, 1,2) 
plot(pca$x[,1],pca$x[,2], col=tmp$shape, xlab="Carbon")
tmp$shape <- ifelse(tmp$Sodium >184,1,2) 
plot(pca$x[,3],pca$x[,4], col=tmp$shape, xlab="Sodium")
tmp$shape <- ifelse(tmp$Fat >0.90,1,2) 
plot(pca$x[,3],pca$x[,4], col=tmp$shape, xlab="Fat")

par(mfrow=c(1,1))
pairs(Cereal_s[,-1],col=clr,pch=clr)

describeBy(pca$x[,1:4],group=Cereal_s2[,1])

library(ggplot2)
DF <- data.frame(PC1 = pca$x[,1], PC2= pca$x[,2], Manu = as.factor(Cereal_s2$Manufacturer))
DF2 <- data.frame(PC3 = pca$x[,3], PC3= pca$x[,4], Manu = as.factor(Cereal_s2$Manufacturer))
par(mfrow=c(1,1))
ggplot(DF, aes(x=PC1,y=PC2)) + geom_point(aes(colour=Manu,shape=Manu))
ggplot(DF2, aes(x=PC3,y=PC3)) + geom_point(aes(colour=Manu,shape=Manu))


biplot(pca)
biplot(pca,choices = c(3,4))

qqnorm(pca$x[,1])
qqline(pca$x[,1])
library(GPArotation)
library(psych)

# 2번 문제 
thur <- Thurstone.33
str(thur)
head(thur)

fa <- factanal(covmat = as.matrix(thur), factors=3)
print(fa,digits=2,order=T)

# 사회 과학문제에서 총분산 60% 정도까지 포함 
# 결과를 일반화 하는데 더 관심이 있다면 직교회전 사용 
# 직교회전 전 하나의 원 변수에 부하 값이 큰 인자가 2개 이상 존재하는 경우
fa2 <- factanal(covmat = as.matrix(thur), factors=3, rotation="Promax") 
print(fa2,digits=2,order=T)


s_load <- fa2$loadings
plot(s_load, type="n") # 점을 찍지 않으려고 type="n" none을 함.
text(s_load, labels=colnames(thur), cex=0.7)


# 원변수와 가장 설명이 안되는 원변수
fa2$uniquenesses

# 데이터의 변동을 설명하는 변수의 비율은 
# fa2$loadings 에서 Proportion Var이다. 

