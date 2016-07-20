####################################################
#################분산분석 (ANOVA)###################
####################################################

###현재까지 양적 변수만 비교함, but 범주형 변수인 경우도 많다! 
## 세 그룹 이상의 평균이 같은지 검정 -> 분산분석
## R에서는 회귀분석과 동일한 형태

mov <- read.csv("movie_MBA2.csv")
summary(mov)
## rating이 total_seen에 영향을 주는지 확인해 보자! 
## 지난 주에는 t-test로 2개 집단 비교함, 오늘은 4개의 집단을 동시에 비교!

hist(mov$total_seen)
## 왼쪽에 많은 데이터가 몰려있다 
hist(log(mov$total_seen))
## 로그 변환 후 사용하자!

out21 <- lm(log(total_seen)~rating, mov)   #이렇게만 보면 분산분석인지~ 다중인지~ 모름! 
summary(out21)
## 설명 변수는 1개, rating 즉 x변수는 3개 as dummy 변수 
## 베타0: 12세 관람가의 평균 
## 베타1: 15세 평균 - 12세 평균

## 청소년과 12의 차이를 봤을 때, 베타3은 별로 유의하지 않다 (0.093)
## 전체와 12의 차이를 봤을 때, 베타2은 매우 유의하다.  

### F-test : 평균 차이의 검정
summary(out21)
# P-value = 0.001601 <- 다 다른지는 모르겠지만, 적어도 하나의 등급은 좀 평균이 다르다 
# but 어느 등급끼리 다른지 모른다! => 다중비교 필요
# 어림잡아 기존 summary의 Pr(>|t|)로 얘기할 수 있지만 각각의 test도 필요하다
# 변수가 늘어나게 되면서 각각의 t-test진행 시, 0.95 * 0.95 .... 신뢰구간이 작아진다 


### 다중비교
## Dunnett Method : reference level(기준)이 있다 
## Tukey Method : 가능한 모든 범주로 한다 

install.packages("multcomp")
library(multcomp)

dunnett <- glht(out21, linfct=mcp(rating="Dunnett"))
summary(dunnett)
## reference level : 12세 관람가 
# 전체와는 유관하지만, 청소년과는 별로 유의하지 않다 / 15세와는 특히 더!

tukey <- glht(out21, linfct=mcp(rating="Tukey"))
summary(tukey)


### 범주형 변수의 변환
## 굳이 다 궁금한 것이 아니라, 부분별로 묶어서 보고 싶은 경우? 
## 예) 12세와 15세를 하나의 그룹으로 묶어서 보자
mov$rating2 <- mov$rating
levels(mov$rating2)
levels(mov$rating2)=c(2,2,1,3)  #합치기 작업 (같은 그룹에 같은 숫자 부여)
summary(mov$rating2)

out22 <- lm(log(total_seen)~rating2, mov)
summary(out22)
## reference group이 자동으로 2로 됨 (가장 앞의 그룹인듯), 아래로 확인!
levels(mov$rating2)

## 1번을 reference group으로 다.시. 잡는다
mov$rating2 <- relevel(mov$rating2, ref="1")  
out22 <- lm(log(total_seen)~rating2, mov)
summary(out22)
# 전체 고나람가에 비해 청소년관람불가가 유의하게 크지 않다 (rating23)



####################################################
###############공분산분석 (ANCOVA)##################
####################################################

### 범주형변수... 분산분석 + 회귀분석
### 양적변수 질적변수 둘다 있다 -> 오늘은 맛보기만! 

## 예) 거식증치료제
# 종속변수에 이미 치료전후 몸무게가 들어가 있지만,
# 치료전 몸무게는 정말 큰 의미를 가지기에 설명변수에도 들어간다 

anx <- read.csv("anorexia.csv")
summary(anx)
str(anx)   # 환자 72명, Prewt / Postwt / Treat종류(3개그룹)

out31 <- lm(Postwt-Prewt~Treat, anx)
summary(out31)

out32 <- lm(Postwt-Prewt~Prewt+Treat, anx)
summary(out32)
# 3개 모두 유의하다
# reference level : CBT
### Prewt이 높을수록 변화가 적다. (-0.5655)
### TreatCont : Prewt이 동일한 수준일 때, Control Group이 -4.0971만큼 차이난다)
                # Control Group의 몸무게 변화가 적었다
### TreatFT : 동일한 사람들 놓고 봤을 때, CBT 약에 비해 FT의 몸무게 변화가 더 컸다

boxplot(Prewt~Treat, anx)


## 여기서 ANOVA가 중요하다!
anova(out32)
# 하나의 변수로 나와서, Treat라는 변수가 설명해주는 효과, 변동성의 정도의 의미
# Treat가 유의하다는 얘기는, Prewt을 제어했을 때, Treat 3개 그룹의 평균의 차이가 유의하다
    # 0.0008438 기준
    # df = 2인 이유가 treatment 종류가 3이라서! 



############ PRACTICE ############## (Practice5 파일)
forb <- read.csv("Forbes500.csv")
str(forb)
summary(forb)

boxplot(Sales~sector, forb)
boxplot(log(Sales)~sector, forb)
## log(Sales)로 분산 분석 실행!

# Q1. ANOVA
forb$sector <- factor(forb$sector)
forb$sector <- relevel(forb$sector, ref="HiTech")   #reference level이 원래 Communication
                          #정규화 때문에 바꾸었다. 그래프 먼저 확인한다.

out41 <- lm(log(Sales)~sector, forb)
summary(out41)
boxplot(log(Sales)~sector, forb)
## Hi-tech가 제일 높다 

# Q2. 분산분석, dunnett test
dunnett2 <- glht(out41, linfct=mcp(sector="Dunnett"))
summary(dunnett2)
## Hi-tech를 기준으로, Energy, Finance, Medical에 유의하게 차이난다

# Q3. Sales~Asset, 산점도, log변환
out42 <- lm(Sales~Assets, forb)
plot(Sales~Assets, forb)
out43 <- lm(log(Sales)~log(Assets), forb)
plot(out43)

# Q4. log(Assets), sector -> log(Sales) 공분산분석
out44 <- lm(log(Sales)~Assets+sector, forb)
summary(out44)
## sector간의 차이 : Assets는 매우 유의하다 

# Q5. log(Assets)이 동일, sector간에 log(sales)의 차이 by dunnett test
dunnett3 <- glht(out44, linfct=mcp(sector="Dunnett"))
summary(dunnett3)
## energy가 바뀌었다! 
