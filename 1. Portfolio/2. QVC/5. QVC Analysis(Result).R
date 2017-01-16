library(stringr)
library(arules)
library(dplyr)
library(maps)
library(ggplot2)
library(ggmap)
library(gridExtra)
library(reshape2)
library(arulesSequences)
library(lubridate)
#제출해야할 파일 
# Customer master2.csv
# order_data.csv
# product.csv
# timezone.csv
# zipcode.csv
# Product airtime.csv
# pre_order_data.csv

theme_set(theme_gray(base_size = 18))

customer <- read.csv("data/Customer master2.csv")
customer$SHOPPER_SEGMENT_CODE <- as.factor(customer$SHOPPER_SEGMENT_CODE)
order_df <- read.csv("data/order_data.csv", stringsAsFactors = F)
order_df$SHOPPER_SEGMENT_CODE[is.na(order_df$SHOPPER_SEGMENT_CODE)] <- 0
order_df$SHOPPER_SEGMENT_CODE <- as.factor(order_df$SHOPPER_SEGMENT_CODE)

product <- read.csv("data/Product master2.csv", stringsAsFactors = F)

#########################################
############## DATA 설명 ################
#########################################

# 1. 고객 분포도. Zip Code 별 고객 분포도. ####
v_customer <- customer %>% group_by(ZIP_CODE) %>% summarize(cnt = n()) %>% filter(cnt > 5)
v_customer <- merge(v_customer,zip[,c(1,3:5)],by.x="ZIP_CODE",by.y="zip")

# 지도 그리기 ####
head(v_customer)

map<-get_map(location='united states', zoom=4, maptype = "terrain",
             source='google',color='color')

ggmap(map) + geom_point(
  aes(x=longitude, y=latitude, show_guide = TRUE, colour=cnt, size=cnt),
  data=v_customer, alpha=1,na.rm = T)  +
  scale_color_gradient(low="beige", high="blue")

us <- map_data("state")
city <- customer %>% group_by(city) %>% summarize(cnt = n())
city <- city %>% mutate(avg = cnt/mean(cnt))
city$city <- tolower(city$city)

gg <- ggplot()
gg <- gg + geom_map(data=us, map=us,
                    aes(x=long, y=lat, map_id=region),
                    fill="#ffffff", color="#ffffff", size=0.25)

gg <- gg + geom_map(data=city, map=us,
                    aes(fill=cnt, map_id=city),
                    color="#ffffff", size=0.25)
gg <- gg + scale_fill_continuous(low='thistle2', high='darkred', 
                                 guide='colorbar')
gg <- gg + labs(x=NULL, y=NULL)
gg <- gg + coord_map("albers", lat0 = 39, lat1 = 45) 
gg <- gg + theme(panel.border = element_blank())
gg <- gg + theme(panel.background = element_blank())
gg <- gg + theme(axis.ticks = element_blank())
gg <- gg + theme(axis.text = element_blank())
gg

# timezone 별 고객 분포도 ####
timezone_customer <- customer %>% group_by(timezone) %>% summarize(cnt=n())
ggplot(timezone_customer,aes(x=timezone,y=cnt,fill=timezone)) + geom_bar(stat="identity")

# 2. State 별 고객 분포 ####
state_number <- v_customer %>% group_by(state) %>% summarize(cnt = sum(cnt)) %>% arrange(desc(cnt))
ggplot(v_customer, aes(x=state,y=cnt)) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# 3. State 별 Segment 별 고객 분포 안하는 게 나을 듯.
customer$SHOPPER_SEGMENT_CODE[is.na(customer$SHOPPER_SEGMENT_CODE)] <- 0
customer$SHOPPER_SEGMENT_CODE <- factor(customer$SHOPPER_SEGMENT_CODE)
state_seg_number <- customer %>% group_by(STATE,SHOPPER_SEGMENT_CODE) %>% summarize(cnt = n())
ggplot(customer,aes(x=STATE,fill=SHOPPER_SEGMENT_CODE)) + geom_bar() + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# 4. segment 별 고객 분포 ####
segment_customer <- customer %>% group_by(SHOPPER_SEGMENT_CODE) %>% summarize(cu_cnt = n()) %>% mutate(prob = round((cu_cnt/sum(cu_cnt)),2)*100)
segment_customer$SHOPPER_SEGMENT_CODE[is.na(segment_customer$SHOPPER_SEGMENT_CODE)] <- 0
#segment_customer$SHOPPER_SEGMENT_CODE <- factor(segment_customer$SHOPPER_SEGMENT_CODE,levels = c(0,1,2,3,4,5))
bp<- ggplot(segment_customer, aes(x="", y=cu_cnt, fill=as.factor(SHOPPER_SEGMENT_CODE)))+
  geom_bar(width = 1, stat = "identity") 
pie <- bp + coord_polar("y", start=0)
# scale_fill_brewer("Blues") + blank_theme +
pie + 
  #theme(axis.text.x=element_blank())+
  geom_text(aes(y = cu_cnt/3 + c(0, cumsum(cu_cnt)[-length(cu_cnt)]), 
                label = paste0(SHOPPER_SEGMENT_CODE,":",prob,"%")), size=6)

ggplot(segment_customer, aes(x="", y=cu_cnt, fill=SHOPPER_SEGMENT_CODE))+
  geom_bar(width = 1, stat = "identity")

# 5. segment 별 구매 횟수 ####

segment_order <- order_df %>% group_by(SHOPPER_SEGMENT_CODE) %>% summarize(or_cnt=n())
segment_order$percent <- round(prop.table(segment_order$or_cnt),2) 

ggplot(segment_order,aes(x=SHOPPER_SEGMENT_CODE,y=or_cnt,fill=SHOPPER_SEGMENT_CODE)) + geom_bar(stat="identity")

# 5.1 segment 별 회원수 
segment_cus_order <- order_df %>% distinct(CUSTOMER_NBR,SHOPPER_SEGMENT_CODE) %>% group_by(SHOPPER_SEGMENT_CODE) %>% summarize(or_cnt=n())
 # 합쳐서
seg <- merge(segment_customer,segment_order,by="SHOPPER_SEGMENT_CODE")
seg <- seg %>% mutate(avg = round(or_cnt/cu_cnt,2))
ggplot(seg,aes(x=SHOPPER_SEGMENT_CODE,y=avg,fill=SHOPPER_SEGMENT_CODE)) + geom_bar(stat="identity",colour="black")

#  월별 판매 수
mon_order <- order_df %>% group_by(ORDER_MON) %>% summarize(cnt =n())
mon_order$ORDER_MON <- as.factor(mon_order$ORDER_MON)
mon_order$per <- round(prop.table(mon_order$cnt),2) * 100
ggplot(data=mon_order,aes(x=ORDER_MON,y=cnt,fill=ORDER_MON)) +geom_bar(stat="identity")


# 6. 요일별 주문 Count ####
v_day <- order_df %>% group_by(ORDER_DAY) %>% summarize(cnt=n())
v_day$ORDER_DAY = factor(v_day$ORDER_DAY,labels=c("SUN","MON","TUE","WED","THU","FRI","SAT"),ordered=TRUE)
ggplot(v_day, aes(x=ORDER_DAY,y=cnt,fill=ORDER_DAY)) + geom_bar(stat="identity",colour="black")

# 7. 카테고리별 구매 횟수 5개 ####
order_per_cate <- order_df %>% group_by(MERCH_DIV_DESC) %>% summarize(cnt = n()) %>% arrange(desc(cnt))
ggplot(head(order_per_cate), aes(x=MERCH_DIV_DESC,y=cnt,fill=MERCH_DIV_DESC)) + geom_bar(stat="identity",colour="black")

# 8. 가장 많이 팔린 제품 상위 5개 ####
order_per_product <- order_df %>% group_by(PACKING_SLIP_DESC) %>% summarize(cnt = n()) %>% arrange(desc(cnt))
ggplot(head(order_per_product), aes(x=PACKING_SLIP_DESC,y=cnt,fill=PACKING_SLIP_DESC)) + geom_bar(stat="identity") + coord_flip()

top5 <- head(order_per_product$PACKING_SLIP_DESC)
top5_df <- order_df %>% filter(PACKING_SLIP_DESC %in% top5) %>% group_by(PACKING_SLIP_DESC,ORDER_HOUR) %>% summarize(cnt= n())

write.csv(top5_df,"TOP5_변화.csv",row.names=F)

ggplot(top5_df,aes(x=ORDER_HOUR,y=cnt,color=PACKING_SLIP_DESC,group=PACKING_SLIP_DESC)) + geom_line(size=2)


# 9. 시간대별 판매 수 ####
v_time_cate <- order_df %>% group_by(ORDER_HOUR,MERCH_DIV_DESC) %>% summarize(cnt = n()) # 다른 데서 line plot으로 시간대별로 다르게 표현.
time_order <- v_time_cate %>% group_by(ORDER_HOUR) %>% summarize(cnt = sum(cnt))
s
ggplot(data=time_order, aes(x=factor(ORDER_HOUR), y=cnt,group=1)) + geom_line(color="red") + geom_point(color="blue")

head(air_product)

# 10. Timezone 별 주문 횟수 ####
timezone_order <- order_df %>% group_by(timezone) %>% summarize(cnt = n()) %>% mutate(prob = round((cnt/sum(cnt)),3)*100)

timezone_customer <- customer %>% group_by(timezone) %>% summarize(cnt=n())
timezone_cluster_customer <- customer %>% group_by(timezone,cluster) %>% summarize(cnt = n())
timezone_segment_customer <- customer %>% group_by(timezone,SHOPPER_SEGMENT_CODE) %>% summarize(cnt=n())

df_order_timezone <- data.frame(timezone = timezone_order$timezone, timezone_cnt = timezone_order$cnt)
df_customer_timezone <- data.frame(timezone = timezone_customer$timezone, customer_cnt = timezone_customer$cnt)
df_timezone <- merge(df_customer_timezone,df_order_timezone,by="timezone")
df_timezone <- df_timezone %>% mutate(per_order = round(timezone_cnt / customer_cnt,2))

timezone_order <- left_join(timezone_order,df_timezone[,c(1,4)])

p1 <- ggplot(timezone_order,aes(x=timezone,y=prob,fill=timezone)) + geom_bar(stat="identity")
p2 <- ggplot(timezone_order,aes(x=timezone,y=per_order,fill=timezone)) + geom_bar(stat="identity")
gridExtra::grid.arrange(p1, p2)

# ETC. Segment , 월별 Brand ####

se_mon_brand <- order_df %>% group_by(SHOPPER_SEGMENT_CODE,ORDER_MON,BRAND_NAME) %>% summarize(cnt = n()) %>% arrange(SHOPPER_SEGMENT_CODE,ORDER_MON,desc(cnt))  
se_mon_brand$SHOPPER_SEGMENT_CODE[is.na(se_mon_brand$SHOPPER_SEGMENT_CODE)] <- 0
for(i in 0:5){
  tmp_df <- se_mon_brand %>% filter(SHOPPER_SEGMENT_CODE==i) %>% arrange(desc(cnt))
  tmp <- tmp_df %>%
    arrange_(~ desc(cnt)) %>%
    group_by_(~ ORDER_MON) %>%
    slice(1:5)
  assign(paste0("seg_mon_brand_",i),tmp)
}

seg_mon_brand <- seg_mon_brand_0
seg_mon_brand <- rbind(seg_mon_brand,seg_mon_brand_1)
seg_mon_brand <- rbind(seg_mon_brand,seg_mon_brand_2)
seg_mon_brand <- rbind(seg_mon_brand,seg_mon_brand_3)
seg_mon_brand <- rbind(seg_mon_brand,seg_mon_brand_4)
seg_mon_brand <- rbind(seg_mon_brand,seg_mon_brand_5)

write.csv(seg_mon_brand,"세그먼트월별구매TOP10.csv",row.names=F)

# 세그먼트별 요일 구매 패턴 
# 5. segment 별 구매 횟수 ####
segment_mon_order <- order_df %>% group_by(SHOPPER_SEGMENT_CODE,ORDER_DAY) %>% summarize(or_cnt=n())
segment_mon_order$ORDER_DAY = factor(segment_mon_order$ORDER_DAY,labels=c("SUN","MON","TUE","WED","THU","FRI","SAT"),ordered=TRUE)
ggplot(segment_mon_order,aes(x=SHOPPER_SEGMENT_CODE,y=or_cnt,fill=ORDER_DAY)) + geom_bar(stat="identity",position="dodge")

################################################
################################################
################# 문제 질문  ###################
################################################
################################################
#### 1번 ####

order_df <- read.csv("data/order_data_cluster.csv", stringsAsFactors = F)
customer <- read.csv("data/customer_with_cluster.csv",stringsAsFactors = F)

for(i in 1:9){
  tmp_df <- order_df %>% filter(cluster==i)
  assign(paste0("cluster_",i),tmp_df)
}

for(i in 1:9){
  tmp_df <- get(paste0("cluster_",i))
  tmp_df <- tmp_df %>% group_by(CUSTOMER_NBR,MERCH_DIV_DESC) %>% summarize(cnt = n()) %>% arrange(CUSTOMER_NBR)
  assign(paste0("cluster_cate_",i),as.data.frame(tmp_df))
}

for(i in 1:9){
  tmp_df <- get(paste0("cluster_",i))
  tmp_df <- tmp_df %>% group_by(CUSTOMER_NBR,PRODUCT_ID) %>% summarize(cnt = n()) %>% arrange(CUSTOMER_NBR)
  assign(paste0("cluster_product_",i),as.data.frame(tmp_df))
}

# id별로 추천 가져오는 Function ####
# 1. Category
getCategoryRecommand <- function(x){
  custId <- x
  custCluster <- customer[customer$CUSTOMER_NBR==custId,]$cluster
  in_df <- get(paste0("cluster_cate_",custCluster))
  in_cate_list <- in_df[in_df$CUSTOMER_NBR==custId,]$MERCH_DIV_DESC
  in_cate_list <- as.data.frame(in_cate_list)
  other_df <- in_df %>% filter(CUSTOMER_NBR!=custId) %>% group_by(MERCH_DIV_DESC) %>% summarize(cnt = sum(cnt)) %>% arrange(desc(cnt))
  other_df <- as.data.frame(other_df)
  other_df$percent <- round(prop.table(other_df$cnt),2)  
  result_df <- other_df %>% filter(!(MERCH_DIV_DESC %in% in_cate_list$in_cate_list))
  print(in_cate_list)
  print(head(result_df))
}
# 2. Product 별 
getProductRecommand <- function(x){
  custId <- x
  custCluster <- customer[customer$CUSTOMER_NBR==custId,]$cluster
  in_df <- get(paste0("cluster_product_",custCluster))
  in_product_list <- in_df[in_df$CUSTOMER_NBR==custId,]$PRODUCT_ID
  in_product_list <- as.data.frame(in_product_list)
  other_df <- in_df %>% filter(CUSTOMER_NBR!=custId) %>% group_by(PRODUCT_ID) %>% summarize(cnt = sum(cnt)) %>% arrange(desc(cnt))
  other_df <- as.data.frame(other_df)
  other_df$percent <- round(prop.table(other_df$cnt),2)  
  result_df <- other_df %>% filter(!(PRODUCT_ID %in% in_product_list$in_producut_list))
  result_df <- left_join(result_df,product)
  names(in_product_list)[1] <- "PRODUCT_ID"
  in_product_list <- left_join(in_product_list,product)
  print(in_product_list[,c(1,2)])
  print(head(result_df[,c(1,4,2,3)]))
}

getCateRecommand2 <- function(x){
  custId <- x
  custCluster <- customer[customer$CUSTOMER_NBR==custId,]$cluster
  if(length(custCluster)==0){
    return(0)
  }
  baskets <-  read_baskets(con  = paste0("data/item_cate_",custCluster,".txt"),sep = "#", info = c("sequenceID","eventID","SIZE"))
  baskets <- cspade(baskets, parameter = list(support = 0.0001), control = list(verbose = TRUE))
  baskets_df <- as(baskets, "data.frame")
  baskets_df <- baskets_df[order(baskets_df$support,decreasing = T),]
  baskets_df$sequence <- gsub(pattern = "<\\{\"","",baskets_df$sequence)
  baskets_df$sequence <- gsub(pattern = "\"\\}>","",baskets_df$sequence)
  baskets_df$sequence <- gsub(pattern = "\"","",baskets_df$sequence)
  last_df <- order_df[order_df$CUSTOMER_NBR==custId,] %>% 
    arrange(desc(ORDER_DATES)) %>% 
    select(MERCH_DIV_DESC)
  last_cate <- last_df$MERCH_DIV_DESC
  support_df <- baskets_df %>% filter(str_detect(sequence,last_cate))
  print(paste0(last_cate))
  print(head(support_df[-1,]))
}

getRecommand2 <- function(x,y){
  if(x=="cate"){
    getCateRecommand2(y)
  }else{
    getProductRecommand(y)
  }
}

# getRecommand <- function(x,y){
#   if(x=="cate"){
#     getCategoryRecommand(y)
#   }else{
#     getProductRecommand(y)
#   }
# }

# 3. 지리별 Group_by MaxCnt, MaxAmt => Product별, Category별 ####

v3_1 <- order_df %>% 
  group_by(STATE,PACKING_SLIP_DESC) %>% 
  summarize(Pro_cnt=n()) %>% 
  slice(which.max(Pro_cnt))


v3_2_1 <- order_df %>% filter(MERCH_DIV_DESC != 'Home Decor') %>% group_by(STATE,MERCH_DIV_DESC) %>% summarize(Category_cnt=n()) %>% slice(which.max(Category_cnt))
v3_2_2 <- order_df %>% group_by(STATE,MERCH_DIV_DESC) %>% summarize(Category_cnt=n()) %>% slice(which.max(Category_cnt))


# 3. 타임존별 가장 많이 팔리는 것.제품 / 카테고리 ####

v3_3 <- order_df %>% group_by(timezone,PACKING_SLIP_DESC) %>% summarize(Hour_P_cnt=n()) %>% slice(which.max(Hour_P_cnt))
v3_4 <- order_df %>% group_by(timezone,MERCH_DIV_DESC) %>% summarize(Hour_C_cnt=n()) %>% slice(which.max(Hour_C_cnt))


# 3. customer segement 별 잘팔리는 Product and category
cs_prodcut <- order_df %>% 
  group_by(SHOPPER_SEGMENT_CODE,PACKING_SLIP_DESC) %>% 
  summarize(pro_cnt=n()) %>% 
  slice(which.max(pro_cnt))


cs_category <- order_df %>% 
  group_by(SHOPPER_SEGMENT_CODE,MERCH_DIV_DESC) %>% 
  summarize(cate_cnt=n()) %>% 
  slice(which.max(cate_cnt))

# 3. 타임존, 세그먼트별 잘팔리는 제품. 
tzsg_product <- order_df %>% group_by(timezone,SHOPPER_SEGMENT_CODE,PACKING_SLIP_DESC) %>% summarize(tzsg_pro_cnt=n()) %>% slice(which.max(tzsg_pro_cnt))
tzsg_category <- order_df %>% group_by(timezone,SHOPPER_SEGMENT_CODE,MERCH_DIV_DESC) %>% summarize(tzsg_cate_cnt=n()) %>% slice(which.max(tzsg_cate_cnt))
tzsg_product$SHOPPER_SEGMENT_CODE[is.na(tzsg_product$SHOPPER_SEGMENT_CODE)] <- 0
tzsg_category$SHOPPER_SEGMENT_CODE[is.na(tzsg_category$SHOPPER_SEGMENT_CODE)] <- 0

# 4. 제품별로 잘팔리는 시간대가 있는가 
product_per_hour <- order_df %>% 
  group_by(PACKING_SLIP_DESC,ORDER_HOUR) %>% 
  summarize(pro_cnt=n()) %>% 
  slice(which.max(pro_cnt)) %>% 
  filter(pro_cnt>10) %>% arrange(ORDER_HOUR)

category_per_hour <- order_df %>% group_by(MERCH_DIV_DESC,ORDER_HOUR) %>% summarize(cate_cnt=n()) %>% slice(which.max(cate_cnt)) 

# 5. 고객군 별로 Brand 
segment_brand <- order_df %>% group_by(SHOPPER_SEGMENT_CODE,BRAND_NAME) %>% summarize(cnt = n()) %>% arrange(SHOPPER_SEGMENT_CODE,desc(cnt))
segment_brand_max <- order_df %>% filter(BRAND_NAME!="Not Known" & BRAND_NAME!="N/A") %>% group_by(SHOPPER_SEGMENT_CODE,BRAND_NAME) %>% summarize(cnt = n()) %>% slice(which.max(cnt)) 
segment_brand_max$SHOPPER_SEGMENT_CODE[is.na(segment_brand_max$SHOPPER_SEGMENT_CODE)] <- 0

# 브랜드별 상관관계 ####
# 상위 10개 브랜드
count_brand <- order_df %>% group_by(BRAND_NAME) %>% summarize(cnt = n()) %>% arrange(desc(cnt)) %>% head(20)

brand_list <- count_brand$BRAND_NAME
brand_list <- as.data.frame(brand_list)
brand_rel <- order_df %>% filter(BRAND_NAME %in% brand_list$brand_list & BRAND_NAME != "Not Known" & BRAND_NAME != "N/A") %>% group_by(CUSTOMER_NBR,BRAND_NAME) %>% summarize(cnt = n())
brand_rel <- dcast(CUSTOMER_NBR ~ BRAND_NAME, data = brand_rel, value.var = "cnt")
brand_rel[is.na(brand_rel)] <- 0
brand_cor <- round(cor(brand_rel),2)
brand_cor <- as.data.frame(brand_cor)
brand_cor[brand_cor>0.1]
View(brand_cor)

# 시간별 광고 횟수(전체) ####
air_product$PRODUCT_START_TMS  <- ymd_hms(air_product$PRODUCT_START_TMS)
air_product$PRODUCT_STOP_TMS  <- ymd_hms(air_product$PRODUCT_STOP_TMS)
air_product$AIR_DATE <- ymd(air_product$AIR_DATE)
air_product$START_HOUR <- hour(air_product$PRODUCT_START_TMS)
air_product$STOP_HOUR <- hour(air_product$PRODUCT_STOP_TMS)
air_product$AIR_MON <- month(air_product$AIR_DATE)

total_air_hour <- air_product %>% group_by(START_HOUR) %>% summarize(cnt = n())
ggplot(total_air_hour,aes(x=factor(START_HOUR),y=cnt,group=2))  + geom_line(size = 2,color="red") + geom_point(color="blue",size=2)

total_air_hour$type = "전체광고"
#total_air_hour$cnt <- scale(total_air_hour$cnt)

mean_air_hour <- air_product %>% group_by(START_HOUR) %>% summarize(cnt = mean(PRODUCT_AIRTIME_MINS))
mean_air_hour$type <- "전체광고평균시간"
#mean_air_hour$cnt <- scale(mean_air_hour$cnt)

# 구매 제품의 방송 시간에 따른 구매 ####
tmp_df <- order_df[!is.na(order_df$AIR_DATE),]
air_time_order <- tmp_df %>% group_by(START_HOUR) %>% summarize(cnt = n())
#air_time_order$cnt <- scale(air_time_order$cnt)
air_time_order$type="판매연결"

mean_air_time_order <- tmp_df %>% group_by(START_HOUR) %>% summarize(cnt = mean(PRODUCT_AIRTIME_MINS))
mean_air_time_order$type="판매연결평균시간"
#mean_air_time_order$cnt <- scale(mean_air_time_order$cnt)

air_df <- rbind(total_air_hour,air_time_order)
air_df$START_HOUR <- factor(air_df$START_HOUR)

mean_df <- rbind(mean_air_hour,mean_air_time_order)
mean_df$START_HOUR <- factor(mean_df$START_HOUR)

ggplot(air_df,aes(x=START_HOUR,y=cnt)) + geom_line(aes(group=type,color=type),size = 2) + geom_point(aes(group=type,color=type),size = 2)
ggplot(mean_df,aes(x=START_HOUR,y=cnt)) + geom_line(aes(group=type,color=type),size = 2) + geom_point(aes(group=type,color=type),size = 2)



# 광고를 본사람 vs 안본사람 시간대 비교 ####
air_order_df <- order_df[!is.na(order_df$AIR_DATE),]
no_air_order_df <- order_df[is.na(order_df$AIR_DATE),]

air_time_order <- air_order_df %>% group_by(ORDER_HOUR) %>% summarize(cnt=n())
no_air_time_order <- no_air_order_df %>% group_by(ORDER_HOUR) %>% summarize(cnt=n())

air_time_order$type="air"
no_air_time_order$type="noair"

compare_air <- rbind(air_time_order,no_air_time_order)
ggplot(compare_air,aes(x=ORDER_HOUR,y=cnt)) + geom_line(aes(group=type,color=type),size = 2) + geom_point(aes(group=type,color=type),size = 2)

names(air_df)[1] <- "HOUR"
names(compare_air)[1] <- "HOUR"

# 전체 주문 확보 ####
total_order <- order_df %>% group_by(ORDER_HOUR) %>% summarize(cnt=n())
names(total_order)[1] <- "HOUR"
total_order$type <- "전체주문"

tmp_df <- rbind(air_df,compare_air)
tmp_df <- rbind(tmp_df,total_order)
ggplot(tmp_df,aes(x=HOUR,y=cnt)) + geom_line(aes(group=type,color=type),size = 2) + geom_point(aes(group=type,color=type),size = 2)



