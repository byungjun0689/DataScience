#text, plot, scoping#
#NO 기말고사#
#데이터 분석 as 기말 리포트#

library(dplyr)
install.packages("reshape2")
library(reshape2)

### data loading -----
cust <- read.csv("customerDb.csv", stringsAsFactors=F)
head(cust)
dim(cust)
str(cust)
table(cust$city)
table(cust$sex)
basket <- read.csv("basketData.csv", stringsAsFactors=F)
head(basket);tail(basket)
str(basket)

# Getage <- function(x){
#   mod <- floor(x / 10) * 10
#   return(mod)
# }
# 
# sapply(cust$age, Getage)

cust$age_group <- floor(cust$age / 10) * 10
table(cust$age_group)

cust %>% 
  group_by(sex,age_group) %>%
  summarize(N=n(), avg_age = mean(age))          # 그룹화 한것의 갯수, 평균 나이.

tmp <- function(age) floor(mean(age)) + 1

custage <- cust %>% 
  group_by(sex,age_group) %>%
  summarize(N=n(), avg_age = tmp(age))          # 그룹화 한것의 갯수, 평균 나이.

# cust %>% 
#   group_by(sex,age_group) %>%
#   summarize(N=n(), avg_age = function(age){mean(age) + 1})          # 그룹화 한것의 갯수, 평균 나이.
custage
dcast(custage, sex ~ age_group, value.var = "N", fun.aggregate = sum)  
# dcast(데이터, 행, 열, 값, 함수)
# x 는 sex y 는 age_group 값은 N을 넣고 각각의 값은 sum으로 함수를 실행한다.


########################################
###############   basket  ##############
str(basket)
tmp <- basket
tmp$dummy <-1

a <- aggregate(dummy ~ custId + date, data = tmp, sum)
a <- a[order(a$custId, decreasing = T),]


### 기본 EDA--------------

#Who are top 10 in purchase amount?
basket %>%
  group_by(custId) %>%  # id로 그룹바이 하고 내용을 사용금액을 합. 나열.desc로 
  summarize(ttl_amt=sum(amount)) %>%
  arrange(desc(ttl_amt))

#Who are top 10 in visit frequency?
##원본 코드
basket %>%
  group_by(custId) %>%
  summarize(visit=n()) %>% 
  arrange(desc(visits))

basket %>%
  group_by(custId,receiptNum) %>%
  summarize(visit=n()) %>% 
  group_by(custId) %>% 
  summarize(visits=n()) %>%   # sum()을 안하는 이유는 영수증 내 항목으로 구성되어있어서 sum을 하게 되면 몇개를 샀는지가 된다.
  arrange(desc(visits))

#Who are top 10 in average purchase amount?
basket %>%
  group_by(custId) %>%
  summarize(avg_amt=mean(amount)) %>%
  arrange(desc(avg_amt))

#what time is biggest sales hour?
basket %>%
  group_by(time) %>%
  summarize(amt=mean(amount)) %>%
  arrange(desc(amt))

##sum이 맞는듯함.
basket %>%
  group_by(time) %>%
  summarize(amt=sum(amount)) %>%
  arrange(desc(amt))

#what time is biggest sales hours of each branch?
dummy <- basket %>%
  group_by(time, branchId) %>%
  summarize(amt=mean(amount))

dummy1 <- dcast(dummy, time ~ branchId, fun.aggregate=sum, value.var="amt")
dummy2 <- dcast(dummy, branchId ~ time, fun.aggregate=sum, value.var="amt")
class(dummy)
args(dcast)
branchHour <- as.data.frame(dummy1)
branchHour2 <- as.data.frame(dummy2)
round(dummy1,0)
branchHour$best <- apply(branchHour[,-1], 1,which.max)
branchHour

dummy1

dummy2 <- melt(dummy1, id.var="time")
dummy2


##Continue RFM
head(basket)
head(cust)
basket$date <- as.Date(as.character(basket$date), format="%Y%m%d")
basket$date_num <- as.numeric(basket$date)
date_dum <- as.Date(basket$date_num, origin="1970-01-01")



##RFM의 의미 이해 필요
library(dplyr)

rfm_dummy <- basket %>%
  group_by(custId, date) %>%
  summarize(N=n())
rfm_dummy

userF <- basket %>%
  group_by(custId, date) %>%
  summarize(N=n()) %>%
  group_by(custId) %>%
  summarize(freq=n())
userF


userRFM <- basket %>%
  group_by(custId) %>%
  summarize(minRecency=min(date_num),
            recency=max(date_num),
            monetary=sum(amount),
            period=max(date_num)-min(date_num))

userRFM <- basket %>%
  group_by(custId) %>%
  summarize(minRecency=min(date),
            recency=max(date),
            monetary=sum(amount),
            period=as.numeric(max(date)-min(date)))


userRFM
userRFM <- left_join(userRFM, userF)

head(userRFM);tail(userRFM)


##RFM연습 다시 시작-------

hist(userRFM$recency, breaks=10)

str(userRFM)
length(unique(userRFM$maxDate))
hist(userRFM$monetary, breaks=100)
range(userRFM$monetary)

plot(table(userRFM$recency), main="Guests Recency")

plot(table(userRFM$freq), main="Guests Frequency")


# 분위수를 따로 구한다.

quantile(userRFM$monetary, c(0.2,0.4,0.6,0.8))

quantile(as.numeric(userRFM$recency), c(0.2,0.4,0.6,0.8)) # be careful about as.numeric


# RFM별로 상위 20%가 차지하는 총 매출액 대비 비중을 구한다.

sumM <- sum(userRFM$monetary[userRFM$monetary > quantile(userRFM$monetary, 0.8)])
sumM/sum(userRFM$monetary) # 65%

sumF <- sum(userRFM$monetary[userRFM$freq > quantile(userRFM$freq, 0.8)])
sumF/sum(userRFM$monetary) # 58%

as.Date(quantile(as.numeric(userRFM$recency),0.8), origin="1970-01-01")
head(as.numeric(userRFM$recency))
str(userRFM)

sumR <- sum(userRFM$monetary[as.numeric(userRFM$recency) > quantile(as.numeric(userRFM$recency), 0.8)])
sumR/sum(userRFM$monetary) # 42%

(weightR <- sumR/(sumR + sumF + sumM))
(weightF <- sumF/(sumR + sumF + sumM))
(weightM <- sumM/(sumR + sumF + sumM))

# RFM지수 = weightR * Recency 점수 + weightF * Frequency점수 + weightM * Monetary 점수

quantM <- quantile(userRFM$monetary,c(0,0.2,0.4,0.6,0.8,1))
quantM
quantR <- as.Date(quantile(as.numeric(userRFM$recency),c(0,0.2,0.4,0.6,0.8,1)),origin="1970-01-01")
quantR
quantF <- quantile(userRFM$freq,c(0,0.2,0.4,0.6,0.8,1))
quantF



# parse 함수 활용방법
columnName <- paste0("userRFM","$","frequency")
eval(parse(text=columnName))[2] # 문자열 조합으로 데이터프레임의 열을 찾는 방법
# ?parse


head(userRFM$frequency)


intervalGrade <- function(mainData, fileName, rfmName, quantileData) {
  
  forLength <- dim(mainData)[1]
  
  results <- rep(0, forLength)
  
  
  for (i in 1:forLength) {
    
    data <- eval(parse(text=paste0(fileName,"$",rfmName)))[i]
    
    if (data >= quantileData[1] && data < quantileData[2] ) {
      results[i] <- 1
    } else if (data >= quantileData[2] && data < quantileData[3]) {
      results[i] <- 2
    } else if (data >= quantileData[3] && data < quantileData[4]) {
      results[i] <- 3
    } else if (data >= quantileData[4] && data < quantileData[5]) {
      results[i] <- 4
    } else { results[i] <- 5 }
  }
  
  return(results)
}


userRFM$R <- intervalGrade(userRFM, "userRFM", "recency", quantR )
userRFM$F <- intervalGrade(userRFM, "userRFM", "freq", quantF )
userRFM$M <- intervalGrade(userRFM, "userRFM", "monetary", quantM )

head(userRFM)

userRFM$score <- (weightR * userRFM$R + weightF * userRFM$F + weightM * userRFM$M)*100/5

hist(userRFM$score)


dim(userRFM)

(quantS <- quantile(userRFM$score,c(0,0.2,0.4,0.6,0.8,1)))

finalGrade <- function(mainData, fileName, rfmName, quantileData) {
  
  forLength <- dim(mainData)[1]
  
  results <- rep(0, forLength)
  
  
  for (i in 1:forLength) {
    
    data <- eval(parse(text=paste0(fileName,"$",rfmName)))[i]
    
    if (data >= quantileData[1] && data < quantileData[2] ) {
      results[i] <- "E"
    } else if (data >= quantileData[2] && data < quantileData[3]) {
      results[i] <- "D"
    } else if (data >= quantileData[3] && data < quantileData[4]) {
      results[i] <- "C"
    } else if (data >= quantileData[4] && data < quantileData[5]) {
      results[i] <- "B"
    } else { results[i] <- "A" }
  }
  
  return(results)
}

userRFM$grade <- finalGrade(userRFM, "userRFM", "score", quantS )
head(userRFM)
str(userRFM)

