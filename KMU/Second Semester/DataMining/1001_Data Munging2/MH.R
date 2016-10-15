# 과제 데이터 

library(dplyr)
library(lubridate)
library(ggplot2)

cs<-read.delim("H(TSV)/HDS_Customers.tab", stringsAsFactors=F)
tr<-read.delim("H(TSV)/HDS_Transactions_MG.tab", stringsAsFactors=F)


#박문호 지도 그리기 
install.packages("ggmap")
install.packages("maps")
library(ggmap)
library(maps)
library(stringr)

zipcode_xy = read.csv("zipcode.csv", header = TRUE)
head(zipcode_xy)
str(zipcode_xy$zipcode)
cs$zipcode <- cs$mail_zip1*1000+cs$mail_zip2 #6자리 우편번호 만들기 
# head(cs$mail_zip1)
# head(cs$mail_zip2)
# cs$zipcode <- paste0(cs$mail_zip1,cs$mail_zip2)
# str(cs$zipcode)
# cs$zipcode <- as.integer(cs$zipcode)

#1.같은 우편번호 안에서의 고객 명수 계산 
custid_cnt<-cs %>% 
  group_by(zipcode) %>%
  summarize(cust_cnt=n())

custid_cnt.map <- left_join(custid_cnt, zipcode_xy, by="zipcode") #위치 변수 붙이기 
head(custid_cnt.map)

Yu_Gi_Oh.map <- get_map("Seoul", zoom=11, maptype="roadmap")
Yu_Gi_Oh.map.custid_cnt <- ggmap(Yu_Gi_Oh.map) + geom_point(aes(x=long, y=lat, size=cust_cnt, colour=cust_cnt)
                                                            , data=custid_cnt.map)
Yu_Gi_Oh.map.custid_cnt

#2. 고객 등급의 지리적 분포 
cs <- left_join(cs, zipcode_xy)
stype_super <- cs %>%  #우량고객 선별 (고객소유형: 초우량1등급~초우량4등급)
  filter(cus_stype>=1 & cus_stype<=4)
stype_poor <- cs %>%
  filter(cus_stype>=11) #비우량고객 선별 (고객소유형: 일반1등급~일반2등급)


Yu_Gi_Oh.map <- get_map("Seoul", zoom=11, maptype="roadmap")
Yu_Gi_Oh.map.stype <- ggmap(Yu_Gi_Oh.map) + geom_point(data=stype_super, aes(x=long, y=lat), size=2, color="red") + 
  geom_point(data=stype_poor, aes(x=long, y=lat), size=1, color="blue")
Yu_Gi_Oh.map.stype

#3. 최근 12개월 구매금액 및 횟수의 분포 (수업내용에 지도 붙임)
end_date<-ymd(ymd_hms(max(tr$sales_date)))
start_date<-ymd('20010501') -months(12)

cs.v7.12 <-tr%>%      #최근 12개월 구매금액 및 횟수 구하기
  filter(start_date<=sales_date& sales_date<=end_date) %>%
  group_by(custid) %>%
  summarize(amt12=sum(net_amt), nop12=n())

cs.v7.12 <- left_join(cs.v7.12, cs) #생성 변수에 지도 좌표 붙이기

Yu_Gi_Oh.map <- get_map("Seoul", zoom=11, maptype="roadmap")
Yu_Gi_Oh.map.cs.v7.12 <- ggmap(Yu_Gi_Oh.map) + geom_point(aes(x=long, y=lat, size=amt12, colour=amt12) #구매금액 
                                                          , data=cs.v7.12)
Yu_Gi_Oh.map.cs.v7.12

Yu_Gi_Oh.map <- get_map("Seoul", zoom=11, maptype="roadmap")
Yu_Gi_Oh.map.cs.v7.12 <- ggmap(Yu_Gi_Oh.map) + geom_point(aes(x=long, y=lat, size=nop12, colour=nop12) #구매횟수 
                                                          , data=cs.v7.12)
Yu_Gi_Oh.map.cs.v7.12