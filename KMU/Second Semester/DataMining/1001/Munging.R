# 데이터 마이닝을 위한 데이터 - Customer Signature


install.packages("lubridate")

library(dplyr)
library(lubridate)
library(ggplot2)

cs <- read.delim("H(TSV)/HDS_Customers.tab",stringsAsFactors = F)
tr <- read.delim("H(TSV)/HDS_Transactions_MG.tab", stringsAsFactors = F)
str(tr)

# 1. 고객의 환불형태(금액,건수)에 대한 변수 생
cs.v1 <- tr %>% filter(net_amt < 0) %>% group_by(custid) %>% summarize(rf_amt = sum(net_amt),rf_cnt=n())
cs.v1[order(cs.v1$rf_amt),]

# 고객의 구매상품 다양성에 대한 변수 생
cs.v2 <- tr %>% distinct(custid,brd_nm) %>% group_by(custid) %>% summarize(buy_brd=n())
head(cs.v2)

# 고객의 내점일수와 평균구매 주기를 계산
start_date = ymd(ymd_hms(min(tr$sales_date)))
end_date = ymd(ymd_hms(max(tr$sales_date)))
cs.v3 <- tr %>% distinct(custid,sales_date) %>% group_by(custid) %>% summarize(visits=n()) %>% mutate(API = as.integer(end_date - start_date)/visits)
head(cs.v3)
max(cs.v3$visits)
filter(cs.v3,visits >=100,API< 10 )

head(merge(cs.v2,cs.v1,by="custid"))
tmp <- merge(cs.v2,cs.v1,by="custid")
tmp <- merge(tmp,cs.v3,by="custid")
head(tmp)

# 내점 당 구매건수(Number of Purchases Per Visits)
tmp <- tr %>% group_by(custid) %>% summarize(n=n())
cs.v4 <- inner_join(cs.v3, tmp) %>% mutate(NPPV = n/visits) %>% select(custid,NPPV)
head(cs.v4)


#고객의 주중, 주말 구매패턴에 대한 변수 생성
tmp <- tr %>% mutate(wk_amt = ifelse(wday(sales_date) %in% 2:6 ,net_amt,0), we_amt = ifelse(wday(sales_date) %in% c(1,7),net_amt,0)) %>% group_by(custid) 
tmp <- tmp %>% summarise_each(funs(sum),wk_amt,we_amt)    
cs.v5 <- tmp %>% mutate(wk_pat = ifelse(wk_amt>=we_amt*1.5,"주중형",ifelse(we_amt>=wk_amt*1.5,"주말형","유형없음")))  
head(cs.v5)

# 고객의 생일로부터 특정시점의 나이와 연령대의 계산
cs.v6<-cs %>%
  mutate(age=year('2001-05-01') -year(ymd_hms(birth))) %>%
  mutate(age=ifelse(age < 10 | age > 100, NA, age)) %>%
  mutate(age=ifelse(is.na(age),round(mean(age,na.rm=T)),age)) %>%
  mutate(agegrp=cut(age, c(0,19,29,39,49,59,69,100), labels=F)*10) %>%
  select(custid, age, agegrp)
head(cs.v6)

# cs.v6 <-cs%>% # 위와동일한결과를얻는다른표현
#   mutate(age=year('2001-05-01') -year(ymd_hms(birth)),
#          age=ifelse(age < 10 | age > 100, NA, age),
#          age=ifelse(is.na(age),round(mean(age,na.rm=T)),age),
#          agegrp=cut(age, c(0,19,29,39,49,59,69,100), labels=F)*10) %>%
#   select(custid, age, agegrp)


#H백화점고객의최근12개월구매금액및구매횟수에대한변수생성
end_date <- ymd(ymd_hms(max(tr$sales_date)))
start_date <- ymd('20010501') - months(12)
cs.v7.12 <-tr%>%
  filter(start_date<=sales_date& sales_date<=end_date) %>%
  group_by(custid) %>%
  summarize(amt12=sum(net_amt), nop12=n())

#===================================================
#==============과                 제================
#===================================================

# 1. 가격 선호도 변수
library(dplyr)
head(tr)
tmp <- tr[tr$net_amt >0,]
tmp <- tmp[!tmp$net_amt>=72000000,]
# cs.v8 <- tr %>% mutate(mountGrp=cut(net_amt, c(0,50000,100000,150000,200000,), labels=F)) 
# Version 1
cs.v8 <- tmp
cs.v8$mountGrp <- ifelse(cs.v8$net_amt <= 50000,1,
                         ifelse(cs.v8$net_amt>50000 & cs.v8$net_amt<=100000,2,
                         ifelse(cs.v8$net_amt>100000 & cs.v8$net_amt<=150000,3,
                        ifelse(cs.v8$net_amt>150000 & cs.v8$net_amt<=200000,4,5
                        ))))
cs.v8 <- cs.v8 %>% group_by(custid) %>% select(custid,mountGrp) %>% summarize(avgPay = sum(mountGrp)/n())
cs.v8$avgPay <- round(cs.v8$avgPay) * 5
head(cs.v8)
# Version 2
tmp <- tr[tr$net_amt >0,]
tmp <- tmp[!tmp$net_amt>=72000000,]
MGRP <- function(x){
  if(x <= 50000){
    result = 1
  }else if(x > 50000 & x <= 100000){
    result = 2
  }else if(x > 100000 & x <= 150000){
    result = 3
  }else if(x > 150000 & x <= 200000){
    result = 4
  }else{
    result = 5
  }
  return(result)
}
head(tmp)
tmp <- mutate(tmp,avgPay = MGRP(net_amt))
cs.v8.2 <- tmp %>% rowwise() %>% mutate(avgPay = MGRP(net_amt)) %>% ungroup() %>% 
  group_by(custid,avgPay) %>% 
  summarize(Cnt=n()) %>%
  slice(which.max(Cnt))
head(cs.v8.2,20)


# 2. 시즌 선호도 변수
summary(ymd_hms(tr$sales_date))
min(ymd_hms(tr$sales_date))
max(ymd_hms(tr$sales_date))
cs.v9 <- tr
cs.v9$month <- month(ymd_hms(tr$sales_date))

cs.v9.3 <- cs.v9 %>% filter(month >= 3 & month <=5) %>% group_by(custid) %>% summarize(Spring = n())
cs.v9.6 <- cs.v9 %>% filter(month >= 6 & month <=8) %>% group_by(custid) %>% summarize(Summer = n())
cs.v9.9 <- cs.v9 %>% filter(month >= 9 & month <=11) %>% group_by(custid) %>% summarize(Fall = n())
cs.v9.12 <- cs.v9 %>% filter(month == 12 | month <=2) %>% group_by(custid) %>% summarize(Winter = n())
cs.v9 <- left_join(cs.v9.3,cs.v9.6) %>% left_join(cs.v9.9) %>% left_join(cs.v9.12)
fun <- function(x){
  SeasonMax <- names(which.max(x))
  return(SeasonMax)
}
cs.v9$Summer <- as.integer(cs.v9$Summer)
cs.v9$Fall <- as.integer(cs.v9$Fall)
cs.v9$Winter <- as.integer(cs.v9$Winter)
cs.v9$Season <- apply(cs.v9[,2:5],1,fun)
cs.v9 <- select(cs.v9,custid,Season)
head(cs.v9)

#version 2
Sea <- function(x){
  if(x >= 3 & x <=5){
    result = 'Spring'
  }else if(x >= 6 & x <=8){
    result = 'Summer'
  }else if(x >= 9 & x <=11){
    result = 'Fall'
  }else{
    result = 'Winter'
  }
  return(result)
}

cs.v9 <- tr
cs.v9$month <- month(ymd_hms(tr$sales_date))
cs.v9 <- cs.v9 %>% rowwise() %>% mutate(season = Sea(month)) %>% ungroup()
cs.v9 <- cs.v9 %>% group_by(custid,season) %>% summarize(cnt = n()) %>% slice(which.max(cnt))
head(cs.v9)
# 3. 구매추세 패턴
cs.v11 <- tr
cs.v11$month <- ym(ymd_hms(tr$sales_date))
cs.v11$year <- year(ymd_hms(tr$sales_date))
head(ymd(ymd_hms(tr$sales_date)))
?lubridate
cs.v11 <- cs.v11 %>% group_by(custid,month) %>% summarize(sum_amt=sum(net_amt))
head(cs.v11)

ggplot(cs.v11[cs.v11$custid == 1,], aes(month, sum_amt)) + 
  geom_line()
summary(cs.v11[cs.v11$custid = 1,])


# 4. 상품별 구매 금액/횟수/여부 변수 
head(tr$goodcd)
str(tr)
cs.v10 <- tr %>% filter(net_amt > 0) %>% group_by(goodcd) %>% summarize(amt = sum(net_amt), Cnt = n())
head(cs.v10)
# 5. 상품별 구매 순서 
install.packages("arulesSequences")
install.packages("tidyr")
install.packages("arules")
library(arulesSequences)
library(tidyr)
library(arules)

# 6. 주 구매 상품 변수
cs.v12 <- tr %>% group_by(custid,goodcd) %>% summarize(cnt = n()) %>% slice(which.max(cnt))
head(cs.v12)

# 7. 휴면/이탈 가망 변수 (Ex) if 평균 구매 주기 < 최종구매경과(현재-마지막 구매 시점) then 이탈


