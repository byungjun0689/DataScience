
# First Chapter 
install.packages("reshape")
library("reshape")


tips <- tips
str(tips)
# 'data.frame':	244 obs. of  7 variables:
#   $ total_bill: num  17 10.3 21 23.7 24.6 ...
# $ tip       : num  1.01 1.66 3.5 3.31 3.61 4.71 2 3.12 1.96 3.23 ...
# $ sex       : Factor w/ 2 levels "Female","Male": 1 2 2 2 1 2 2 2 2 2 ...
# $ smoker    : Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 1 1 1 ...
# $ day       : Factor w/ 4 levels "Thur","Fri","Sat",..: 4 4 4 4 4 4 4 4 4 4 ...
# $ time      : Factor w/ 2 levels "Dinner","Lunch": 1 1 1 1 1 1 1 1 1 1 ...
# $ size      : Factor w/ 6 levels "1","2","3","4",..: 2 3 3 2 4 4 2 4 2 2 ...
  
summary(tips) #평균과 중간값 이런것을 계산 해주는거는 양적변수, 아닐경우 질적변수
# total_bill         tip             sex      smoker      day         time          size          size 
# Min.   : 3.07   Min.   : 1.000   Female: 87   No :151   Fri :19   Dinner:176   Min.   :1.00     1:  4
# 1st Qu.:13.35   1st Qu.: 2.000   Male  :157   Yes: 93   Sat :87   Lunch : 68   1st Qu.:2.00     2:156
# Median :17.80   Median : 2.900                          Sun :76                Median :2.00     3: 38
# Mean   :19.79   Mean   : 2.998                          Thur:62                Mean   :2.57     4: 37
# 3rd Qu.:24.13   3rd Qu.: 3.562                                                 3rd Qu.:3.00     5: 5
# Max.   :50.81   Max.   :10.000                                                 Max.   :6.00     6: 4
                                      
head(tips)
# total_bill  tip    sex smoker day   time size
# 1      16.99 1.01 Female     No Sun Dinner    2
# 2      10.34 1.66   Male     No Sun Dinner    3
# 3      21.01 3.50   Male     No Sun Dinner    3
# 4      23.68 3.31   Male     No Sun Dinner    2
# 5      24.59 3.61 Female     No Sun Dinner    4
# 6      25.29 4.71   Male     No Sun Dinner    4

#범주형 sex, smoker, day, time 
#양적 : tip, total_bill
str(tips)
#size의 경우 1~6의 숫자로 구성 => 범주형으로 보고싶다? 여기서 size는 온 사람들의 수.
#factor를 사용.
tips$size <- factor(tips$size)

# $ size      : Factor w/ 6 levels "1","2","3","4",..: 2 3 3 2 4 4 2 4 2 2 ...

tips2 <- tips
tips2$size  <- factor(tips2$size)


mean(tips2$tip)
median(tips2$tip)
tips2$tip[1] <- 100
median(tips2$tip) # 중위수는 Outlier가 있더라도 변화가 없다. 
mean(tips2$tip)

quantile(tips$tip)

#변동성 측도. 얼마나 퍼져있느냐?
#분산, 표준편차 ( PDF식 잘못됨 )   
mean(tips$tip)
var(tips$tip)
sd(tips$tip)   # x bar + - 2sd => 95%

#변동계수 : sd/x bar => 비율을 비교할 수 있는 것이다. 
#같은 sd라도 mean에 따라 크기의 비율이 다를 수 도있다.

#IQR -> boxplot 의 range Q3 - Q1 
IQR(tips$tip)
boxplot(tips$tip,horizontal = T)
hist(tips$tip,20)
barplot(tips$tip,xlim=c(0,10))
?barplot

#Q-Q plot 그래프를 이용한 정규성 확인 
qqnorm(tips$tip)
qqline(tips$tip)

# bar chart, pie chart
# table => 도수분표표로 만들어준다. 
# 원래는 가장 먼저 나오는 순서대로 factor생성(label) 
tips$day <- factor(tips$day,levels = c("Thur","Fri","Sat","Sun")) #levels 지정하여 목~일 로 출력되도록 변경.
unique(tips$day)
mytable <- table(tips$day)
# Fri  Sat  Sun Thur 
# 19   87   76   62 
barplot(table(tips$day))

# pi chart 
lbl <- paste(names(mytable),",",round(prop.table(mytable),2)*100,"%",sep = "")  #labels 이름 부여를 위한 작업.
pie(mytable, labels=lbl) # 간단한 모양에 라벨 추가.



#두개의 범주형 변수 자료의 요약
mytable2 <- xtabs(~sex+day,tips) #앞 종속, 뒤 설명. 카운트를 하려면 앞에 없이. 를~의 기준으로 
# ~ 앞에 없으면 카운트를 세서 준다. table형태로 출력.
#          day
# sex      Thur Fri Sat Sun
# Female   32   9  28  18
# Male     30  10  59  58

class(mytable2)
par(mfcol=c(1,2))

mytable2 <- addmargins(mytable2)
mytable3 <- xtabs(~sex+day,tips) 
barplot(mytable3,legend.text = c("Female","Male"))
barplot(mytable3,legend.text = c("Female","Male"),beside = T)

#더 많은 정보를 줄 수 있음.
mosaicplot(t(mytable3)) # 전치행렬.
mosaicplot(mytable3)

#범주형 변수와 양적 변수의 요약
boxplot(tip~day,data=tips, ylab="tips",xlab="day") #종속 tip 설명 day

#두 양적변수의 요약
plot(tip~total_bill,tips)
plot(tips$total_bill,tips$tip)
cor(tips$tip,tips$total_bill)

DF <- read.csv("movie_MBA2.csv",stringsAsFactors = F)
head(DF,3)
View(DF)
str(DF)

# 'data.frame':	227 obs. of  11 variables:
#   $ title       : chr  "다크아워" "원더풀 라디오" "밀레니엄 : 여자를 증오한 남자들" "장화신은 고양이" ...
# $ release_date: chr  "2012-01-05" "2012-01-05" "2012-01-11" "2012-01-12" ...
# $ week1_sales : num  1.17e+09 3.99e+09 2.20e+09 7.75e+09 7.37e+08 ...
# $ week1_seen  : int  142322 541314 281785 883384 104258 183724 916902 335960 209516 1239057 ...
# $ nation      : chr  "미국" "한국" "미국" "미국" ...
# $ production  : chr  "" "(주)영화사아이비젼,(주)기안컬처테인먼트" "" "" ...
# $ distributor : chr  "이십세기폭스코리아(주)" "쇼박스㈜미디어플렉스" "한국소니픽쳐스릴리징브에나비스타영화㈜" "씨제이이앤엠 주식회사" ...
# $ rating      : chr  "12세이상관람가" "15세이상관람가" "청소년관람불가" "전체관람가" ...
# $ genre       : chr  "액션/어드벤쳐" "드라마" "스릴러/공포" "애니메이션" ...
# $ total_seen  : int  162704 986287 443855 2080445 206344 276334 3459864 467697 283449 4058225 ...
# $ total_sales : num  1.32e+09 7.26e+09 3.50e+09 1.76e+10 1.44e+09 ...

boxplot(DF$total_seen)
unique(DF$rating)
agratingSeen <- aggregate(total_seen~rating,data = DF,mean)
agratingSeen
# rating total_seen
# 1 12세이상관람가  1774489.7
# 2 15세이상관람가  2095732.6
# 3     전체관람가   638541.3
# 4 청소년관람불가  1015156.6

barplot(agratingSeen[,2],names.arg = agratingSeen[,1],legend.text = "관객수",main = "등급에 따른 관객수")


agratingSale <- aggregate(total_sales~rating,data = DF,mean)
# rating total_sales
# 1 12세이상관람가 13595065509
# 2 15세이상관람가 15129767237
# 3     전체관람가  4716789617
# 4 청소년관람불가  7651462719
barplot(agratingSale[,2],names.arg = agratingSale[,1],legend.text = "수익",main = "등급에 따른 수익")
class(agratingSale)


boxplot(total_seen~rating,data=DF, ylab="CNT",xlab="rating")
range(DF$total_seen)


tableOfRating <- table(DF$rating)
tableOfRating
barplot(tableOfRating,ylab="CNT",xlab="Rating")
pie(tableOfRating)
lbl2 <- paste(names(tableOfRating),",",round(prop.table(tableOfRating)* 100,2) ,"%",sep="")
pie(tableOfRating,labels = lbl2)



### 교수님 자료
summary(DF$total_seen)
boxplot(DF$total_seen,horizontal = T)
hist(DF$total_seen,20)
par(las=2,mar=c(10,5,5,5))
?par
boxplot(total_seen~rating,DF)

library("plyr")
msales <- ddply(DF,~rating,summarize,mean_sales=mean(total_sales))
class(msales)
barplot(msales[,2],names.arg = msales[,1])

tab <- xtabs(~genre+rating,DF)  # cross table
#                 rating
# genre           12세이상관람가 15세이상관람가 전체관람가 청소년관람불가
# 가족                       1              0          1              0
# 기타                       3              3          2              2
# 드라마                     8             20          2              6
# 멜로/로맨스                4              5          0              5
# 미스터리/범죄              1              9          0              6
# 스릴러/공포                0             10          0              6
# 애니메이션                 2              0         39              0
# 액션/어드벤쳐             19             33          3             14
# 코미디                     5             14          1              3
class(tab)
mosaicplot(tab,cex.axis = 1.0)
mosaicplot(t(tab),cex.axis = 1.0)
?mosaicplot

