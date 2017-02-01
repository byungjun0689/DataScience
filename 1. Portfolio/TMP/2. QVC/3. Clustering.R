library(stringr)
library(arules)
library(dplyr)
library(lubridate)
library(reshape2)
# Clustering ####
# Making rowData ####

customer <- read.csv("data/Customer master2.csv",stringsAsFactors = F)
order_df <- read.csv("data/order_data.csv", stringsAsFactors = F)

## 각 항목당 횟수를 이용해서 Vertor화 

library(psych)

cate_per_customer <- order_df %>% group_by(CUSTOMER_NBR,MERCH_DIV_DESC) %>% summarize(cnt = n())
cate_per_customer <- dcast(CUSTOMER_NBR ~ MERCH_DIV_DESC, data = cate_per_customer, value.var = "cnt")
cate_per_customer[is.na(cate_per_customer)] <- 0

item_per_customer <- order_df %>% group_by(CUSTOMER_NBR,PRODUCT_ID) %>% summarize(cnt = n())
item_per_customer <- dcast(CUSTOMER_NBR ~ PRODUCT_ID, data = item_per_customer, value.var = "cnt")
item_per_customer[is.na(item_per_customer)] <- 0

per_customer <- left_join(cate_per_customer,item_per_customer)

wss <- 0;
for(i in 1:12){
  wss[i] <- kmeans(per_customer[,-1], centers=i)$tot.withinss
}
plot(1:12, wss, type="b", xlab="# of clusters", ylab="Within group sum of squares")

# 9개로 결정 
set.seed(1)
kc <- kmeans(per_customer,9)
per_customer$cluster <- kc$cluster


order_df <- merge(order_df,per_customer[,c(1,8383)],by="CUSTOMER_NBR")
customer <- merge(customer,per_customer[,c(1,8383)],by="CUSTOMER_NBR")

#write.csv(order_df,"order_data_cluster.csv",row.names = F)
#write.csv(customer,"customer_with_cluster.csv",row.names=F)
#install.packages("recommenderlab")
library(recommenderlab)


order_df <- read.csv("order_data_cluster.csv", stringsAsFactors = F)
customer <- read.csv("customer_with_cluster.csv",stringsAsFactors = F)
for(i in 1:9){
  tmp_df <- order_df %>% filter(cluster==i)
  assign(paste0("cluster_",i),tmp_df)
  #write.csv(tmp_df,paste0("cluster_",i,".csv"),row.names = F)
}
for(i in 1:9){
  tmp_df <- get(paste0("cluster_",i))
  tmp_df <- tmp_df %>% group_by(CUSTOMER_NBR,MERCH_DIV_DESC) %>% 
    summarize(cnt = n()) %>% arrange(CUSTOMER_NBR)
  assign(paste0("cluster_cate_",i),as.data.frame(tmp_df))
}
for(i in 1:9){
  tmp_df <- get(paste0("cluster_",i))
  tmp_df <- tmp_df %>% group_by(CUSTOMER_NBR,PRODUCT_ID) %>% 
    summarize(cnt = n()) %>% arrange(CUSTOMER_NBR)
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
  other_df <- in_df %>% filter(CUSTOMER_NBR!=custId) %>% 
    group_by(PRODUCT_ID) %>% summarize(cnt = sum(cnt)) %>% arrange(desc(cnt))
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
  baskets <-  read_baskets(con  = paste0("item_cate_",custCluster,".txt"),sep = "#", info = c("sequenceID","eventID","SIZE"))
  baskets <- cspade(baskets, parameter = list(support = 0.0001), control = list(verbose = TRUE))
  baskets_df <- as(baskets, "data.frame")
  baskets_df <- baskets_df[order(baskets_df$support,decreasing = T),]
  baskets_df$sequence <- gsub(pattern = "<\\{\"","",baskets_df$sequence)
  baskets_df$sequence <- gsub(pattern = "\"\\}>","",baskets_df$sequence)
  baskets_df$sequence <- gsub(pattern = "\"","",baskets_df$sequence)
  last_df <- order_df[order_df$CUSTOMER_NBR==custId,] %>% 
    arrange(desc(ORDER_DATES)) %>% 
    select(MERCH_DIV_DESC)
  last_cate <- last_df[1,]
  support_df <- baskets_df %>% filter(str_detect(sequence,last_cate))
  print(paste0("last buy : ",last_cate))
  print(head(support_df[-1,]))
}

getRecommand <- function(x,y){
  if(x=="cate"){
    getCateRecommand2(y)
  }else{
    getProductRecommand(y)
  }
}



