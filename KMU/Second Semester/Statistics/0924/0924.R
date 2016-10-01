library(MASS)
attach(geyser)

par(mfrow=c(1,2))
options(repr.plot.height=4, repr.plot.width = 8)
density1 <- kde2d(waiting, duration, n=25)
image(density1, xlab="waiting", ylab="duration")

density2 <- kde2d(waiting,duration,n=100)
image(density2, xlab="waiting", ylab="duration")

contour(density2)

persp3d(density2, back="lines", col="skyblue",xlab="waiting",ylab="duration")
?persp3d


# PCA (주성분 분석)
# 상관계수 => 공분산을 표준화 시켜서 각각의 분산의 곱으로 나누는 값과 동일하다.
# 숫자형 변수만 사용가능하고 명목형 변수는 사용할 수 없다. 즉, 명목형 변수값들은 숫자형으로 변화시켜야한다.
library(psych)

data <- read.csv("open_closed.csv", stringsAsFactors = F)
head(data)
str(data)
cor(data)
pairs.panels(data)

pca = prcomp(data,scale=T)  # 상관계수로 주성분 분석을 한다. scale된 변수로 (평균0 표편1)
summary(pca) # 각 변수의 표준 편차라 생각하면 된다. Standard deviation = sqrt(고유값) 
# PC1    PC2     PC3     PC4     PC5
# Standard deviation     1.7835 0.8600 0.66706 0.62281 0.49658  -> pc1부터 편차가 가장 큰 이유는 가장 큰 값들을 찾아왔으니깐.
# Proportion of Variance 0.6362 0.1479 0.08899 0.07758 0.04932
# Cumulative Proportion  0.6362 0.7841 0.87310 0.95068 1.00000

# Proportion of Variance 
# 총분산의 양은 동일하다. 축만 바꼈을 뿐이다. x1,x2,x3 였느냐 y1,y2,y3 였느냐  
# 즉, y1+...+y5 = 총분산량  
# PC1이 전체 분산량을 얼마만큼 설명하는가?  그래서 점점 작아진다. 분산이 가장 큰 부분부터 찾아왔으니깐. 
# 뒤의 3개변수는 10프로도 안되는 설명을한다. 총 2개의 변수를 가지고 설명하면 더욱 효율성이 있지 않느냐 
# 그 변수가 Y1, Y2가 되는 것이다. 새로운 도식이 나온다. 
# 상관관계로 했을 경우는 분산이 1이므로 총분산은 변수의 갯수 만큼 되지만 상관계수로 했을 경우는 총 분산 / 변수의 수 

pca
# PC1        PC2         PC3        PC4        PC5
# mechanics_C  -0.3996045 -0.6454583  0.62078249 -0.1457865 -0.1306722   이 값들이 각 x1...xq의 a1...aq의 가중치 값이다.
# vectors_C    -0.4314191 -0.4415053 -0.70500628  0.2981351 -0.1817479
# algebra_O    -0.5032816  0.1290675 -0.03704901 -0.1085987  0.8466894
# analysis_O   -0.4569938  0.3879057 -0.13618182 -0.6662561 -0.4221885
# statistics_O -0.4382444  0.4704545  0.31253342  0.6589164 -0.2340223

# PC1 전체적으로 공부를 잘하고 못하는 학생들을 부리 
# PC2 통계는 잘하지만 기계학은 못하는것.

str(pca)
pca$rotation[,1]  # PC1을 만들기 위한 weight 각각의 열에 x1~x5를 곱한 것에 대한 합이 y1
#y1 의 값.  data의 갯수와 동일한 크기로 나온다.
head(pca$x)
pca$x[,1]

data_s <- scale(data) # 88x5 matrix  muliplex t(a)(1x5 Matrix)
summary(data_s)  
tmp <- data_s%*%pca$rotation[,1]  # 행렬의 곱.
plot(tmp,pca$x[,1])


# 성질
# 1. PC K 의 분산 = var(Yk) = lambda(k)
# 2. PCi와 PCk의 공분산 cov(yi,yk) = 0 , i != k 이다.
cor(pca$x[,1],pca$x[,2])

# 몇개의 주성분을 뽑아내야되는거냐
# 총분산을 설명하는 비중이 70%에서 90%사이에서 선택.
# 평균 고유값보다 작은 고유값을 갖는 주성분을 제거 
summary(pca)
#Standard deviation     1.7835 0.8600 0.66706 0.62281 0.49658  표편을 ^2해도 1보다 작은 것은 작다
#즉, PC1만 사용하고 나머지는 사용하지 않는다 라는 기준이 나온다. 분석가마다 기준을 선택한다. 

plot(pca,type="l")
# 2 이후부터 기울기가 급격히 떨어진다. 2 이후는 사용하지 않는 다 라고 생각하면된다. 꺽이는 부분을 엘보우라한다.


# Example 올림픽 7종 경기 결과 
library(MVA)
head(heptathlon)
pairs.panels(heptathlon[,-8])
# 달리기는 적을 수록 빠른 것이다. 숫자가 크면 잘하는 걸로만들어주고 시작해야 한다. 보기가 편하다
heptathlon$hurdles=with(heptathlon,max(hurdles)-hurdles)
heptathlon$run200m=with(heptathlon,max(run200m)-run200m)
heptathlon$run800m=with(heptathlon,max(run800m)-run800m)
pairs.panels(heptathlon)
summary(heptathlon)
heptathlon[heptathlon$highjump<=1.5,]
hp <- heptathlon[heptathlon$hurdles>0,]
pairs.panels(hp)

# 서로 다른 종목이기때문에 scale을 하는 것이 좋다.
pca2 <- prcomp(hp[,-8],scale=T)
pca2
summary(pca2)
par(mfrow=c(1,1))
plot(pca2,type="l")
plot(hp$score,pca2$x[,1]) 
cor(hp$score,pca2$x[,1])#관계도가 엄청 높다. 거의 1에 가깝다.


#행렬도.
# PC1와 PC2의 산점도.이다 
# 원변수와 주성분 점수와의 관계를 그래프로 표현
biplot(pca2) # pc1와 pc2의 산점도. 우선 화살표는 빼놓고 어떤식으로 퍼저있는지. 
             # rownames로 지정을 해줘야 이름이 마킹되서 나온다.
head(hp)
# Joyner-Kersee (USA) 그림에서 왼쪽이 가장 작다 PC1에서 PC1은 값이 작을 수록 잘한다. 
# 화살표들이 x축과 평행할 수록 원변수가 pc1에 관련도가 높다라는 것을 볼 수 있다. 
# pc1의 값들과 비례한다 rotation
# y축과 수직일 경우는 pc2와 관계가 적다고 생각하면 된다. 
# PC1         PC2        PC3     
# hurdles  -0.4503876  0.05772161
# highjump -0.3145115 -0.65133162
# shot     -0.4024884 -0.02202088
# run200m  -0.4270860  0.18502783
# longjump -0.4509639 -0.02492486
# javelin  -0.2423079 -0.32572229
# run800m  -0.3029068  0.65650503

# pc1은 전체적으로 잘하고 못하고 그런것을 분별
# pc2는 highjump는 못하고 run800m잘하는 선수들을 분별할 수 있다.  장거리형 선수 

biplot(pca2,cex=0.8,choices = c(1,3)) #원하는 PC 2개를 선택하면 볼 수 있다. 

