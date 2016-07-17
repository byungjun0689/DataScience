####################################################
##################다중회귀분석######################
####################################################

###여러 개의 독립변수

salary <- read.csv("salary.csv")
head(salary)
summary(salary)

pairs(salary)
pairs.panels(salary)

model <- lm(salary~experience+score, data=salary)  #3개변수
model <- lm(salary~., data=salary)   #위와 같은 내용, salary를 제외한 모든 내용을 변수로
summary(model)

# F-검정 : 선형회귀에서는 베타1이 0인 경우였으나, 지금은 변수가 여러 개
## F-test의 P-value가 매우 작다. Ho를 기각한다. 회귀식이 유의하다!

# T-검정 : Ho가 각 베타i가 0인지 아닌지, 개별 test (from 베타1 ~ 베타끝)
## Intercept, 즉 베타0에서는 P-value가 크다. 베타0는 0같다.
##### 보통 베타0는 큰 의미를 가지지 않는다.
## 각 베타i의 경우, experience와 score의 P-value가 작아서 둘다 유의하다. (Ho 기각)
## 2개 변수 둘다 유의하다 (y를 설명할 수 있는 변수로서 작용한다)

# 계수의 해석방법
## 1개의 변수를 해석하는 경우, 다른 변수는 일정, 즉 변하지 않는다는 가정하에 해석
## 예) 연수가 1년 증가할때 연봉이 1,404 증가 (직무적성검사는 같다고 가정!)

summary(lm(salary~experience, data=salary))
## 결정계수의 경우, 설명변수의 수가 증가하면 언제나 증가한다 (줄어들지 않는다)
## 변수의 개수를 고려한 새로운 결정계수 필요 -> 수정 다중결정계수 (Adjusted R-squared)

plot(model)
## residual plot -> 2번 관측치가 Cook's distance를 벗어남, 영향점
head(salary)
pairs.panels(salary, col=2)
## 2번만 이상하다? 다른 색깔을 주고 싶어요! 

cl <- rep(1,20)
cl
cl[2] = 2
pairs(salary,col=cl)  #색을 빨간색으로 바꾼다 (on 2번 관측치)
pairs(salary,col=cl,pch=cl)   #다른 모양으로 한다 (on 2번 관측치)
## 2번 관측치는 경력에 비해 높은 연봉을 받는다
## 2번을 빼야 할 지 말지는 결정하기 애매하다 (예-해외스카웃)

model2 <- lm(salary~., data=salary[-2,])
## 결국 2번 관측치를 뺀다 -> 주관적으로 판단하여 결정한다 (수량적 근거를 만들 수 없다)
summary(model2)
plot(model2)   #영향점이 없다 


### 추정과 예측
predict(model, data.frame("experience"=c(5,10), "score"=c(80,70)),
        interval="confidence")
## 신뢰구간 : 평균 연봉이 29,045 ~ 31.483 in (5,80)
predict(model, data.frame("experience"=c(5,10), "score"=c(80,70)),
        interval="prediction")
## 예측 : 구간이 넓어진다


### 다중공산성 : 독립변수 사이의 상관관계
attitude
cor(attitude)
round(cor(attitude),3)

summary(lm(rating~complaints+learning,attitude))
## complaint와 learning의 상관계수가 0.6
plot(attitude[,c(1,2,4)])
## 0.2112가 별로 의미가 없어 보이지만, 사실 learning~rating도 관련이 있고,
## complaint와 rating의 관계도 있는데, 합쳐놓고 보니 learning의 역할이 작아보이는 것뿐이다
## learning과 complaint와의 관계도 존재하기 때문이다 


### 모형선택방법
out11 <- lm(rating~., attitude)
summary(out11)
## P-value를 기준으로, critical의 값이 가장 의미가 없다 -> 빼자!

out12 <- lm(rating~.-critical, attitude)
summary(out12)

## ANOVA table
anova(out11)  #Sum Sq <- Sum of Square : R의 변동성의 의미
#R의 변동성이 유의한지 안한지가 P-value로 표현됨
# ANOVA가 중요한 경우는, 이따 다시 배워요 =) 
## (분산분석에서 다시 나옴: 여러개 설명변수의 영향력을 동시에 제거 한 경우, 변동성 분석)

## 하나하나 빼기 힘들다면!
backward <- step(out11, direction="backward")
# 변수가 backward로 하나하나씩 빠진 내용이 들어가 있다 
# trace=FALSE 하면 최종 모형만 남는다 (숫자를 넣으면 그만큼까지 빠진다)
backward <- step(out11, direction="backward", trace=2)

##All subsets Regression
install.packages("leaps")
library(leaps)

leaps <- regsubsets(rating~., data=attitude, nbest=5)
## 변수가 6개라면 6C2만큼 가능, 즉 15개 
## size별로 좋은 모형 5개 저장 <- nbest=5 <- default는 nbest=1
summary(leaps)   #별표가 포함되어 있는 변수
plot(leaps)   #complaints만 들어간 것이 좋다 
plot(leaps, scale="adjr2")
## BIC를 기준으로, 제일 좋은 모형은 complaints와 learning, advnace가 들어 간게 제일 좋다 
## 맨 윗줄이 색칠되어 있는 부분을 보면 된다



############ PRACTICE ############## (Practice4 파일의 2번)
laq <- read.csv("laquinta.csv")
summary(laq)

# Q1. 산점도
plot(laq)
## 설명변수간의 correlation도 낮다. 종속변수와도 낮다. (큰 의미 없는 data인듯...)

# Q2. Margin을 변수로 설명하는 회귀식
out15 <- lm(Margin~., laq)
summary(out15)

# Q3. 회귀모형의 유의여부
summary(out15)
## F-test의 P-value가 매우 작다. 유의하다. Ho를 기각한다. 의미있는 선형식이다!

# Q4. 회귀계수 유의여부
summary(out15)
## Enrollment, Distance는 큰 의미 없어 보인다. 
## Number = 근처에 1개 있을 때 Margin율이 0.7% 내려간다는 의미 
## Office.Space = 근처에 커뮤니티 사무실 규모가 1,000 ft^2 증가 시, Margin 1.9% 증가

# Q5. 잔차분석
plot(out15)
## 크게 벗어나는 점이 없다 (Cook's distance에서 나가는 점이 없다)

# Q6. 각 회귀계수 해석
pairs.panels(laq)
round(cor(laq),3)

# Q7. 신뢰구간 예측
summary(laq)
predict(out15, data.frame("Number"=3815, "Nearest"=0.9, "Office.Space"=476,
                          "Enrollment"=24.5, "Income"=35, "Distance"=11.2),
        interval="confidence")

# Q8. BIC를 통한 설명변수의 조합 
leaps2 <- regsubsets(Margin~., laq)
leaps2
plot(leaps2)
## BIC : log-likeliehood + penalty on number of variables
plot(leaps2, scale="adjr2")
## 다른 기준인 adjr2을 적용한 사례
