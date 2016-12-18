library(stringr)
library(arules)
library(dplyr)
library(maps)
library(ggplot2)
library(ggmap)
# 데이터 전처리 ####

customer <- read.csv("Customer master.csv",stringsAsFactors = T)
customer$ZIP_CODE <- as.factor(customer$ZIP_CODE)
zip <- read.csv("zipcode.csv")
customer <- merge(customer,zip[,c(1,2,4,5)],by.x='ZIP_CODE', by.y='zip')

timezone <- read.csv("timezone.csv", stringsAsFactors = F)
timezone2 <- timezone %>% distinct(state,timezone)
timezone2  <- timezone2[-c(19,25,29,42,46,48,37,53,58),]

head(customer)
head(timezone2)
names(timezone2)[1] <- "STATE"
customer <- merge(customer,timezone2,by="STATE")

write.csv(customer,"Customer master2.csv", row.names = F)


#orderlist <- read.csv("Historyoforders.csv")
#orderlist$ORDER_DATES <- as.POSIXlt(orderlist$ORDER_DATES,format="%Y-%m-%d %H:%M:%S")
product <- read.csv("Product master2.csv",stringsAsFactors = T)

air_product <- read.csv("Product airtime.csv", stringsAsFactors = F)
air_product$SEQ <- 1:nrow(air_product)

# air_product$AIR_DATE <- as.POSIXlt(air_product$AIR_DATE,format="%Y-%m-%d")
# air_product$PRODUCT_START_TMS <- as.POSIXlt(air_product$PRODUCT_START_TMS,format="%Y-%m-%d %H:%M")
# air_product$PRODUCT_STOP_TMS <- as.POSIXlt(air_product$PRODUCT_STOP_TMS,format="%Y-%m-%d %H:%M")


#volumeOfDate <- as.data.frame(table(orderlist$ORDER_DATE))
#volumeOfDate[order(volumeOfDate$Freq,decreasing = T),]

# for(i in 1:nrow(tmp)){
#   productId <- tmp[i,2]
#   orderDate <- tmp[i,]$ORDER_DATES
#   tmp_air <- air_product[air_product$PRODUCT_ID==productId,]
#   if(nrow(tmp_air)>0){
#     #for(j in 1:nrow(tmp_air)){
#     print(paste0("Product ID :",productId))
#     print(paste0("orderDate : ",orderDate))
#     tt <- tmp_air[which(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS))==min(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS)))),]
#     print(paste0("Start Time :",tt$PRODUCT_START_TMS))
#     print(paste0("End Time : ",tt$PRlODUCT_STOP_TMS))
#     print(paste0("Sequence : ",tt$SeqAir))
#     #if(orderDate >= tmp_air[j,]$PRODUCT_START_TMS & orderDate <= tmp_air[j,]$PRODUCT_STOP_TMS){
#     #print(tmp_air[j,])
#     #tmp[i,]$AIRStart <- tmp_air[j,]$PRODUCT_START_TMS
#     #tmp[i,]$AIREnd <- tmp_air[j,]$PRODUCT_STOP_TMS
#     #}
#     #}
#   }
# }

# 실제 적용.
# 
# for(i in 1:nrow(order_df)){
#   productId <- order_df[i,2]
#   orderDate <- order_df[i,]$ORDER_DATES
#   tmp_air <- air_product[air_product$PRODUCT_ID==productId,]
#   if(nrow(tmp_air)>0){
#     nearest <- tmp_air[which(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS))==min(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS)))),]
#     
#     order_df[i,]$AIR_START <- nearest$PRODUCT_START_TMS[1]
#     order_df[i,]$AIR_END <- nearest$PRlODUCT_STOP_TMS[1]
#   }
# }

getNear <- function(x){
  pdID <- x[1]
  odDate <- x[2]
  tmp_air <- air_product[air_product$PRODUCT_ID==pdID,]
  result <- 0
  if(nrow(tmp_air)>0){
    nearest <- tmp_air[which(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS))==min(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS)))),]
    result <- unlist(nearest$SEQ[1])
  }
  return(result)
}

#tmp$SEQ <- apply(tmp[,c(2,7)],1,getNear)
#order_df <- order_df[,-18]
#order_df$SEQ <- apply(order_df[,c(2,7)],1,getNear)

#tmp <- order_df
#tmp$SEQ <- lapply(tmp$SEQ, `[[`, 1)
#tmp$SEQ <- unlist(tmp$SEQ)
#order_df$SEQ <- lapply(order_df$SEQ, `[[`, 1)

#write.csv(order_df,"order_data.csv",row.names = F)


# air_product <- merge(air_product,product,by="PRODUCT_ID")
# air_product$AIR_DATE <- as.character(air_product$AIR_DATE)
# air_product$PRODUCT_START_TMS <- as.character(air_product$PRODUCT_START_TMS)
# air_product$PRODUCT_STOP_TMS <- as.character(air_product$PRODUCT_STOP_TMS)
# air_product <- air_product %>% arrange(PRODUCT_ID,PRODUCT_START_TMS,PRODUCT_STOP_TMS) 

#order_df <- read.csv("order_data2.csv",stringsAsFactors = F)

#order_df <- merge(order_df,air_product,by="SEQ")
#order_df$AIR_DATE <- as.POSIXlt(order_df$AIR_DATE,format="%Y-%m-%d")
#order_df$PRODUCT_START_TMS <- as.POSIXlt(order_df$PRODUCT_START_TMS,format="%Y-%m-%d %H:%M")
# order_df$PRODUCT_STOP_TMS <- as.POSIXlt(order_df$PRODUCT_STOP_TMS,format="%Y-%m-%d %H:%M")
# order_df$ORDER_DATES <- as.POSIXlt(order_df$ORDER_DATES,format="%Y-%m-%d %H:%M:%S")
# order_df$ORDER_DAY <- order_df$ORDER_DATES$wday
# order_df$AIR_HOUR <- order_df$PRODUCT_START_TMS$hour
# 
# order_df$AIR_DATE <- as.character(tmp_df$AIR_DATE)
# order_df$PRODUCT_START_TMS <- as.character(tmp_df$PRODUCT_START_TMS)
# order_df$PRODUCT_STOP_TMS <- as.character(tmp_df$PRODUCT_STOP_TMS)
# order_df$ORDER_DATES <- as.character(tmp_df$ORDER_DATES)

#write.csv(order_df,"order_data2.csv",row.names = F)
order_df <- read.csv("order_data2.csv")
order_df <- merge(order_df,timezone2,by="STATE")

write.csv(order_df,"order_data3.csv",row.names = F)


#  Zip Code 별 고객 분포도. ####
v_customer <- customer %>% group_by(ZIP_CODE) %>% summarize(cnt = n())
v_customer <- merge(v_customer,zip[,c(1,3:5)],by.x="ZIP_CODE",by.y="zip")

#  요일별 주문 Count ####
v_day <- order_df %>% group_by(ORDER_DAY) %>% summarize(cnt=n())
v_day$ORDER_DAY = factor(v_day$ORDER_DAY,labels=c("SUN","MON","TUE","WED","THU","FRI","SAT"),ordered=TRUE)


# 지도 그리기 ####
# head(v_customer)
# 
# map<-get_map(location='united states', zoom=4, maptype = "terrain",
#              source='google',color='color')
# 
# ggmap(map) + geom_point(
#   aes(x=longitude, y=latitude, show_guide = TRUE, colour=cnt), 
#   data=v_customer, alpha=.2,na.rm = T)  + 
#   scale_color_gradient(low="beige", high="blue")

# barplot 을 위한 Data ####

state_number <- v_customer %>% group_by(state) %>% summarize(cnt = sum(cnt))
write.csv(state_number,"state_number.csv",row.names = F)

# 고객별 구매 횟수 ####
customer_order <- order_df %>% group_by(CUSTOMER_NBR) %>% summarize(cnt = n())

# Segement 별 구매 횟수 ####
segement_order <- order_df %>% group_by(SHOPPER_SEGMENT_CODE) %>% summarize(cnt = n())

# TimeZone 별 구매 횟수 ####
timezone_order <- order_df %>% group_by(timezone) %>% summarize(cnt = n())
 
# 카테고리별 구매 ####
order_per_cate <- order_df %>% group_by(MERCH_DIV_DESC) %>% summarize(cnt = n()) %>% filter(cnt>=3) %>% arrange(desc(cnt))

# 각 주별로 고객 Segement분포 

each_state_segement <- order_df %>% group_by(STATE,SHOPPER_SEGMENT_CODE) %>% summarize(cnt = n())

# 3. 방송 시간대별, 카테고리별 주문 Count ####
v_air_cate <- order_df %>% group_by(AIR_HOUR,MERCH_DIV_DESC) %>% summarize(cnt = n()) # 다른 데서 line plot으로 시간대별로 다르게 표현.
v_air <- v_air_cate %>% group_by(AIR_HOUR) %>% summarize(cnt = sum(cnt))

#ggplot(data=v_air, aes(y=cnt)) + geom_bar()

# 3. 지리별 Group_by MaxCnt, MaxAmt => Product별, Category별 ####

v3_1 <- order_df %>% group_by(STATE,PACKING_SLIP_DESC) %>% summarize(Pro_cnt=n()) %>% slice(which.max(Pro_cnt))
v3_2 <- order_df %>% filter(MERCH_DIV_DESC != 'Home Decor') %>% group_by(STATE,MERCH_DIV_DESC) %>% summarize(Category_cnt=n()) %>% slice(which.max(Category_cnt))

# 3. 시간대 별로 가장 많이 팔리는 것.제품 / 카테고리 위에 3번이랑 다른게 주문시간이냐 방송시간이냐 차이 밖에 없음. ####
# 아마 방송시간이 맞을듯 위에꺼가 맞을 것 같다.

v3_3 <- order_df %>% group_by(ORDER_HOUR,PACKING_SLIP_DESC) %>% summarize(Hour_P_cnt=n()) %>% slice(which.max(Hour_P_cnt))
v3_4 <- order_df %>% filter(MERCH_DIV_DESC!="Home Decor") %>% group_by(ORDER_HOUR,MERCH_DIV_DESC) %>% summarize(Hour_C_cnt=n()) %>% slice(which.max(Hour_C_cnt))

# 3. customer segement 별 잘팔리는 Product and category
# Product 아래 제품이 Segementation에 전역으로 많이 팔렸다. 제외
cs_prodcut <- order_df %>% filter(PACKING_SLIP_DESC != "FlashPad 2.0 Touchscreen Handheld Game with") %>% group_by(SHOPPER_SEGMENT_CODE,PACKING_SLIP_DESC) %>% summarize(pro_cnt=n()) %>% slice(which.max(pro_cnt))
cs_category <- order_df %>% filter(MERCH_DIV_DESC != "Home Decor") %>% group_by(SHOPPER_SEGMENT_CODE,MERCH_DIV_DESC) %>% summarize(cate_cnt=n()) %>% slice(which.max(cate_cnt))

# 4. 제품별로 잘팔리는 시간대가 있는가 
product_per_hour <- order_df %>% group_by(PACKING_SLIP_DESC,ORDER_HOUR) %>% summarize(pro_cnt=n()) %>% slice(which.max(pro_cnt)) %>% filter(pro_cnt>1)
category_per_hour <- order_df %>% group_by(MERCH_DIV_DESC,ORDER_HOUR) %>% summarize(cate_cnt=n()) %>% slice(which.max(cate_cnt)) 

# 5. 고객군 별로 Brand 
segement_brand <- order_df %>% group_by(SHOPPER_SEGMENT_CODE,BRAND_NAME) %>% summarize(cnt = n()) %>% arrange(SHOPPER_SEGMENT_CODE,desc(cnt))
segement_brand_max <- order_df %>% filter(BRAND_NAME!="Not Known" & BRAND_NAME!="N/A") %>% group_by(SHOPPER_SEGMENT_CODE,BRAND_NAME) %>% summarize(cnt = n()) %>% slice(which.max(cnt)) 
