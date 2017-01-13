library(stringr)
library(arules)
library(dplyr)
library(maps)
library(ggplot2)
library(ggmap)
# 데이터 전처리 ####

#orderlist <- read.csv("6 month history of customer orders.csv")
customer <- read.csv("Customer master.csv",stringsAsFactors = T)
customer$ZIP_CODE <- as.factor(customer$ZIP_CODE)

zip <- read.csv("zipcode.csv")
customer <- merge(customer,zip[,c(1,2,4,5)],by.x='ZIP_CODE', by.y='zip')

v_customer <- customer %>% group_by(ZIP_CODE) %>% summarize(cnt = n())
v_customer <- merge(v_customer,zip[,c(1,3:5)],by.x="ZIP_CODE",by.y="zip")
head(v_customer)

orderlist <- read.csv("Historyoforders.csv")
#orderlist <- orderlist[,-1]
orderlist$ORDER_DATES <- as.POSIXlt(orderlist$ORDER_DATES,format="%Y-%m-%d %H:%M:%S")

product <- read.csv("Product master2.csv",stringsAsFactors = T)
#product <- product[,-1]

air_product <- read.csv("Product airtime.csv", stringsAsFactors = F)
air_product$AIR_DATE <- as.POSIXlt(air_product$AIR_DATE,format="%Y-%m-%d")
air_product$PRODUCT_START_TMS <- as.POSIXlt(air_product$PRODUCT_START_TMS,format="%Y-%m-%d %H:%M")
air_product$PRODUCT_STOP_TMS <- as.POSIXlt(air_product$PRODUCT_STOP_TMS,format="%Y-%m-%d %H:%M")

# orderlist$ORDER_DATE <- as.POSIXlt(orderlist$ORDER_DATE,format="%Y-%m-%d")
# str(orderlist)orderDate
# orderlist$ORDER_DATES <- paste(orderlist$ORDER_DATE,orderlist$ORDER_TIME)
# orderlist$ORDER_DATES <- as.POSIXlt(orderlist$ORDER_DATES,format="%Y-%m-%d %H:%M:%S")
# 
# orderlist$ORDER_YEAR <- orderlist$ORDER_DATES$year + 1900
# orderlist$ORDER_MON <- orderlist$ORDER_DATES$mon + 1
# orderlist$ORDER_DAY <- orderlist$ORDER_DATES$mday
# orderlist$ORDER_HOUR <- orderlist$ORDER_DATES$hour
# 
# write.csv(orderlist,"Historyoforders.csv")

volumeOfDate <- as.data.frame(table(orderlist$ORDER_DATE))
volumeOfDate[order(volumeOfDate$Freq,decreasing = T),]

order_df <- merge(orderlist,product,by = "PRODUCT_ID")
order_df <- merge(order_df,customer,by="CUSTOMER_NBR")

# 해당 get order airtime
tmp <- order_df[6:10,]

for(i in 1:nrow(tmp)){
  productId <- tmp[i,2]
  orderDate <- tmp[i,]$ORDER_DATES
  tmp_air <- air_product[(air_product$PRODUCT_ID==productId)&(air_product$PRODUCT_START_TMS < orderDate) ,]
  if(nrow(tmp_air)>0){
    #for(j in 1:nrow(tmp_air)){
      print(paste0("Product ID :",productId))
      print(paste0("orderDate : ",orderDate))
      tt <- tmp_air[which(abs(as.numeric(orderDate-tmp_air$PRODUCT_START_TMS))==min(abs(as.numeric(orderDate-tmp_air$PRODUCT_START_TMS)))),]
      print(paste0("Start Time :",tt$PRODUCT_START_TMS))
      print(paste0("End Time : ",tt$PRODUCT_STOP_TMS))
      print(paste0("Sequence : ",tt$SeqAir))
      #if(orderDate >= tmp_air[j,]$PRODUCT_START_TMS & orderDate <= tmp_air[j,]$PRODUCT_STOP_TMS){
        #print(tmp_air[j,])
        #tmp[i,]$AIRStart <- tmp_air[j,]$PRODUCT_START_TMS
        #tmp[i,]$AIREnd <- tmp_air[j,]$PRODUCT_STOP_TMS
      #}
    #}
  }
}

# 실제 적용.
air_product$SEQ <- 1:nrow(air_product)

for(i in 1:nrow(order_df)){
  productId <- order_df[i,2]
  orderDate <- order_df[i,]$ORDER_DATES
  tmp_air <- air_product[(air_product$PRODUCT_ID==productId)&(air_product$PRODUCT_START_TMS < orderDate) ,]
  if(nrow(tmp_air)>0){
    nearest <- tmp_air[which(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS))==min(abs(as.numeric(orderDate-tmp_air$PRODUCT_STOP_TMS)))),]

    order_df[i,]$AIR_START <- nearest$PRODUCT_START_TMS[1]
    order_df[i,]$AIR_END <- nearest$PRlODUCT_STOP_TMS[1]
  }
}

write.csv(order_df,"order_data4.csv",row.names = F)

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


air_product <- merge(air_product,product,by="PRODUCT_ID")
air_product$AIR_DATE <- as.character(air_product$AIR_DATE)
air_product$PRODUCT_START_TMS <- as.character(air_product$PRODUCT_START_TMS)
air_product$PRODUCT_STOP_TMS <- as.character(air_product$PRODUCT_STOP_TMS)
air_product <- air_product %>% arrange(PRODUCT_ID,PRODUCT_START_TMS,PRODUCT_STOP_TMS) 

order_df <- read.csv("order_data.csv",stringsAsFactors = F)

tmp_df <- merge(order_df,air_product,by.x="SEQ",by.y="SeqAir")
tmp_df$AIR_DATE <- as.POSIXlt(tmp_df$AIR_DATE,format="%Y-%m-%d")
tmp_df$PRODUCT_START_TMS <- as.POSIXlt(tmp_df$PRODUCT_START_TMS,format="%Y-%m-%d %H:%M")
tmp_df$PRODUCT_STOP_TMS <- as.POSIXlt(tmp_df$PRODUCT_STOP_TMS,format="%Y-%m-%d %H:%M")
tmp_df$ORDER_DATES <- as.POSIXlt(tmp_df$ORDER_DATES,format="%Y-%m-%d %H:%M:%S")
tmp_df$ORDER_DAY <- tmp_df$ORDER_DATES$wday
tmp_df$AIR_HOUR <- tmp_df$PRODUCT_START_TMS$hour

tmp_df$AIR_DATE <- as.character(tmp_df$AIR_DATE)
tmp_df$PRODUCT_START_TMS <- as.character(tmp_df$PRODUCT_START_TMS)
tmp_df$PRODUCT_STOP_TMS <- as.character(tmp_df$PRODUCT_STOP_TMS)
tmp_df$ORDER_DATES <- as.character(tmp_df$ORDER_DATES)

# 요일별 주문 Count ####
v_day <- tmp_df %>% group_by(ORDER_DAY) %>% summarize(cnt=n())

# 방송 시간대별, 카테고리별 주문 Count ####
v_air_cate <- tmp_df %>% group_by(AIR_HOUR,MERCH_DIV_DESC) %>% summarize(cnt = n())
v_air <- v_air_cate %>% group_by(AIR_HOUR) %>% summarize(cnt = sum(cnt))

v1 <- order_df %>% group_by(CUSTOMER_NBR,ORDER_DATE) %>% select(CUSTOMER_NBR,ORDER_DATE,PRODUCT_ID) %>% arrange(CUSTOMER_NBR,ORDER_DATE,PRODUCT_ID)
tmp <- split(v1$PRODUCT_ID,v1$CUSTOMER_NBR)

trans <- as(split(v1$PRODUCT_ID,v1$CUSTOMER_NBR), "transactions")


# 3. 지리별, 시간대별 Group_by MaxCnt, MaxAmt => Product별, Category별 ####

#a <- order_df %>% group_by(STATE,ORDER_HOUR,PACKING_SLIP_DESC) %>% summarize(Pro_cnt=n())
#head(a)
v3_1 <- order_df %>% group_by(STATE,ORDER_HOUR,PACKING_SLIP_DESC) %>% summarize(Pro_cnt=n()) %>% slice(which.max(Pro_cnt))
v3_2 <- order_df %>% group_by(STATE,ORDER_HOUR,MERCH_DIV_DESC) %>% summarize(Category_cnt=n()) %>% slice(which.max(Category_cnt))
v3 <- merge(v3_1,v3_2,by=c("STATE","ORDER_HOUR"))
head(v3)
# 4. 시간대 별로 가장 많이 팔리는 것.####

v4_1 <- order_df %>% group_by(ORDER_HOUR,PACKING_SLIP_DESC) %>% summarize(Hour_P_cnt=n()) %>% slice(which.max(Hour_P_cnt))
v4_2 <- order_df %>% group_by(ORDER_HOUR,MERCH_DIV_DESC) %>% summarize(Hour_C_cnt=n()) %>% slice(which.max(Hour_C_cnt))
v4 <- merge(v4_1,v4_2,by=c("ORDER_HOUR"))
head(v4)

write.csv(v4,"Most Sell_Per_hour.csv",row.names=F)

# 지도 그리기 ####
head(v_customer)

map<-get_map(location='united states', zoom=4, maptype = "terrain",
             source='google',color='color')

ggmap(map) + geom_point(
  aes(x=longitude, y=latitude, show_guide = TRUE, colour=cnt), 
  data=v_customer, alpha=.2,na.rm = T)  + 
  scale_color_gradient(low="beige", high="blue")


# barplot 을 위한 Data ####

state_number <- v_customer %>% group_by(state) %>% summarize(cnt = sum(cnt))
write.csv(state_number,"state_number.csv",row.names = F)

# Trans Data ####
tr <- df %>% distinct(CUSTOMER_NBR,PRODUCT_ID)

# Count of orderNumber
num_of_order <- order_df %>% group_by(CUSTOMER_NBR) %>% summarize(cnt = n())

trans <- as(split(tr$PRODUCT_ID, tr$CUSTOMER_NBR), "transactions")
inspect(trans[1:2])
itemFrequency(trans, type="absolute")

itemFrequencyPlot(trans, support=0.2, cex.names=0.8)

df_543664 <- df[df$CUSTOMER_NBR==543664,]
df_543664$ORDER_DATE <- as.character(df_543664$ORDER_DATE)
tr_543664 <- df_543664 %>% distinct(ORDER_DATE,ORDER_TIME,PRODUCT_ID)
tr_543664 <- tr_543664[order(tr_543664$ORDER_DATE,tr_543664$ORDER_TIME),]

df$ORDER_DATE <-  as.character(df$ORDER_DATE)
tr <- df %>% distinct(CUSTOMER_NBR,ORDER_DATE,ORDER_TIME,PRODUCT_ID)
tr <- tr[order(tr$CUSTOMER_NBR,tr$ORDER_DATE,tr$ORDER_TIME),]
split(head(tr$PRODUCT_ID),head(tr$CUSTOMER_NBR))

test <- function(x){
  userid <- unique(x$CUSTOMER_NBR)
  for(i in 1:length(userid)){
    tmp_df <- x[x$CUSTOMER_NBR==userid[i],]
    a <- split(tmp_df$PRODUCT_ID, tmp_df$ORDER_DATE)
    for(j in 1:length(a)){
      dateOforder <- paste(a[names(a)[i]][[1]],collapse = ",")
      x[x$ORDER_DATE==names(a)[i],"Orders"] <- dateOforder 
    }
  }
  return(x)
}

test2 <- function(x){
  id <- unique(x$CUSTOMER_NBR)
  print(id)
  print(head(x))
}

tmp <- tr
tmp <- test(tmp)

test2(tmp)


trans <- as(split(tr_543664$PRODUCT_ID, tr_543664$ORDER_DATE), "transactions")
rules <- apriori(trans, parameter=list(support=0.02, confidence=0.70))
summary(rules)

rules2 <- apriori(trans,parameter = list(support=0.02,target="frequent itemsets"))
a <- split(tr_543664$PRODUCT_ID, tr_543664$ORDER_DATE)
# 
# for(i in 1:nrow(orderlist)){
#   orderlist[i,]$ORDER_TIMES <- strsplit(orderlist[i,]$ORDER_TIME,":")[[1]][1]
# }
