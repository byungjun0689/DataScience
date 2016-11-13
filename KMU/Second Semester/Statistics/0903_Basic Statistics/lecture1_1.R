install.packages("MVA")
library(MVA)
install.packages("mvtnorm")
library("mvtnorm")
demo("Ch-MVA")


dim(hypo)
str(hypo)  
hypo # NA (Not available) 결측치가 생겨있다.

data("USairpollution")
pairs(USairpollution)
str(USairpollution)

## 공분산.
x <- 1:100
x1 <- 101:200
df <- data.frame(x=x,x1=x1)
sd(x) # Σ (X - X bar)² / n - 1
cov(df$x,df$x1) # Σ (X - X bar)(X1-X1 bar) / n - 1

#Data Measure
# 가슴 허리 엉덩이 둘레 
str(measure)
cov(measure[,1:3]) # 공분산 행렬 출력. 
# 남자 
cov(measure[measure$gender=="male",1:3])
# 여자
cov(measure[measure$gender=="female",1:3])
