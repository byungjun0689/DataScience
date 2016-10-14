# 살인(murder)와 절도(burglary) 사이의 관계를 살피려고 한다
# A. 두 변수 사이의 산점도를 단변량 분포와 함께 그리시오. 상관계수도 함께 살피시오.

library(psych)
Crime <- read.csv("crime.csv",stringsAsFactors = F)
#crime2 <- subset(Crime,select = c("state","murder","burglary"))
pairs.panels(Crime[,-1])  # cor : 0.22

plot(crime2[,c(2,3)]) 


# B. 위를 통해 이상점 존재여부를 판단하고 존재한다면 해당 주를 확인하고 제거하시오. 제거 후 변수들 사이의 관계가 어떻게 변화하는지 살피시오.
plot(Crime$robbery,Crime$burglary,xlim=c(0,800))
identify(Crime$robbery,Crime$burglary,labels=Crime$state)

plot(Crime$robbery, Crime$population)
identify(Crime$robbery,Crime$population,labels=Crime$state)


out=match(c("United States","District of Columbia"),Crime$state)
clr=rep(1,dim(Crime)[1])
clr[out]=2
pairs(Crime[,-1],col=clr,pch=clr)
Crime2<-Crime[-out,]
pairs.panels(Crime2[,-1])   # cor: 0.62

# C. 살인, 절도와 인구(population)의 관계를 함께 관찰하기 위해 bubble plot을 그리고 관찰한 사실을 기술하시오.
with(Crime2, symbols(murder,burglary,circles = population)) # 인구가 많을 수록 살인과 강도가 많은 경우가 발생하나 무조건 적인지는 않다. 

# D. 7가지 범죄의 발생 건수를 heatmap으로 표현하고 범죄 발생 특징 간의 패턴이 비슷한 주들이 있는지 살피시오.
# burglary 와 Murder 관계 외 forible_rape 과 murder에서의 이상점 ( alasak 도 삭제)
out=match(c("United States","Alaska","District of Columbia"),Crime$state)
Crime3 <- Crime[-out,]
pairs.panels(Crime3[,-1])

install.packages("RColorBrewer")
library(RColorBrewer)
TmpCrime <- Crime3
rownames(TmpCrime) <- Crime3[,1]
TmpCrime <- TmpCrime[,-1]
TmpCrime <- as.matrix(TmpCrime)
head(TmpCrime)
heatmap(TmpCrime[,-8], scale="column", col=brewer.pal(9,"Blues"))

summary(Crime)
install.packages("outliers")
library(outliers)
out <- outlier(Crime[,-1])
pairs.panels(Crime[,-1])
out <- as.data.frame(out)

# 2. Baseball_201509.csv는 2015년 9월 현재 한국 프로야구 각 팀의 
# 성적을 보여준다. 이 자료를 이용해 별그림, 나이팅게일 차트를 적절한 
# label을 포함하여 그리고 비슷한 패턴을 가지는 그룹으로 나누어 
# 각 그룹이 어떤 변수적 특징을 가지는지 서술하여라.

bball <- read.csv("http://datasets.flowingdata.com/ppg2008.csv")
rownames(bball) <- bball[,1]
bball <- bball[,-1]
# 1) Nightingale's Chart
star <- stars(bball,cex=0.7, draw.segments = TRUE)
star
sapply(star, max) # 16.1 18.4
stars(bball,cex=0.7, key.loc=c(19.5,2),draw.segments = TRUE)
stars(bball,cex=0.7, key.loc=c(19.5,2))

bball2 <- bball[,2:20]
bball2 <- as.matrix(bball2)
bball2 <- bball2[order(bball2[,3], decreasing = F),]
heatmap(bball2,scale = "column",margins = c(5,10),col=brewer.pal(9,"Blues"))


