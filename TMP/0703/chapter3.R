############ 모비율에 대한 검정 ############
# 한집단의 비율

# 국립 안전심의회(NSC)는 크리스마스와 연초 기간에
# 교통사고로 500명이 사망하고 25,000명이 부상을 입는다고
# 추정 하였다. NSC는 사고의 50%가 음주 운전으로 발생한다고
# 주장 하였다.
# 120건의 교통사고를 표본으로 조사한 결과 67건이
# 음주운전으로 일어난 사고였다.
# • 이 자료를 바탕으로 음주운전으로 일어난 사고의 비율에
# 대한 95% 신뢰구간을 구하시오.
# • 유의수준 𝛼 = .05에서 NSC의 주장을 검정하시오.

# 50% 비율이 정확히 맞는지 모르겠다. 

rm(list=ls())
prop.test(67,120) 
# probability 0.5   
# p-value = 0.2353 > 0.05  참. 50% 비율일 확률이 참. 
# 95 percent confidence interval: 0.4649273 0.6479534 
# sample estimates: p => 0.5583333 

# p=0.7 인지 검정.
prop.test(67,120,p = 0.7)   #p-value : 0.001013 < 0.05 기각.

# 시장조사 협회는 의뢰기업의 새로운 광고 캠페인 효과를 측정 하려고
# 한다. 새로운 캠페인이 시작 되기 전에 측정하고자 하는 시장지역의
# 150가구에 대하여 전화조사를 실시하였다. 조사결과, 150가구 중
# 60가구가 의뢰기업의 생산품에 대하여 알고 있었다.
# 새로운 캠페인은 TV와 신문을 통해 3주 동안 실시해 왔다. 새로운
# 캠페인이 시작된 직후 실시된 조사에서는 250가구 중 120가구가
# 의뢰회사의 제품에 대하여 알고 있다고 한다.
# 이러한 자료는 ‘새로운 광고 캠페인이 의뢰회사의 제품에 대하여
# 인지도를 증가시켰다’는 주장을 지지하는가?


prop.test(c(60,120),c(150,250),alter="less")  # c(x1,x2) c(n1,n2)   
#유의할 만큼 증가하지 않았다라고 볼 수 있다. 


# 모 비율에 대한 검정
# 독립성 검정
# H0 :우울증과 소득수준은 독립이다.
# H1 : 우울증과 소득수준은 독립적이지 않다.
DE <- matrix(c(33,28,5,67,122,45),3,2)
colnames(DE) <- c("있다","없다")
rownames(DE) <- c("저소득","중간층","고소득")
#         있다 없다
# 저소득   33   67
# 중간층   28  122
# 고소득    5   45

chisq.test(DE)  
# H0 : 독립이다.  H1: 종속적이다.
# 독립성 테스트.   p-value = 0.002222    귀무를 기각 => 독립적이지 않다.
 
#분할표만들기. 
TP <- matrix(c(48,16,20,40),2,2,byrow = T)
TP <- addmargins(TP)
class(TP)
colnames(TP) <- c("0","1","합")
rownames(TP) <- c("Treat","Placebo","Test")
#          0  1  합
# Treat   48 16  64
# Placebo 20 40  60
# Test    68 56 124



NY <- read.csv("NYReform.csv",stringsAsFactors = F)   # 찬성 : 1, 반대 : 2
str(NY)

# 'data.frame':	100 obs. of  5 variables:
#   $ Observation: int  1 2 3 4 5 6 7 8 9 10 ...
# $ Party      : chr  "Democrat" "Democrat" "Democrat" "Democrat" ...
# $ Pay.Cut    : int  1 1 2 1 2 2 1 2 1 1 ...
# $ Lobbyists  : int  2 1 1 2 2 1 2 1 1 2 ...
# $ Term.Limits: int  2 2 2 1 2 1 2 2 2 1 ...

tab1 <- xtabs(~Pay.Cut + Party, data=NY)
#         Party
# Pay.Cut Democrat Independent Republican
#    1       22          10         39
#    2       14           9          6

chisq.test(tab1)  #  p-value = 0.006135 < 0.05 기각. 독립이 아니다.
par(las=1)
par(mfcol=c(1,2))
mosaicplot(tab1)
mosaicplot(t(tab1))
tab2 <- xtabs(~Lobbyists + Party, NY)
#           Party
# Lobbyists Democrat Independent Republican
#     1       21          15         34
#     2       15           4         11

chisq.test(tab2)   # p-value = 0.1557 > 0.05 크게 정당별로 관계가 없다. 독립이다.
mosaicplot(tab2)
mosaicplot(t(tab2))

tab2 <- addmargins(tab2,1)
#           Party
# Lobbyists Democrat Independent Republican
#     1         21          15         34
#     2         15           4         11
#     Sum       36          19         45

#f번.  민주당 지지자들이 p : 0.5와 다르다고 볼 수 있냐? 로비스트 찬성에 대해서
prop.test(tab2[1,1],tab2[3,1])   # equal  21,36 에서 p=0.5  p-value = 0.4047 귀무 참. 0.5의 유의수준에 있다. 

tab3 <- xtabs(~Term.Limits+Party,NY)
tab3 <- addmargins(tab3,1)
#             Party
# Term.Limits Democrat Independent Republican
#       1       17          10         32
#       2       19           9         13
#      sum      36          19         45
chisq.test(tab3)  # 기각 X 독립 p-value = 0.07763
mosaicplot(t(tab3))

prop.test(c(17,32),c(36,45),alter="less")  #귀무가설 기각. H0 : 두 비율의 차이가 없다. => 차이가 있다. 
# p-value = 0.02519 < 0.05
# 95 percent confidence interval: -1.00000000 -0.03758875
# sample estimates: 
#  prop 1    prop 2 
# 0.4722222 0.7111111 
