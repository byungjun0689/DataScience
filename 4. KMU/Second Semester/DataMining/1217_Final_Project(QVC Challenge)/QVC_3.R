library(stringr)
library(arules)
library(dplyr)
library(maps)
library(ggplot2)
library(ggmap)

customer <- read.csv("Customer master2.csv")
order_df <- read.csv("order_data.csv", stringsAsFactors = F)

# timezone 별 고객 분포도 ####
timezone_customer <- customer %>% group_by(timezone) %>% summarize(cnt=n())
timezone_cluster_customer <- customer %>% group_by(timezone,cluster) %>% summarize(cnt = n())
timezone_segment_customer <- customer %>% group_by(timezone,SHOPPER_SEGMENT_CODE) %>% summarize(cnt=n())
timezone_segment_customer$SHOPPER_SEGMENT_CODE[is.na(timezone_segment_customer$SHOPPER_SEGMENT_CODE)] <- 0
write.csv(timezone_customer,"타임존별고객.csv",row.names=F)
write.csv(timezone_cluster_customer,"타임존_클러스터별고객.csv",row.names=F)
write.csv(timezone_segment_customer,"타임존_세그먼트별고객.csv",row.names=F)

#  Zip Code 별 고객 분포도. ####
v_customer <- customer %>% group_by(ZIP_CODE) %>% summarize(cnt = n())
v_customer <- merge(v_customer,zip[,c(1,3:5)],by.x="ZIP_CODE",by.y="zip")
#write.csv(v_customer,"ZIPCODE별 고객분포.csv",row.names=F)

# 지도 그리기 ####
head(v_customer)

map<-get_map(location='united states', zoom=4, maptype = "terrain",
             source='google',color='color')

ggmap(map) + geom_point(
  aes(x=longitude, y=latitude, show_guide = TRUE, colour=cnt, size=cnt),
  data=v_customer, alpha=1,na.rm = T)  +
  scale_color_gradient(low="beige", high="blue")

#  요일별 주문 Count ####
v_day <- order_df %>% group_by(ORDER_DAY) %>% summarize(cnt=n())
v_day$ORDER_DAY = factor(v_day$ORDER_DAY,labels=c("SUN","MON","TUE","WED","THU","FRI","SAT"),ordered=TRUE)
write.csv(v_day,"요일별 주문.csv",row.names=F)

# barplot 을 위한 Data ####
# state별 고객 분포 ####
state_number <- v_customer %>% group_by(state) %>% summarize(cnt = sum(cnt))
write.csv(state_number,"주(state)별 고객 분포.csv",row.names=F)

# 고객별 구매 횟수 ####
customer_order <- order_df %>% group_by(CUSTOMER_NBR) %>% summarize(cnt = n())

# Segement 별 구매 횟수 ####
segment_order <- order_df %>% group_by(SHOPPER_SEGMENT_CODE) %>% summarize(cnt = n())
#segment_order$SHOPPER_SEGMENT_CODE[is.na(segment_order$SHOPPER_SEGMENT_CODE)] <- 0
segment_order$prob <- round(prop.table(segment_order$cnt),2) * 100
write.csv(segment_order,"세그먼트별구매횟수.csv",row.names=F)


# TimeZone 별 구매 횟수 ####
timezone_order <- order_df %>% group_by(timezone) %>% summarize(cnt = n())
write.csv(timezone_order,"타임존별구매횟수.csv",row.names=F)

df_order_timezone <- data.frame(timezone = timezone_order$timezone, timezone_cnt = timezone_order$cnt)
df_customer_timezone <- data.frame(timezone = timezone_customer$timezone, customer_cnt = timezone_customer$cnt)
df_timezone <- merge(df_customer_timezone,df_order_timezone,by="timezone")

df_timezone <- df_timezone %>% mutate(per_order = timezone_cnt / customer_cnt)
write.csv(df_timezone,"타임존별고객분포및구매횟수.csv",row.names=F)


# 카테고리별 구매 ####
order_per_cate <- order_df %>% group_by(MERCH_DIV_DESC) %>% summarize(cnt = n()) %>% filter(cnt>=3) %>% arrange(desc(cnt))
order_per_cate
write.csv(order_per_cate,"카테고리별구매횟수.csv",row.names=F)

# 각 주별로 고객 Segement분포 
each_state_segement <- order_df %>% group_by(STATE,SHOPPER_SEGMENT_CODE) %>% summarize(cnt = n())
write.csv(each_state_segement,"주별세그먼트분포.csv",row.names=F)

# 가장 많이 팔린 제품
order_per_product <- order_df %>% group_by(PACKING_SLIP_DESC) %>% summarize(cnt = n()) %>% arrange(desc(cnt))

# 3. 방송 시간대별, 카테고리별 주문 Count ####
v_air_cate <- order_df %>% group_by(START_HOUR,MERCH_DIV_DESC) %>% summarize(cnt = n()) # 다른 데서 line plot으로 시간대별로 다르게 표현.
v_air <- v_air_cate %>% group_by(START_HOUR) %>% summarize(cnt = sum(cnt))
write.csv(v_air_cate,"방송시간_카테고리별주문.csv",row.names=F)
write.csv(v_air,"방송시간별주문.csv",row.names=F)
#ggplot(data=v_air, aes(y=cnt)) + geom_bar()



#######################################################
############ 3번은 정리 다시 하기 #####################
#######################################################

# 3. 지리별 Group_by MaxCnt, MaxAmt => Product별, Category별 ####
# 이건 그대로 사용. 흠.. 데코를 빼야되나 말아야되나....

v3_1 <- order_df %>% group_by(STATE,PACKING_SLIP_DESC) %>% summarize(Pro_cnt=n()) %>% slice(which.max(Pro_cnt))
v3_2_1 <- order_df %>% filter(MERCH_DIV_DESC != 'Home Decor') %>% group_by(STATE,MERCH_DIV_DESC) %>% summarize(Category_cnt=n()) %>% slice(which.max(Category_cnt))
v3_2_2 <- order_df %>% group_by(STATE,MERCH_DIV_DESC) %>% summarize(Category_cnt=n()) %>% slice(which.max(Category_cnt))

write.csv(v3_1,"지리별잘팔리는제품.csv",row.names=F)
write.csv(v3_2_2,"지리별잘팔리는카테고리.csv",row.names=F)

# 3. 시간대 별로 가장 많이 팔리는 것.제품 / 카테고리 위에 3번이랑 다른게 주문시간이냐 방송시간이냐 차이 밖에 없음. ####
# 아마 방송시간이 맞을듯 위에꺼가 맞을 것 같다.
# timezone 으로 변경.

v3_3 <- order_df %>% group_by(timezone,PACKING_SLIP_DESC) %>% summarize(Hour_P_cnt=n()) %>% slice(which.max(Hour_P_cnt))
#v3_4 <- order_df %>% filter(MERCH_DIV_DESC!="Home Decor") %>% group_by(ORDER_HOUR,MERCH_DIV_DESC) %>% summarize(Hour_C_cnt=n()) %>% slice(which.max(Hour_C_cnt))
v3_4 <- order_df %>% group_by(timezone,MERCH_DIV_DESC) %>% summarize(Hour_C_cnt=n()) %>% slice(which.max(Hour_C_cnt))

write.csv(v3_3,"타임존별잘팔리는제품.csv",row.names=F)
write.csv(v3_4,"타임존별잘팔리는카테고리.csv",row.names=F)

# 3. customer segement 별 잘팔리는 Product and category
# Product 아래 제품이 Segementation에 전역으로 많이 팔렸다. 제외
cs_prodcut <- order_df %>% group_by(SHOPPER_SEGMENT_CODE,PACKING_SLIP_DESC) %>% summarize(pro_cnt=n()) %>% slice(which.max(pro_cnt))
cs_category <- order_df %>% group_by(SHOPPER_SEGMENT_CODE,MERCH_DIV_DESC) %>% summarize(cate_cnt=n()) %>% slice(which.max(cate_cnt))

write.csv(cs_prodcut,"세그먼트별잘팔리는제품.csv",row.names=F)
write.csv(cs_category,"세그먼트별잘팔리는카테고리.csv",row.names=F)

# 3. 타임존, 세그먼트별 잘팔리는 제품. 

tzsg_product <- order_df %>% group_by(timezone,SHOPPER_SEGMENT_CODE,PACKING_SLIP_DESC) %>% summarize(tzsg_pro_cnt=n()) %>% slice(which.max(tzsg_pro_cnt))
tzsg_category <- order_df %>% group_by(timezone,SHOPPER_SEGMENT_CODE,MERCH_DIV_DESC) %>% summarize(tzsg_cate_cnt=n()) %>% slice(which.max(tzsg_cate_cnt))

tzsg_product$SHOPPER_SEGMENT_CODE[is.na(tzsg_product$SHOPPER_SEGMENT_CODE)] <- 0
tzsg_category$SHOPPER_SEGMENT_CODE[is.na(tzsg_category$SHOPPER_SEGMENT_CODE)] <- 0

write.csv(tzsg_product,"타임존세그먼트별잘팔리는제품.csv",row.names=F)
write.csv(tzsg_category,"타임존세그먼트별잘팔리는카테고리.csv",row.names=F)

#######################################################
############ 3번은 정리 다시 하기 #####################
#######################################################


# 4. 제품별로 잘팔리는 시간대가 있는가 
product_per_hour <- order_df %>% group_by(PACKING_SLIP_DESC,ORDER_HOUR) %>% summarize(pro_cnt=n()) %>% slice(which.max(pro_cnt)) %>% filter(pro_cnt>1)
category_per_hour <- order_df %>% group_by(MERCH_DIV_DESC,ORDER_HOUR) %>% summarize(cate_cnt=n()) %>% slice(which.max(cate_cnt)) 

write.csv(product_per_hour,"제품별잘팔리는시간.csv",row.names=F)
write.csv(category_per_hour,"카테고리별잘팔리는시간.csv",row.names=F)

# 5. 고객군 별로 Brand 
segment_brand <- order_df %>% group_by(SHOPPER_SEGMENT_CODE,BRAND_NAME) %>% summarize(cnt = n()) %>% arrange(SHOPPER_SEGMENT_CODE,desc(cnt))
segment_brand_max <- order_df %>% filter(BRAND_NAME!="Not Known" & BRAND_NAME!="N/A") %>% group_by(SHOPPER_SEGMENT_CODE,BRAND_NAME) %>% summarize(cnt = n()) %>% slice(which.max(cnt)) 
segment_brand_max$SHOPPER_SEGMENT_CODE[is.na(segment_brand_max$SHOPPER_SEGMENT_CODE)] <- 0

write.csv(segment_brand,"세그먼트별구매브랜드수.csv",row.names=F)
write.csv(segment_brand_max,"세그먼트별최대구매브랜드.csv",row.names=F)

df_customer_timezone
df_orderCustomer_timezone <- order_df %>% group_by(timezone,CUSTOMER_NBR) %>% summarize(order_timezone=n()) %>% group_by(timezone) %>% summarize(order_timezone=n())
df_diff_timezone <- merge(df_customer_timezone,df_orderCustomer_timezone,by="timezone")
df_diff_timezone <- df_diff_timezone %>% mutate(diff_ratio = round(order_timezone/customer_cnt,2))



# Prepareing for Clustering ####
# 1. 구매 횟수 
# 2. 한번에 구매한 최대 구매수 
# # 4. 내점 당 구매건수(Number of Purchases Per Visit) #
# tmp <- tr.input %>% 
#   group_by(custid) %>% 
#   summarize(n=n())
# cs.v4 <- inner_join(cs.v3, tmp) %>% 
#   mutate(NPPV = n/visits) %>% 
#   select(custid,NPPV)
# 3. 구매 다양성 (브랜드, 카테고리, 아이템 갯수)
# cs.v2 <- tr.input %>% 
#   distinct(custid,brd_nm) %>% 
#   group_by(custid) %>% 
#   summarize(buy_brd=n())
# 4. 내점 일수와 평균 구매 주기 
# start_date = ymd(ymd_hms(min(tr$sales_date)))
# end_date = ymd(ymd_hms(max(tr$sales_date)))
# cs.v3 <- tr.input %>% 
#   distinct(custid,sales_date) %>% 
#   group_by(custid) %>% 
#   summarize(visits=n()) %>% 
#   mutate(API = round(as.integer(end_date - start_date)/visits))
# Customer Segment 활용 
# 5. 최근 6,5,4,3,2,1 구매 횟수 
# end_date <- ymd(ymd_hms(max(tr$sales_date)))
# start_date <- ymd('20010501') - months(12)
# cs.v7.12 <-tr.input %>%
#   filter(start_date<=sales_date& sales_date<=end_date) %>%
#   group_by(custid) %>%
#   summarize(amt12=sum(net_amt), nop12=n())
# 6. 주 구매 시간대
# 7. 주 구매 방송시간 대 
# 8. 방송 or 방송 아닌 일반 구매 ( 웹사이트 )
