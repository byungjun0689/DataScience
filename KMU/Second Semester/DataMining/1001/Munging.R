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
str(tr)
boxplot(tr$net_amt)
summary(tr[tr$net_amt >0,]$net_amt)
tmp <- tr[tr$net_amt >0,]
plot(tmp$net_amt)
summary(tmp$net_amt)
cs.v8 <- tr %>% mutate(mountGrp=cut(net_amt, c(0,50000,100000,150000,200000), labels=F)*50000) 
cs.v8 <- cs.v8 %>% group_by(mountGrp) %>% summarize(cnt=n())
head(cs.v8)
sum(cs.v8$cnt)
nrow(tmp)
# 2. 시즌 선호도 변수
summary(ymd_hms(tr$sales_date))
min(ymd_hms(tr$sales_date))
max(ymd_hms(tr$sales_date))
cs.v9 <- tr
cs.v9$sales_date <- ymd_hms(tr$sales_date)
cs.v9$month <- month(cs.v9$sales_date)
head(cs.v9)
# 봄
spring <- filter(cs.v9, month >=3 & month <=5)
spring$month <- 1
# 여름
summer <- filter(cs.v9, month >=6 & month <=8)
table(summer$month)
summer$month  <- 2
# 가을 
fall <- filter(cs.v9, month >=9 & month <=11)
table(fall$month)
fall$month <- 3
# 겨울 
winter <- filter(cs.v9, month == 12 | month <=2)
head(winter)
table(winter$month)
winter$month <- 4
tmp <- rbind(spring,summer) %>% rbind(fall) %>% rbind(winter)
head(tmp)
cs.v9 <- tmp %>% group_by(month) %>% summarize(Cnt = n())
head(cs.v9)
# 3. 구매추세 패턴
# 4. 상품별 구매 금액/횟수/여부 변수 
head(tr$goodcd)
str(tr)
cs.v10 <- tr %>% filter(net_amt > 0) %>% group_by(goodcd) %>% summarize(amt = sum(net_amt), Cnt = n())
head(cs.v10)
# 5. 상품별 구매 순서 
# 6. 주 구매 상품 변수
# 7. 휴면/이탈 가망 변수 (Ex) if 평균 구매 주기 < 최종구매경과(현재-마지막 구매 시점) then 이탈