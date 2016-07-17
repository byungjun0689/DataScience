####################################################
###########평균에 대한 추론(구간추정)###############
####################################################

t.test(tips$total_bill)
t.test(tips$total_bill, conf.lev=0.99)   #신뢰구간 조정 (기본=95%)
#데이터 개수가 많아지면 conf.lev이 작아져도 나쁘지 않음

###One Sample T-Test
#1# 귀무가설, 대립가설 설정
#2# 가정 체크
#3# 검정통계량, P-value 계산
#4# 결론

x <- c(15.5, 11.21, 12.67, 8.87, 12.15, 9.88, 2.06, 14.5, 0, 4.97)
boxplot(x)
hist(x)9
qqnorm(x)
qqline(x)

#Shapiro-Wilk noramlity test (정규분포를 따른다 as 귀무가설)
shapiro.test(x)

t.test(x, mu=8.1)   #귀무가설 구체화
#평균에 가까울수록 T분포의 값이 작아진다 
t.test(x, mu=8.1, alternative="greater")


############ PRACTICE ##############
names(mov)
unique(mov$rating)

mov2 <- mov[mov$rating == "15세이상관람가",]
str(mov2)
hist(mov2$total_seen, 20)
t.test(mov2$total_seen, mu=1500000, alternative="greater")
#P-value가 a보다 작다. 즉, Ho를 기각한다.


###Two Sample T-Test
dental <- read.csv("dental.csv")
dental
boxplot(resp~treatment, dental)
boxplot(log(resp)~treatment, dental)   #좀더 보기 좋은 비교를 위해 log를 씌움 
par(mfcol=c(1,2))   #위의 2개 boxplot을 한 번에 볼 수 있게 함 (비교) 

var.test(log(resp)~treatment, dental)
#2개의 분산의 비율(s1/s2)이 1이라면 동분산, 아니라면 이분산
#다르다면 t.test 바로 진행, 같으면 t.test(, var.equal=TRUE)이라고 별도로 적어야
t.test(log(resp)~treatment, dental)
t.test(log(resp)~treatment, dental, var.equal=T)
#로그변환에 따라 결과가 달라진다, but 로그 변환이 더 가정이 맞으므로 권장됨
#로그변환 : 변수의 분포를 보다 고르게 한다 (outlier의 극한 정도가 줄어든다)


###Paired T-Test
FT <- read.csv("FT.csv")
FT
with(FT, boxplot(Postwt-Prewt))   
boxplot(FT$Postwt - FT$Prewt)
#한 번에 2개 이상의 변수를 사용하는 경우, 위에서처럼 Postwt-Prewt라고 바로 쓰지 못함
#with을 쓰지 않으려면 FT$라고 별도 명시해 주어야 함 
with(FT, hist(Postwt-Prewt))
str(FT)
with(FT, t.test(Postwt-Prewt, alternative="greater"))


############ PRACTICE ##############
mov3 <- mov[mov$rating == "12세이상관람가" | mov$rating == "15세이상관람가",]
str(mov3)
mov3$rating <- factor(mov3$rating,
                      labels=c("12세이상관람가","15세이상관람가"))
#범주형으로 만들기 위해 factor화 작업
boxplot(total_seen~rating, mov3)
boxplot(log(total_seen)~rating, mov3)

var.test(log(total_seen)~rating, mov3)
t.test(log(total_seen)~rating, mov3, var.equal=T, alternative="less")
#귀무가설을 기각할 수 없다


engs <- read.csv("Earnings.csv")
summary(engs)
with(engs, boxplot(Actual-Predicted))
with(engs, t.test(Actual-Predicted))
#P-value가 크다. 귀무가설을 기각할 수 없다.
#Actual과 Predicted의 차이가 크지 않다.
attach(engs)   #적용시 with 불필요