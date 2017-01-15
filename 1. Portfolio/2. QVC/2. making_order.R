# 2016-12-11 Making Order ####

library(stringr)
library(arules)
library(dplyr)
library(maps)
library(ggplot2)
library(ggmap)
library(lubridate)

customer <- read.csv("Customer master.csv",stringsAsFactors = T)
customer$ZIP_CODE <- as.factor(customer$ZIP_CODE)
customer$SHOPPER_SEGMENT_CODE[is.na(customer$SHOPPER_SEGMENT_CODE)] <- 0

zip <- read.csv("zipcode.csv")
customer <- merge(customer,zip[,c(1,2,4,5)],by.x='ZIP_CODE', by.y='zip')
timezone <- read.csv("timezone.csv", stringsAsFactors = F)
timezone2 <- timezone %>% distinct(state,timezone)
timezone2  <- timezone2[-c(19,25,29,42,46,48,37,53,58),]
names(timezone2)[1] <- "STATE"
customer <- merge(customer,timezone2,by="STATE")

# customer[customer$timezone=="MST7MDT",]$timezone <- "MST"
# customer[customer$timezone=="CST6CDT",]$timezone <- "CST"
# customer[customer$timezone=="PST8PDT",]$timezone <- "PST"
# customer[customer$timezone=="EST5EDT",]$timezone <- "EST"

#write.csv(customer,"Customer master2.csv",row.names = F)

orderlist <- read.csv("6 month history of customer orders.csv")
orderlist$ORDER_DATE <- ymd(ymd_hm(orderlist$ORDER_DATE))

orderlist$ORDER_DATES <- paste(orderlist$ORDER_DATE,orderlist$ORDER_TIME)
orderlist$ORDER_DATES <- ymd_hms(orderlist$ORDER_DATES)

orderlist$ORDER_YEAR <- year(orderlist$ORDER_DATES)
orderlist$ORDER_MON <- month(orderlist$ORDER_DATES)
orderlist$ORDER_DAY <- wday(orderlist$ORDER_DATES)
orderlist$ORDER_HOUR <- hour(orderlist$ORDER_DATES)

product <- read.csv("Product master2.csv",stringsAsFactors = T)

air_product <- read.csv("Product airtime.csv", stringsAsFactors = F)
air_product$SEQ <- 1:nrow(air_product)
air_product$AIR_DATE <- ymd(ymd_hm(air_product$AIR_DATE))
air_product$PRODUCT_START_TMS <- ymd_hm(air_product$PRODUCT_START_TMS)
air_product$PRODUCT_STOP_TMS <- ymd_hm(air_product$PRODUCT_STOP_TMS)

#air_product <- merge(air_product,product,by="PRODUCT_ID")

order_df <- merge(orderlist,customer,by="CUSTOMER_NBR")

getNear3 <- function(x){
  pdID <- x[1]
  odDate <- x[2]
  #tmp_air <- air_product[air_product$PRODUCT_ID==pdID & air_product$PRODUCT_START_TMS < odDate,] %>% 
  # arrange(desc(PRODUCT_START_TMS,PRODUCT_STOP_TMS))
  tmp_air <- air_product %>% 
    filter(PRODUCT_ID==pdID & PRODUCT_START_TMS < odDate) %>% 
    arrange(desc(PRODUCT_START_TMS,PRODUCT_STOP_TMS))
  result <- 0
  print(paste0("Product ID :",pdID))
  print(paste0("orderDate : ",odDate))
  print(nrow(tmp_air))
  if(nrow(tmp_air) > 0){
    n_df <- tmp_air[1,]
    print(paste0("Start Time :",n_df$PRODUCT_START_TMS))
    print(paste0("End Time : ",n_df$PRODUCT_STOP_TMS))
    print(paste0("Sequence : ",n_df$SEQ))
    result <- n_df$SEQ
  }
  return(result)
}

order_df$SEQ <- apply(order_df[,c(4,7)],1,getNear3)
#write.csv(tmp_df,"pre_order_data.csv",row.names = F)

order_df <- read.csv("pre_order_data.csv", stringsAsFactors = F)
order_df <- merge(order_df,product,by="PRODUCT_ID")

air_product$AIR_DATE <- as.character(air_product$AIR_DATE)
air_product$PRODUCT_START_TMS <- as.character(air_product$PRODUCT_START_TMS)
air_product$PRODUCT_STOP_TMS <- as.character(air_product$PRODUCT_STOP_TMS)
air_product <- air_product %>% arrange(PRODUCT_ID,PRODUCT_START_TMS,PRODUCT_STOP_TMS) 

order_df <- merge(order_df,air_product[,-1],by="SEQ",all.x=T)

order_df$AIR_DATE <- ymd(order_df$AIR_DATE)
order_df$PRODUCT_START_TMS <- ymd_hms(order_df$PRODUCT_START_TMS)
order_df$PRODUCT_STOP_TMS <- ymd_hms(order_df$PRODUCT_STOP_TMS)
order_df$ORDER_DATES <- ymd_hms(order_df$ORDER_DATES)
order_df$PRODUCT_START_TMS <- ymd_hms(order_df$PRODUCT_START_TMS)
order_df$AIR_MON <- month(order_df$PRODUCT_START_TMS)
order_df$START_HOUR <- hour(order_df$PRODUCT_START_TMS)
order_df$PRODUCT_STOP_TMS <- ymd_hms(order_df$PRODUCT_STOP_TMS)
order_df$STOP_HOUR <- hour(order_df$PRODUCT_STOP_TMS)

#order_df[order_df$timezone=="MST7MDT",]$timezone <- "MST"
#order_df[order_df$timezone=="CST6CDT",]$timezone <- "CST"
#order_df[order_df$timezone=="PST8PDT",]$timezone <- "PST"
#order_df[order_df$timezone=="EST5EDT",]$timezone <- "EST"

write.csv(order_df,"order_data.csv",row.names = F)

