# 평균에 대한 추론
# 추정 : 표본을 통해 모집단 특성을 추측
# 가설검정 : 모집단 실제 값이 얼마나 되는가 하는 주장과 관련해서
# 표본이 가지고 있는 정보를 이용해서 가설이 올바른지 판점. 

# 모집단 평균의 구간 추정
# 신뢰구간 
rm(list=ls())

library(reshape)
tips <- tips
t99 <- t.test(tips$total_bill,conf.level = 0.99)  # 신뢰 수준
t99$conf.int 
# [1] 18.30631 21.26557  신뢰 구간.
# attr(,"conf.level")
# [1] 0.99  # 신뢰 수준 99%
t99$estimate
# mean of x 
# 19.78594

t90 <- t.test(tips$total_bill,conf.level = 0.90)
t90$conf.int
# [1] 18.84492 20.72696
# attr(,"conf.level")
# [1] 0.9
t90$estimate
# mean of x 
# 19.78594 


# 평균에 대한 추론 
# One-sample T-Test ( 단일집단 모평군에 대한 검정)

# 예) 2006년조사에의하면한국인의1인1일평균알코올섭취량은
# 8.1g이다. 2008년대통령선거로 알코올섭취량이달라졌는지조사하기
# 위해10명을무작위로 뽑아서조사한결과다음과같은데이터를얻었다.

# 알콜 섭취량 
OneSample <- c(15.5,11.21,12.67,8.87,12.15,9.88,2.06,14.5,0,4.97)
OneSample

# H0 : 2008년의 평균 알콜 섭취량 8.1g
# H1 : 2008년의 평균 알콜 섭취랑 <> 8.1g
# 조건 : 정규분포 또는 편중된 그래프 일 경우 표본수가 30~50개 이상. 

shapiro.test(OneSample) # 정규분포를 따르는지 확인.
# W = 0.92341, p-value = 0.3863
# p-value가 0.05보다 크다. 기각X => 정규분포를 따른다. 
# p-value < 0.05 => 관측수가 적어 다른 TEST 고려.

t.test(OneSample,mu=8.1)
# H0 : mu = 8.1 vs H1 : mu𝜇 > 8.1
t.test(OneSample,mu=8.1,alternative = "greater")
# H0 : mu = 8.1 vs H1 : mu < 8.1
t.test(OneSample,mu=8.1,alternative = "less")


# H0 : 암이 걸리지 않았다. H1: 암이 걸렸다.
# 제 1종 오류, 제 2종 오류 
# 제 1종 : 참인 가설을 기각. => 암이 걸리지 않았는데 걸렸다고 판정.
# 제 2종 : 거짓인 가설을 기각 안함. => 암이 걸렸는데 안걸렸다고 판정. 
# 문제에 따라서 a를 조정할 필요가 있다. 
# 유의수준(𝛼) 조정
t.test(OneSample,mu=8.1,conf.level = 0.99)


# 15세 이상 관람가 영화의 평균 관객수를 95% 신뢰구간을 통해 추정
# 15세 이상 관람가 영화의 평균을 1,500,000 보다 크다고 주장 이 주장이 사실인지 가설 검정을 판단. 
# 1. 귀무가설, 대립 가설설정
# 2. 가정을 만족하는지 체크
# 3. 검정통계량과 p-value 구하기
# 4. a = 0.05에서 통계적 결론은 무엇인가.

DF <- read.csv("movie_MBA2.csv",stringsAsFactors = F)
DF15 <- DF[DF$rating=="15세이상관람가",]
par(las=1,mfcol=c(1,1))
hist(DF$total_seen,20)
str(DF)
DFRe <- t.test(DF15$total_seen,conf.level = 0.95,mu=1500000,alternative = "greater")
# 1. 귀무가설 : 영화 평균 1,500,000 이하이다. 
# 1. 대립가설 : 영화 평균 1,500,000 보다 크다. 
DFRe$p.value # => 0.02 즉, a보다 작다. H0를 기각 가능하다. 귀무가설이 거짓이다. 1,500,000이다. 

DFRe2 <- t.test(DF15$total_seen,conf.level = 0.95,mu=1500000)
DFRe2$conf.int # 150만을 포함하고 있지 않다. 기각한다. 


# 평균에 대한 추론 / 두 모집단 평균에 대한 검정. 독립표본 T-검정.

rm(list=ls())
DT <- read.csv("dental.csv",stringsAsFactors = F)
par(mfcol=c(1,2))
boxplot(resp~treatment,data=DT)
boxplot(log(resp)~treatment,data=DT)

# Test가 control군의 분산보다 크다.
# 둘다 편중
# Log변환 후 분산 차도 좁혀지고 편향도도 작아졌다.


# 양의 왜도, 음의 왜도가 생길경우는 log 또는 sqrt (루트) 적용. 
# One sample : T = x bar - mu / (=sd(x bar)/sqrt(n))
# Two sample : T = x1 bar - x2 bar / sqrt(Var(x1 bar - x2 bar))
# sqrt(Var(x1 bar - x2 bar)) => sd(x1)^2 / n1 + sd(x2)^2 / n2
# 등분산 검정 
var.test(log(resp)~treatment, data=DT)  # alternative : true ratio of variances is not equal to 1
t.test(log(resp)~treatment,var.equal=T,data=DT)

# 결론 p.value=0.0357 < 0.05  : 귀무가설 기각 =>  5%하 에서 차이가 있다. 


var.test(resp~treatment, data=DT) # 기각
# p-value = 0.03483 < 0.5 
# confidence interval: 0.008840233 0.815484912  
# ratio of variances 0.08490628  신뢰구간에 존재 하지 않는다. 
t.test(resp~treatment,data=DT) # 기각

# 쌍체표본 T-검정.
# 같은 대상한테 다른 조건을 주고 결과를 체크 하는 것.
# 쌍을 이룬 두 변수의 차이를 보는 검정. 
# 두 집단이라하더라도 쌍둥이 또는 부부처럼 변수들 간의 상관관계가 존재할때 

# 거식증치료제 FT복용전후의 체중변화를 측정하여 FT가 체중증가에 영향이 있는지 조사
FT <- read.csv("FT.csv",stringsAsFactors = F)
summary(FT)
str(FT)
# 'data.frame':	17 obs. of  3 variables:
#   $ Treat : chr  "FT" "FT" "FT" "FT" ...
# $ Prewt : num  83.8 83.3 86 82.5 86.7 79.6 76.9 94.2 73.4 80.5 ...
# $ Postwt: num  95.2 94.3 91.5 91.9 100.3 ...

FT$Gap <- FT$Postwt - FT$Prewt
FT

with(FT, shapiro.test(Postwt-Prewt))  #2개의 값을 한번에 사용하려면 with 가 필요.
shapiro.test(FT$Postwt-FT$Prewt)  # 동일함.

#H0 : mu1 - mu2 = 0 ( 평균의 차가 0인지 )
#H1 : Mud = 0 (차이의 평균이 0인지)
#H1 : Mud > 0 (차이의 평균이 0보다 큰것인지 )   

with(FT,boxplot(Postwt - Prewt))
boxplot(FT$Postwt-FT$Prewt)
boxplot(FT$Gap)

with(FT,t.test(Postwt - Prewt,alternative = "greater"))
t.test(FT$Gap, alternative = "greater")

# A/B 테스트(임의화 비교실험)
# 요인의 효과를 제어할 수 있는 상태에서 비교할 수 있다. 
# 예 ) 흡연 유무에 따른 폐질활 검사=> 통제 할 수 없다.



# 실전
# 3. 12 / 15 세 관객수 비교
# 3.	한 영화사에서는 15세 이상 관람가 영화의 평균 관객수가 12세이상 관람가 영화의 평균관객수보다 많다고 주장한다. 본 주장이 사실인지 가설검정을 통해 판단하시오 
#   i.	귀무가설, 대립가설 설정
#   ii.	가정을 만족하는지 체크  
#   iii.	검정통계량과 p-value 구하기
#   iv.	α=0.05에서 통계적 결론은 무엇인가? 

MV <- read.csv("movie_MBA2.csv",stringsAsFactors = F)
MV1215 <- MV[MV$rating=="15세이상관람가"|MV$rating=="12세이상관람가",]
unique(MV1215$rating)
MV1215$rating <- factor(MV1215$rating,labels=c("12세이상관람가","15세이상관람가")) #rating에 원래 다른 levels가 존재한걸 없애준다.
boxplot(total_seen~rating,MV1215)
boxplot(log(total_seen)~rating,MV1215)
var.test(total_seen~rating,MV1215)
var.test(log(total_seen)~rating,MV1215)
t.test(total_seen~rating,MV1215,alternative="less")  #12세 - 15세가 0보다 작아야되므로 less를 적용.
#실질적으로는 15세가 크게 나왔지만 통계적으로 유희수준을 넘을 정도로 크게 나오지 않음.
t.test(log(total_seen)~rating,MV1215,var.equal = T,alternative="less")
#log는 그냥 해본것. 


# 4.	StreetInsider.com은 대기업의 표본 자료를 통해 2002년 주당이익 수준을 발표하였다. 
# 2002년 이전에 애널리스트들이 이들 대기업에 대한 주당이익을 예측하였다 (Borron’s, 2001년 9월 10일). 
# Earnings.csv에 자료를 바탕으로 실제 주당이익과 추정 주당이익의 차이에 대한 조사를 수행하였다.
# A.	실제 평균 주당 이익과 추정 평균 주당이익의 자료를 각각 기술통계량을 사용해 요약하시오.
# B.	실제 모집단 평균 주당 이익과 추정 모집단 평균 주당이익 간의 차이에 대하여 가설검정을 α=0.05에서 
# 수행하시오. 
#   i.	귀무가설, 대립가설 설정
#   ii.	가정을 만족하는지 체크
#   iii.	검정통계량과 p-value구하기
#   iv.	통계적 결론은 무엇인가?
# C.	두 평균의 차이에 대한 점 추정치는 얼마인가? 애널리스트들은 주당 이익에 대하여 과대평가 하였는가? 아니면 과소평가 하였는가?

Earning <- read.csv("Earnings.csv",stringsAsFactors = F)
head(Earning)
# Company Actual Predicted
# 1         AT&T   1.29      0.38
# 2 Amer Express   2.01      2.31
# 3    Citigroup   2.59      3.43
# 4    Coca Cola   1.60      1.78
# 5       DuPont   1.84      2.18
# 6  Exxon-Mobil   2.72      2.19

with(Earning,boxplot(Actual - Predicted))
with(Earning,t.test(Actual - Predicted,alternative = "greater"))
# p-value = 0.7199
# alternative hypothesis: true mean is greater than 0
# 95 percent confidence interval: -0.4151565        Inf
# mean of x -0.103

# H0 mean(Earning$Actual - Earning$Predicted) is equal to 0
# H1 true mean is not equal to 0
boxplot(Earning$Actual - Earning$Predicted)
t.test(Earning$Actual - Earning$Predicted)
# Acutal이 적게 나왔다, 과대 평가를 한것이다. 하지만 양은 통계적으로 유의할 만큼 과대평가 한것이 아니다. 
# p-value = 0.5602
# 95 percent confidence interval : -0.4882175  0.2822175
# mean of x -0.103 
