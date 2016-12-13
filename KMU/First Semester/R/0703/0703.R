
# First Chapter 
install.packages("reshape")
library("reshape")

tips <- tips
summary(tips) #평균과 중간값 이런것을 계산 해주는거는 양적변수, 아닐경우 질적변ㅅ
head(tips)
#범주형 sex, smoker, day, time 
#양적 : tip, total_bill
str(tips)
#size의 경우 1~6의 숫자로 구성 => 범주형으로 보고싶다? 여기서 size는 온 사람들의 수.
#factor를 사용. 
tips2 <- tips
tips2$size  <- factor(tips2$size)

mean(tip)
median(tip)
tip[1] <- 100
median(tip) # 중위수는 Outlier가 있더라도 변화가 없다. 
mean(tip)

quantile(tip)

#변동성 측도. 얼마나 퍼져있느냐?
#분산, 표준편차 ( PDF식 잘못됨 )   
mean(tip)
var(tip)
sd(tip)   # x bar + - 2sd => 95%

#변동계수 : sd/x bar => 비율을 비교할 수 있는 것이다. 
#같은 sd라도 mean에 따라 크기의 비율이 다를 수 도있다.

#IQR -> boxplot 의 range Q3 - Q1 
IQR(tip)

boxplot(tips$tip,horizontal = T)
hist(tips$tip,20)
barplot(tips$tip,xlim=c(0,10))
?barplot

qqnorm(tips$tip)
qqline(tips$tip)

# bar chart, pie chart
# table => 도수분표표로 만들어준다. 
tips$day <- factor(tips$day,levels = c("Thur","Fri","Sat","Sun"))
unique(tips$day)
mytable <- table(tips$day)
barplot(table(tips$day))

# pi chart 
lbl <- paste(names(mytable),",",round(prop.table(mytable),2)*100,"%",sep = "")
pie(mytable, labels=lbl)

#두개의 범주형 변수 자료의 요약
mytable2 <- xtabs(~sex+day,tips) #앞 종속, 뒤 설명. 카운트를 하려면 앞에 없이. 를~의 기준으로
mytable2 <- addmargins(mytable2)
mytable3 <- xtabs(~sex+day,tips) 
barplot(mytable3,legend.text = c("Female","Male"))
barplot(mytable3,legend.text = c("Female","Male"),beside = T)

#더 많은 정보를 줄 수 있음.
mosaicplot(t(mytable3)) # 전치행렬.
mosaicplot(mytable3)

#범주형 변수와 양적 변수의 요약
boxplot(tip~day,data=tips, ylab="tips",xlab="day")

#두 양적변수의 요약
plot(tip~total_bill,tips)
plot(tips$total_bill,tips$tip)
cor(tips$tip,tips$total_bill)


DF <- read.csv("movie_MBA2.csv",stringsAsFactors = F)
head(DF)
View(DF)
str(DF)
boxplot(DF$total_seen)
unique(DF$rating)
agratingSeen <- aggregate(total_seen~rating,data = DF,mean)
agratingSeen
barplot(agratingSeen[,2],names.arg = agratingSeen[,1])

agratingSale <- aggregate(total_sales~rating,data = DF,mean)
barplot(agratingSale[,2],names.arg = agratingSale[,1])
class(agratingSale)


boxplot(total_seen~rating,data=DF, ylab="tips",xlab="rating")
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
class(tab)
mosaicplot(tab)
mosaicplot(t(tab))


