library(psych)
library(dplyr)
# PCA practice 2 // 1015 수업까지 보내기. ####
bullsOri <- read.csv("../0924_1001/bulls.csv", stringsAsFactors = F)
str(bulls)
# breed 종 => 제외 필요.
# Salespr 가격 => 제외 필요 

bulls <- bulls[,-c(1,2)]
pairs.panels(bulls)
bulls <- bulls[!bulls$PrctFFB==81.40,] 
bulls_pca <- prcomp(bulls,scale=T)
plot(bulls_pca,type="l")


bulls_pca$x
bulls_c <- scale(bulls)
tmp <- bulls_c %*% bulls_pca$rotation[,1]

plot(tmp, bulls_pca$x[,1])
cor(bulls_pca$x[,1], bulls_pca$x[,2])

biplot(bulls_pca)
bulls_pca$rotation


# 교수님 코드 
bulls_pro <- bullsOri
pairs.panels(bulls_pro)
# BkFat 의 경우 오른쪽 꼬리 그래프가 나온다. => 뭉쳐져있는 것을 퍼뜨리기 위해서 log변환이 필요하다.

pca_cov <- prcomp(bulls_pro[,-c(1,2)])
summary(pca_cov) # 하나만 가지고 80프로를 설명할 수 있다. 하지만 넘어 가면 안된다. biplot으로 확인
biplot(pca_cov) # SaleWt, FtFrBody 두개만 보이고 나머지는 중간에 뭉쳐있어서 설명이되지도 않는다. 
# 화살이 길면 길수록 분산이 크다. 즉, 나머지 부분들이 분산이 높지가 않다. 
 
pca_cov$rotation[,1:2]
# => 두개의 변수에 의해서 모두 좌지우지 되어 버린다. SaleWt, FtFrBody
# 측정된 값들의 범위에 의해서 ( 유닛에 의해서 ) 좌지우지 되는 방향은 좋지가 않다. 즉, 측정 값? 단위에 따라서....

pca_cor <- prcomp(bulls_pro,scale. = T)

# Exploratory Factor Analysis (색탐적 인자 분석) #### 
# 예를 들어 각각 측정 된 시험에 대한 성적을 바탕으로 잠재된 변수를 뽑아내는 것. 


