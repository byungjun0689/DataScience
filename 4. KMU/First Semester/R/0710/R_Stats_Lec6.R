####################################################
####################상관분석########################
####################################################

###(복습)변수유형에따른분석기법###

#Pearson 상관계수#
## 공분산 cov(x,y) : xi와 yi값의 부호가 의미를 가진다
##### x부분이 양수/음수, y부분이 함께 양수/음수인 경우 = 결론은 양수 
##### 둘의 부호가 다른 경우 = 결론은 음수
##### 단위를 맞춰줘야 한다 
## 상관계수 : 각 표준편차로 나눈 값
##### 절대값의 크기가 상관관계의 강도를 표현한다

library(reshape)

attitude   #30개의 data
str(attitude)
summary(attitude)   #각 변수의 상관관계를 알고자 함 

cor(attitude)   #전체 변수의 상관관계를 먼저 전체로 봄
round(cor(attitude),3)
pairs(attitude)   #변수별 산점도 

install.packages("psych")   #pairs를 보다 가시성 있게 보고 싶다면 install~
library(psych)
pairs.panels(attitude)   #산점도와 상관관계 등을 한꺼번에 볼 수 있다 
#하늘색 부분은 각 변수의 histogram 
#왼쪽 아래는 2개 변수의 산점도, 우측 위는 상관계수 

#Pearson은 선형관계만 확인한다. (예외 example은 노트 필기 확인!)
#아치형 그래프의 경우, 실제로는 관계가 크지만 선형관계수는 0에 가깝게 나온다.
#이런 경우에는 그래프로 확인해야 한다.


#Kendal, Spearman은 순위가 기준!
x <- c(1:10)
y <- x^2
plot(x,y)
#각 상관계수의 종류 비교 
cor(x,y)
cor(x,sqrt(y))
cor(x,y,method="kendall")
cor(x,y,method="spearman")


# 상관계수가 의미를 가지는 기준은? 뭐가 높은 거에요?
## 사실 기준은 없다!
##### 0이냐 아니냐를 해보는 test는 있다 (조금이라도 관계가 있는지 없는지 비교)
cor.test(attitude$rating, attitude$complaints)
#대립가설 : 로우(true correlation)이 0이 아니다, 상관관계가 조금이라도 있다!
#P-value가 0.05보다 작다. Ho를 기각한다!
#그러나 빅!데이터, 즉 데이터가 엄청 많은 경우, P-valeu가 많이 작을 수 있다.
#세부 그래프는 항상 함께 확인하는 것이 좋다.





####################################################
###################단순회귀분석#####################
####################################################

# 설명변수가 한 개 있는 경우를 단순회귀분석이라고 한다
# x가 원인이 되어 y가 어떻게 변하는 지에 대한 수식
# 인과관계는 아니다! 조심하자! 이건 상관관계다! 
# 엡실론: 오차항: 선으로부터 점들이 얼마나 떨어져 있는지 수치화 
### 다 더하면 0이다, 그래야 선이 의미를 가진다 
### 선으로부터 많이 퍼져있는 경우 분산이 크다, 선에 많이 붙어있으면 분산이 작다
### 분산이 작은 것이 correlation 즉 상관관계가 크다 
# 추정된 회귀모형: 직선 그 자체의 식 
# 기울기가 0이냐 아니냐가 의미를 가진다: 과연 x가 y를 설명할 수 있는 변수인가?
### x에 상관없이 y 는 항상 베타0, 즉 상수다 <- x는 y에 있어서 의미를 가지지 않는다

cars <- read.csv("cars.csv")
str(cars)
summary(cars)   #2개의 변수 (brake밟았을 때에 속도에 따라 멈추는 데 걸리는 거리)

plot(cars)   #처음 보면 큰 문제가 없어 보인다? 답정너!
out <- lm(dist~speed, data=cars)   #lm = linear model (선형 모델) #종속변수~설명변수
summary(out)
# residual = 잔차 (y1원래데이터값 & y햇=선형식에서의값의 차이)
# 잔차의 평균은 0이다 (그렇게 선형식을 만드니까!) 그래서 summary에 mean값이 없다 

# 이 부분은 print의 필기를 봐야 함

# No intercept model (y절편을 없앰)
## break를 안 밟았을 때의 거리가 0인 것이 당연하다
out1.5 <- lm(dist~0+speed, data=cars)
summary(out1.5)
# 선형식 = y = 2.91x

plot(out1.5)
## 3개 plot을 한번에 본다 
#residual plot (별로다)
#Normal Q-Q plot (정규분포 확인: X)
#2번째 잔차도 (띠 형태가 아니다: not good)

plot(dist~speed, cars)
plot(log(dist)~speed, cars)   #변환해 보니, 앞쪽 분산이 너무 크다!
plot(sqrt(dist)~speed, cars)  #분산도 꽤 일정하고, 비교적 보기 좋은 선형 모형이다
### 보기 좋은 모형으로 바꾼 후에 그것을 종속변수로 넣고 회귀분석을 한다 

out2 <- lm(sqrt(dist)~0+speed, data=cars)
summary(out2)
plot(out2)
# sqrt를 함으로써 단위가 달라졌다 
# 매우 유의하다 P-value가 매우 작다
# 96.89% 설명력 <- 루트 변환 후에 회귀식의 설명력이 훨씬 올라갔다 
# F-test의 P-value도 매우 작다 

### 추정과 예측
new <- data.frame("speed"=c(10,30))
predict(out2, new)  #out2의 모델에서, 새로운 변수인 enw를 넣어서 예측한다
# 루트(dist)이 0.397speed => 0.397*10 => 원래 scale로 돌아오려면!
predict(out2, new)^2

## 신뢰구간과 예츠
predict(out2, new, interval="confidence")
# default가 95% 신뢰구간
# 여러개 뽑아서 평균 : 평균적으로 이 구간 안에 들어갈 거라고 생각한다
# random하게 차를 엄청 많이 like 백만대 뽑아서 평균 
predict(out2, new, interval="prediction")
# 하나의 차에 대한 예측이므로 범위가 더 커진다 (덜 확실하지만 사례에 따라 달라진다)

fitted(out2)
cbind(cars,fitted(out2))
# 50개에 대한 모든 y의 예측치 
# speed가 x, dist가 y, 산점도를 그린다
# fitted = y햇의 값 전부
plot(cars$speed, fitted(out2))

plot(dist~speed, cars)
# 50일떄의 값을 predict 할 수는 있겠지만, 조심해야 한다!
new2 <- data.frame("speed"=c(50))
predict(out2, new2)

plot(out)
# 영향점 확인
# 3번째 plot 모양에서 우측 상단에 0.5라고 써있는 빨간 선 확인 (Cook's distance)
# 0.5 빨간 선 아래 모든 점이 있어서 influential point가 다행히 없다 
# 넘어가는 점이 있으면, 초록색 선이 함께 뜬다 (influential point가 빠졌을 때의 회귀식)


### 마지막 페이지 절차 확인~~~ Summary~~~


############ PRACTICE ############## (Practice4 파일의 1번)
sonata <- read.csv("sonata.csv")
str(sonata)

# Q1. 기술통계량
summary(sonata)
## sonata <- sonata[,-3] <- color이라는 의미없는 변수를 삭제 

# Q2. 산점도와 상관계수 
plot(Price~Odometer, sonata)
cor(sonata$Price, sonata$Odometer)   #음의 상관계수, 높음 (-0.81)
pairs.panels(sonata)
out4 <- lm(Price~Odometer, data=sonata)
out4

# Q3. 회귀식
summary(out4)
## No-intercept모델이 필요하다
out4 <- lm(Price~0+Odometer, data=sonata)
summary(out4)
# y = 2.41x

# Q4. 회귀모형 추정 및 유의여부
summary(out4)
# F-test의 P-value가 매우 작다. 즉 회귀모형이 유의하다!
# R-squared를 통해 0.65, 즉 65% 정도 설명력을 가진다 

# Q5. 회귀계수 유의여부 (t-test)
summary(out4)
# P-value가 매우 작다. 즉 유의하다. (= Odometer이 0에 가깝지만 알고보면 유의한 값)
# 100 mile 더 달렸을 때에 67불이 떨어진다 (Odometer -0.067 기준, 1,000달러 기준)

# Q6. 잔차분석 
plot(out4)
# 양호함 (residual plot, Q-Q plot, 영향값도 Cook's distance 밖에 없음) 

# Q7. 주행거리의 계수 추정치
fitted(out4)

# Q8. Odometer = 3600마일, 평균가격을 95% 신뢰구간으로 추정
new3 <- data.frame("Odometer"=36)
predict(out4, new3, interval="confidence")
## 다음의 방법도 가능하다
predict(out4, data.frame("Odometer"=36), interval="confidence")
predict(out4, data.frame("Odometer"=36), interval="prediction")
## 문제에 100단위라고 나온 점을 확인한다