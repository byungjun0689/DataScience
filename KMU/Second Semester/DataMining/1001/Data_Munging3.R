
install.packages("ggmap")
install.packages("maps")

rm(list=ls())

library(dplyr)
library(lubridate)
library(ggplot2)
library(ggmap)
library(maps)
library(stringr)

cs <- read.delim("H(TSV)/HDS_Customers.tab", stringsAsFactors = F)
tr <- read.delim("H(TSV)/HDS_Transactions_MG.tab", stringsAsFactors = F)
tr.input <- tr

# Data Munging Team Report

# 1. 환불형태(금액,건수) #
cs.v1 <- tr.input %>% filter(net_amt < 0) %>% 
  group_by(custid) %>% 
  summarize(rf_amt = sum(net_amt),rf_cnt=n())

# 2. 구매상품 다양성 #
cs.v2 <- tr.input %>% 
  distinct(custid,brd_nm) %>% 
  group_by(custid) %>% 
  summarize(buy_brd=n())

# 3. 내점일수와 평균구매주기 #
start_date = ymd(ymd_hms(min(tr$sales_date)))
end_date = ymd(ymd_hms(max(tr$sales_date)))
cs.v3 <- tr.input %>% 
  distinct(custid,sales_date) %>% 
  group_by(custid) %>% 
  summarize(visits=n()) %>% 
  mutate(API = round(as.integer(end_date - start_date)/visits))

# 4. 내점 당 구매건수(Number of Purchases Per Visit) #
tmp <- tr.input %>% 
  group_by(custid) %>% 
  summarize(n=n())
cs.v4 <- inner_join(cs.v3, tmp) %>% 
  mutate(NPPV = n/visits) %>% 
  select(custid,NPPV)

# 5. 주중•주말 구매 패턴 #
tmp <- tr.input %>% 
  mutate(wk_amt = ifelse(wday(sales_date) %in% 2:6 ,net_amt,0), 
         we_amt = ifelse(wday(sales_date) %in% c(1,7),net_amt,0)) %>% 
  group_by(custid) 
tmp <- tmp %>% summarise_each(funs(sum),wk_amt,we_amt)    
cs.v5 <- tmp %>% mutate(wk_pat = ifelse(wk_amt>=we_amt*1.5,"주중형",
                                        ifelse(we_amt>=wk_amt*1.5,"주말형",
                                               "유형없음")))
ggplot(cs.v5, aes(wk_pat)) + geom_bar(aes(fill=wk_pat))

# 6. 고객의 생일로부터 특정 시점의 나이와 연령대 #
cs.v6<-cs %>%
  mutate(age=year('2001-05-01') -year(ymd_hms(birth))) %>%
  mutate(age=ifelse(age < 10 | age > 100, NA, age)) %>%
  mutate(age=ifelse(is.na(age),round(mean(age,na.rm=T)),age)) %>%
  mutate(agegrp=cut(age, c(0,19,29,39,49,59,69,100), labels=F)*10) %>%
  select(custid, age, agegrp)

cs.v6_2 <-cs%>% # 같은 결과의 다른 표현
  mutate(age=year('2001-05-01') -year(ymd_hms(birth)),
         age=ifelse(age < 10 | age > 100, NA, age),
         age=ifelse(is.na(age),round(mean(age,na.rm=T)),age),
         agegrp=cut(age, c(0,19,29,39,49,59,69,100), labels=F)*10) %>%
  select(custid, age, agegrp)

# 7. H백화점 고객의 최근 12개월 구매 금액 및 구매 횟수 #
end_date <- ymd(ymd_hms(max(tr$sales_date)))
start_date <- ymd('20010501') - months(12)
cs.v7.12 <-tr.input %>%
  filter(start_date<=sales_date& sales_date<=end_date) %>%
  group_by(custid) %>%
  summarize(amt12=sum(net_amt), nop12=n())

# 8. 최근 3개월, 6개월, 12개월 구매 금액 및 횟수 #
start_date<-ymd('20010501') -months(6)
cs.v7.06 <-tr%>%
  filter(start_date<=sales_date& sales_date<=end_date) %>%
  group_by(custid) %>%
  summarize(amt6=sum(net_amt), nop6=n())

start_date<-ymd('20010501') -months(3)
cs.v7.03 <-tr%>%
  filter(start_date<=sales_date& sales_date<=end_date) %>%
  group_by(custid) %>%
  summarize(amt3=sum(net_amt), nop3=n())

# 8_1. 병합 후 amt6, nop6, amt3, nop3가 NA이면 0으로 대체 #
cs.v7 <- left_join(cs.v7.12, cs.v7.06) %>% left_join(cs.v7.03)

cs.v7[is.na(cs.v7$amt6),]$amt6 <- 0
cs.v7[is.na(cs.v7$nop6),]$nop6 <- 0
cs.v7[is.na(cs.v7$amt3),]$amt3 <- 0
cs.v7[is.na(cs.v7$nop3),]$nop3 <- 0

###############################################################################

###############################################################################

# 9. 가격 선호도 변수 (Price Preference = pr_pref) ####
summary.value <- summary(tr.input$net_amt)
# IQR(사분위수)를 기반으로 4개 등급 생성

tmp <- tr.input
cs.v9 <- tmp %>% mutate(grade1 = ifelse(net_amt < summary.value[[2]], 1,0),
                        grade2 = ifelse(net_amt >= summary.value[[2]] 
                                        & net_amt < summary.value[[3]], 1,0),
                        grade3 = ifelse(net_amt >= summary.value[[3]] 
                                        & net_amt < summary.value[[5]], 1,0),
                        grade4 = ifelse(net_amt >= summary.value[[5]] 
                                        & net_amt < summary.value[[6]], 1,0),
                        grade5 = ifelse(net_amt >= summary.value[[6]] 
                                        & is.na(net_amt), 1,0)) %>% 
  group_by(custid) %>% 
  summarize(grade1 = sum(grade1),
            grade2 = sum(grade2),
            grade3 = sum(grade3),
            grade4 = sum(grade4),
            grade5 = sum(grade5))
cs.v9 <- cs.v9 %>% 
  mutate(pr_pref = apply(cs.v9[,-1],1,which.max)) %>% 
  select(custid,pr_pref)

# 10. 시즌 선호도 변수 (Season Preference = sea_pref) ####
rm(cs.v10)
tmp <- tr.input
cs.v10 <- tmp %>% mutate(Spring = ifelse(as.numeric(substr(sales_date,6,7)) <= 5 
                                         & as.numeric(substr(sales_date,6,7)) >= 3,1,0),
                         Summer = ifelse(as.numeric(substr(sales_date,6,7)) <= 8 
                                         & as.numeric(substr(sales_date,6,7)) >= 6,1,0),
                         Fall = ifelse(as.numeric(substr(sales_date,6,7)) <= 11 
                                       & as.numeric(substr(sales_date,6,7)) >= 9,1,0),
                         Winter = ifelse(as.numeric(substr(sales_date,6,7)) <= 2 
                                         & as.numeric(substr(sales_date,6,7)) >= 12,1,0)) %>% 
  group_by(custid) %>% 
  summarize(Spring = sum(Spring),
            Summer = sum(Summer),
            Fall = sum(Fall),
            Winter = sum(Winter)) 
cs.v10 <- cs.v10 %>% 
  mutate(sea_pref = apply(cs.v10[,-1],1,which.max)) %>% 
  select(custid,sea_pref)

# 11. 상품별 구매 금액/횟수 변수 #
cs.v11 <- tr.input %>% filter(net_amt > 0) %>% 
  group_by(goodcd) %>% 
  summarize(goodcd_totamt = sum(net_amt), goodcd_Cnt = n())

# 12. 주 구매 상품 변수 #
cs.v12 <- tr %>% 
  group_by(custid,goodcd) %>% 
  summarize(main_good_cnt = n()) %>% 
  slice(which.max(main_good_cnt)) %>% 
  select(custid,goodcd) %>%
  rename(fav_goodcd = goodcd) 

# 13. 휴면/이탈 가망 고객 #

# sys.date <- as.numeric(gsub("-","",as.character(Sys.Date())))
sys.date <- 20010530
# Data 맞춤 sys.date 설정 

tmp <- tr.input
tmp$sales_date <- as.numeric(gsub("-","",substr(tr.input$sales_date,1,10)))
cs.v13 <- tmp %>% group_by(custid) %>%
  arrange(sales_date) %>%
  summarize(avg.date = (mean(diff(sales_date))), last.date = max(sales_date),
            sys.date) %>%
  mutate(stay_out = ifelse(sys.date-last.date > avg.date, "Y", "N")) %>%
  select(custid,stay_out)
# cs.v13 <- merge(x = tr.input, y = cs.tmp, by = "custid") %>% select(custid,stay_out)

# 14. 주 구매 시간대 ####
# install.packages("Kmisc")
library(Kmisc)
library(stringr)

tmp <- tr.input
tmp[tmp$sales_time<=900,'sales_time'] <- round(mean(tmp$sales_time))
tmp$fav_time <- str_rev(tmp$sales_time)
tmp$fav_time <- paste0(str_sub(tmp$fav_time,1,2),":",
                       str_sub(tmp$fav_time,3,nchar(tmp$fav_time)))
tmp$fav_time <- hour(hm(str_rev(tmp$fav_time)))

cs.v14 <- tmp %>% 
  group_by(custid,fav_time) %>% 
  summarize(cnt=n()) %>% 
  slice(which.max(cnt)) %>%
  select(custid,fav_time)

# 15. 선호하는 지불형태 (할부 여부) #
cs.v15 <- tr.input %>% 
  group_by(custid,inst_mon) %>% 
  summarize(cnt = n()) %>% 
  slice(which.max(cnt)) %>% 
  rename(fav_paymthd=inst_mon) %>%
  select(custid,fav_paymthd)

# 16. Part별 최대 구매 part와 평균 구매액, 구매횟수 ####
cs.v16 <- tr.input %>% 
  group_by(custid, part_nm) %>% 
  summarize(mean_amt = mean(net_amt), cnt = n()) %>% 
  slice(which.max(cnt)) %>% 
  rename(fav_part = part_nm, fav_part_mean_amt = mean_amt, fav_part_cnt = cnt)

# 17. id별 주 이용지점 ####
cs.v17 <- tr.input %>% 
  group_by(custid, str_nm) %>% 
  summarize(cnt=n()) %>% 
  slice(which.max(cnt)) %>% 
  rename(main_store=str_nm) %>%
  select(custid,main_store)

# 18. 적용 할인율 ####
cs.v18 <- tr.input %>%
  mutate(dis_rate = round(dis_amt/tot_amt*100, 2)) %>%
  group_by(custid) %>%
  summarize(avg_disc = round(mean(dis_rate)),2) %>%
  select(custid,avg_disc)

# 19. 그룹사 인지 아닌지 ####

job <- read.csv("H(TSV)/HDS_Jobs.tab",sep="\t")
cs.v19 <- cs %>% 
  left_join(job, by="job_stype") %>% 
  mutate(group_member = ifelse(job_nm_gr=="그룹사", "그룹사", "일반회원")) %>% 
  select(custid,group_member)
head(cs.v19)

nrow(cs.v19[which(cs.v19$group_member == "일반회원"),])
nrow(cs.v19[which(cs.v19$group_member == "그룹사"),])

# 합칠때는 11은 custid별로 되어있지 않으므로 join하지 말것.

cust_sig <- cs%>%
  left_join(cs.v1) %>% left_join(cs.v2) %>%
  left_join(cs.v3) %>% left_join(cs.v4) %>%
  left_join(cs.v5) %>% left_join(cs.v6) %>%
  left_join(cs.v7) %>% left_join(cs.v9) %>%
  left_join(cs.v10) %>%
  left_join(cs.v12) %>% left_join(cs.v13) %>%
  left_join(cs.v14) %>% left_join(cs.v15) %>%
  left_join(cs.v16) %>% left_join(cs.v17) %>% 
  left_join(cs.v18) %>% left_join(cs.v19) 

cust_sig[is.na(cust_sig$rf_amt),]$rf_amt <- 0
cust_sig[is.na(cust_sig$rf_cnt),]$rf_cnt <- 0
# NA 값 0으로 대체 


############################ 합칠 수 없는 부분 그냥 시연만 ########################

# 16. 같은 우편 번호 안에서의 고객 수####
zipcode_xy = read.csv("zipcode.csv", header = TRUE)
cs$zipcode <- cs$mail_zip1*1000+cs$mail_zip2 #6자리 우편번호 만들기 

custid_cnt<-cs %>% 
  group_by(zipcode) %>%
  summarize(cust_cnt=n())

custid_cnt.map <- left_join(custid_cnt, zipcode_xy, by="zipcode") #위치 변수 붙이기 
custid.map <- get_map("Seoul", zoom=11, maptype="roadmap")
custid.map.custid_cnt <- ggmap(custid.map) + geom_point(aes(x=long, y=lat, 
                                                            size=cust_cnt, colour=cust_cnt)
                                                        , data=custid_cnt.map)
custid.map.custid_cnt

# 17. 고객 등급의 지리적 분포 ####
cs <- left_join(cs, zipcode_xy)
stype_super <- cs %>%  #우량고객 선별 (고객소유형: 초우량1등급~초우량4등급)
  filter(cus_stype>=1 & cus_stype<=4)
stype_poor <- cs %>%
  filter(cus_stype>=11) #비우량고객 선별 (고객소유형: 일반1등급~일반2등급)

custid.map <- get_map("Seoul", zoom=11, maptype="roadmap")
custid.map.stype <- ggmap(custid.map) + 
  geom_point(data=stype_super, aes(x=long, y=lat), size=2, color="red") + 
  geom_point(data=stype_poor, aes(x=long, y=lat), size=1, color="blue") 
custid.map.stype

# # 18. 최근 12개월 구매금액 및 횟수의 분포 (수업내용에 지도 붙임) ####
# end_date<-ymd(ymd_hms(max(tr$sales_date)))
# start_date<-ymd('20010501') -months(12)
# 
# cs.v20 <-tr.input %>%      #최근 12개월 구매금액 및 횟수 구하기
#   filter(start_date<=sales_date& sales_date<=end_date) %>%
#   group_by(custid) %>%
#   summarize(amt12=sum(net_amt), nop12=n())
# 
# cs.v20 <- left_join(cs.v20, cs) #생성 변수에 지도 좌표 붙이기
# 
# #구매금액 
# custid.map <- get_map("Seoul", zoom=11, maptype="roadmap")
# custid.map.cs.v7 <- ggmap(custid.map) + geom_point(aes(x=long, y=lat, size=amt12, colour=amt12), data=cs.v7)
# custid.map.cs.v7
# 
# #구매횟수 
# custid.map <- get_map("Seoul", zoom=11, maptype="roadmap")
# custid.cs.v7.2 <- ggmap(custid.map) + geom_point(aes(x=long, y=lat, size=nop12, colour=nop12), data=cs.v7)
# custid.cs.v7.2


write.csv(cust_sig,"cust_sig.csv")
mean(diff(tmp$sales_date))
tmp <- tr
tmp$sales_date <- as.numeric(gsub("-","",substr(tmp$sales_date,1,10)))
