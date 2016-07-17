####################################################
##########경영통계 데이터 요약 및 정리##############
####################################################

library(reshape)

summary(tips)
str(tips2)
tips <- tips   #변수화
attach(tips)   #tips에 넣는다
total_bill     #tips$total_bill이라고 하나하나 다 쓰지 않아도 된다 

tips2 <- tips
tips2$size <- factor(tips2$size) #양적 변수가 아닌 범주형으로 인식하기 위함
summary(tips2)
summary(tips)

###중심위치측도###
mean(tips$tip)
median(tips$tip)
quantile(tips$tip)
quantile(tips$tip, seq(0.1, 0.1))
#중심위치측도의 차이?
tips2$tip[1] = 100   #max값을 바꾸기 위함 (기존:10)
mean(tips2$tip)
median(tips2$tip)

###변동성측도###
var(tip)
sd(tip)
sd(tip)/mean(tip)   #변동계수
#같은 표준편차(예-3)이더라도, 평균이 10과 50이라면 표준편차가 가지는 의미가 다르다.
#평균이 50일 때의 표준편차 3은 10일때 보다 더 작게 느껴진다. 
IQR(tip)

###그래프###
boxplot(tip)
boxplot(tip, horizontal=T)
windows()   #별도의 창을 만들어 plot 등 표시 by R Graphics

hist(tip)
hist(tip,20,probability=T)   #비율 함께 표시 

qqnorm(tip)
qqline(tip)
#정규분포에 얼마나 근접한지 판단 

###도수분포표###
day
table(day)
barplot(table(day))
#level의 이슈 (Fri > Sat > Sun > Thur)
day <- factor(tips$day,levels=c("Thur", "Fri", "Sat", "Sun"))
barplot(table(day))

mytable <- table(day)
pie(mytable)
pie(mytable, labels=c(1,2,3,4))              

names(mytable)
mytable
round(mytable/sum(mytable)*100,1)   #퍼센트 계산 with 올림 

lbl <- paste(names(mytable),",",round(mytable/sum(mytable)*100,1) ,"%",sep="")
lbl <- paste(names(mytable),",",round(prop.table(mytable),2)*100,"%",sep="")
lbl

mytable2 <- xtabs(~sex+day,tips)
barplot(mytable2)   #그래프만 나오고 별도 설명이 없음
barplot(mytable2,legend.text=c("Female","Male"))   #보다 쉬운 비교를 위해 그래프 나누려면?
barplot(mytable2,legend.text=c("Female","Male"),beside=T)

mosaicplot(mytable2)   #비율 비교 (여자 남자의 요일별 비율)
mosaicplot(t(mytable2))   #transpose (요일에 따른 남녀 비교)
   #토요일이 전체적으로 제일 많고, 목요일 내에서는 남녀 비슷, 토요일은 남녀 차이 큼 등 

boxplot(tip~day, data=tips, ylab="tips")
#요일별로 tip의 분포 비교 

plot(tip~total_bill,tips)
#tip이 y축, 아래도 같은 내용임! 
plot(total_bill, tip)

############ PRACTICE ##############
mov <- read.csv("movie_MBA2.csv")
str(mov)

boxplot(mov$total_seen, horizontal=T)
hist(mov$total_seen)
#우측에 outlier가 너무 많다, 적당히 변환 후 분석 진행 필요 

aggregate(total_sales~rating, data=mov, mean)
boxplot(total_sales~rating, data=mov, mean, ylab="tips", xlab="rating")

par(las=2,mar=c(10,5,5,5))   #table을 보다 보기 쉽게 정리 (12세 이상 등의 이름이 긴 라벨)
?par
boxplot(total_seen~rating, mov)

table(mov$rating)
barplot(table(mov$rating))
pie(table(mov$rating))
lbl2 <- paste(names(table(mov$rating)),",",round(prop.table(table(mov$rating))* 100,2),
              "%",sep="")`
pie(table(mov$rating),labels = lbl2)

library(plyr)
msales <- ddply(mov, ~rating, summarize, mean_sales <- mean(total_sales))
barplot(msales[,2], names.arg=msales[,1])
tab <- xtabs(~genre+rating, mov)
tab

mytable3 <- xtabs(~rating+genre, mov)
barplot(mytable3)
barplot(mytable3, legend.text=c("12세이상", "15세이상", "전체", "청소년"), beside=T)
unique(mov$genre)

par(las=2)
mosaicplot(tab)
mosaicplot(t(tab))
