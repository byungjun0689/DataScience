library(stringr)
library(arules)
library(dplyr)
library(lubridate)
library(reshape2)
# Clustering ####
# Making rowData ####

customer <- read.csv("Customer master2.csv",stringsAsFactors = F)
# customer[customer$timezone=="MST7MDT",]$timezone <- "MST"
# customer[customer$timezone=="CST6CDT",]$timezone <- "CST"
# customer[customer$timezone=="PST8PDT",]$timezone <- "PST"
# customer[customer$timezone=="EST5EDT",]$timezone <- "EST"
# write.csv(customer,"Customer master2.csv",row.names = F)

order_df <- read.csv("order_data.csv", stringsAsFactors = F)
# order_df[order_df$timezone=="MST7MDT",]$timezone <- "MST"
# order_df[order_df$timezone=="CST6CDT",]$timezone <- "CST"
# order_df[order_df$timezone=="PST8PDT",]$timezone <- "PST"
# order_df[order_df$timezone=="EST5EDT",]$timezone <- "EST"
# write.csv(order_df,"order_data.csv",row.names = F)


# 1. 고객별 전체 구매 횟수 ####
v.1 <- order_df %>% group_by(CUSTOMER_NBR) %>% summarize(customer_order_cnt = n())

# 2. 6개월 3개월 구매 횟수 ####
# 2.1 6개월 구매 횟수
end_date <- ymd(max(order_df$ORDER_DATE))
start_date <- ymd('20130330') -months(6)

v.2.1 <- order_df %>% filter(start_date<=ORDER_DATE & ORDER_DATE <= end_date) %>% 
  group_by(CUSTOMER_NBR) %>% summarize(nop6=n())

# 2.2 3개월 구매 횟수

start_date <- ymd('20130330') -months(3)

v.2.2 <- order_df %>% filter(start_date<=ORDER_DATE & ORDER_DATE <= end_date) %>%  
  group_by(CUSTOMER_NBR) %>% summarize(nop3=n())

v.2 <- left_join(v.2.1,v.2.2) 
v.2$nop3[is.na(v.2$nop3)] <- 0

# 3. 한번에 왔을때 최대 구매 횟수 

v.3 <- order_df %>% group_by(CUSTOMER_NBR,ORDER_DATE) %>% summarize(once_buy_cnt = n()) %>% slice(which.max(once_buy_cnt)) 

# 4. 구매 다양성 (제품, 브랜드, 카테고리)
# 4.1 제품

v.4.1 <- order_df %>% distinct(CUSTOMER_NBR,PRODUCT_ID) %>% 
  group_by(CUSTOMER_NBR) %>% 
  summarize(various_product=n())

# 4.2 카테고리
v.4.2 <- order_df %>% distinct(CUSTOMER_NBR,MERCH_DIV_DESC) %>% 
  group_by(CUSTOMER_NBR) %>% 
  summarize(various_category=n())

# 4.3 브랜드
v.4.3 <- order_df %>% distinct(CUSTOMER_NBR,BRAND_NAME) %>% 
  group_by(CUSTOMER_NBR) %>% 
  summarize(various_brand=n())

v.4 <- left_join(v.4.1,v.4.2) %>% left_join(v.4.3)

# 5. 구매 일수와 평균 구매 주기 
start_date = ymd(min(order_df$ORDER_DATE))
end_date = ymd(max(order_df$ORDER_DATE))

v.5 <- order_df %>% 
  distinct(CUSTOMER_NBR,ORDER_DATE) %>% 
  group_by(CUSTOMER_NBR) %>% 
  summarize(visits=n()) %>% 
  mutate(API = round(as.integer(end_date - start_date)/visits))

# 6. 주 구매 시간대 
v.6 <- order_df %>% group_by(CUSTOMER_NBR,ORDER_HOUR) %>%
  summarize(favorite_time=n()) %>% slice(which.max(favorite_time)) 

v.6 <- v.6[,-3]
names(v.6)[2] <- "favorite_time"

# 7. 주 구매 제품 중 방송 시청 후 구매했던 제품 중 선호하는 방송 시간대 
v.7 <- order_df %>% distinct(CUSTOMER_NBR) %>% select(CUSTOMER_NBR)
v.7.1 <- order_df %>% filter(SEQ != 0) %>% group_by(CUSTOMER_NBR,START_HOUR) %>%
  summarize(favor_air_time=n()) %>% slice(which.max(favor_air_time)) 

v.7.1[v.7.1$START_HOUR==0,]$START_HOUR  <- 24

v.7 <- left_join(v.7,v.7.1)
v.7$START_HOUR[is.na(v.7$START_HOUR)] <- 0
v.7$favor_air_time[is.na(v.7$favor_air_time)] <- 0

v.7 <- v.7[,-3]
names(v.7)[2] <- "favor_air_time"

# 8. 방송이있는 구매 횟수 / 방송이 없는 구매 횟수
# 8.1 방송이 있는 구매 횟수
# 8.2 방송이 없는 구매 횟수
v.8 <- order_df %>% distinct(CUSTOMER_NBR)
v.8.1 <- order_df %>% filter(SEQ!=0) %>% group_by(CUSTOMER_NBR) %>% summarize(air_cnt =n())
v.8.2 <- order_df %>% filter(SEQ==0) %>% group_by(CUSTOMER_NBR) %>% summarize(no_air_cnt =n())

v.8 <- left_join(v.8,v.8.1) %>% left_join(v.8.2)
v.8$air_cnt[is.na(v.8$air_cnt)] <- 0
v.8$no_air_cnt[is.na(v.8$no_air_cnt)] <- 0

tmp <- left_join(v.1,v.2) %>% left_join(v.4) %>% 
  left_join(v.5) %>%
  left_join(v.6) %>%
  left_join(v.7) %>%
  left_join(v.8)

tmp <- as.data.frame(tmp)

timezone_label <- customer %>% distinct(timezone)
timezone_label$tz <- 1:nrow(timezone_label)

tmp <- left_join(tmp,customer[,c(3,8)])
tmp <- left_join(tmp,timezone_label)
tmp <- tmp[,-14]
tmp <- left_join(tmp,customer[,c(3,4)])
tmp$SHOPPER_SEGMENT_CODE[is.na(tmp$SHOPPER_SEGMENT_CODE)] <- 0

write.csv(tmp,"base_data_of_cluster.csv",row.names = F)

library(cluster)
library(NbClust)
library(kohonen)
library(ggplot2)
library(gridExtra)
library(scales)
library(RColorBrewer)
library(fields) # to use designer.colors

d <- dist(tmp[,-1], method = "euclidean")
fit <- hclust(d, method="ward.D")
plot(fit)

wss <- 0;
for(i in 1:15){
  wss[i] <- kmeans(tmp[,-1], centers=i)$tot.withinss
}
plot(1:15, wss, type="b", xlab="# of clusters", ylab="Within group sum of squares")


nc = NbClust(tmp[,-1], min.nc=2, max.nc=15, method='kmeans') # 2 ~ 15개 kmeans를 비교.
barplot(table(nc$Best.nc[1,]), xlab="# of clusters", ylab="# of criteria", main="Number of clusters chosen by 26 criteria")


# SOM ####


tmp.n <- scale(subset(tmp, select=-c(CUSTOMER_NBR)))
tmp.n <- as.data.frame(tmp.n)

nc = NbClust(tmp.n, min.nc=2, max.nc=15, method='kmeans') # 2 ~ 15개 kmeans를 비교.
barplot(table(nc$Best.nc[1,]), xlab="# of clusters", ylab="# of criteria", main="Number of clusters chosen by 26 criteria")



sm <- som(data = tmp.n, grid = somgrid(10, 10, "rectangular"))
str(sm)

plot(sm, main = "feature distribution")
plot(sm, type="counts", main = "cluster size")
plot(sm, type="quality", main = "mapping quality")

coolBlueHotRed <- function(n, alpha = 1) {
  rainbow(n, end=4/6, alpha=alpha)[n:1]
}

for (i in 1:ncol(sm$data))
  plot(sm, type="property", property=sm$codes[,i], main=dimnames(sm$data)[[2]][i], palette.name=coolBlueHotRed)



tmp$clusterX <- sm$grid$pts[sm$unit.classif,"x"]
tmp$clusterY <- sm$grid$pts[sm$unit.classif,"y"]
p <- ggplot(tmp, aes(clusterX, clusterY))
p + geom_jitter(position = position_jitter(width=.2, height=.2))

# kmeans 

tmp.n <- scale(subset(tmp, select=-c(CUSTOMER_NBR)))
tmp.n <- as.data.frame(tmp.n)

kc <- kmeans(tmp.n,3)
tmp.n$cluster <- kc$cluster

#pairs.panels(tmp.n)

#par(mfrow=c(1,1))

pairs(tmp.n[,-15],col=tmp.n$cluster,pch=tmp.n$cluster)

tmp$cluster <- kc$cluster
order_df <- left_join(order_df,tmp[,c(1,16)])

write.csv(order_df,"order_data_with_cluster.csv",row.names = F)


par(mfrow=c(1,1))
# 카테고리별 ####
# Cluster 1 
order_df_1 <- order_df %>% filter(cluster==1)
tr.filter_1 <- order_df_1 %>% distinct(CUSTOMER_NBR,MERCH_DIV_DESC)
head(split(tr.filter_1$MERCH_DIV_DESC, tr.filter_1$CUSTOMER_NBR))
trans_1 <- as(split(tr.filter_1$MERCH_DIV_DESC, tr.filter_1$CUSTOMER_NBR), "transactions") #transactions 메소드 
inspect(trans_1[1:10])
itemFrequency(trans_1, type="absolute")
itemFrequencyPlot(trans_1, topN = 5, main = "trans1 support top 5 items",cex.names=0.6)
rules_1 <- apriori(trans_1[,-2],parameter = list(support=0.005,target="frequent itemsets"))

# Cluster 2
order_df_2 <- order_df %>% filter(cluster==2)
tr.filter_2 <- order_df_2 %>% distinct(CUSTOMER_NBR,MERCH_DIV_DESC)
trans_2 <- as(split(tr.filter_2$MERCH_DIV_DESC, tr.filter_2$CUSTOMER_NBR), "transactions") #transactions 메소드 
itemFrequency(trans_2, type="absolute")
itemFrequencyPlot(trans_2, topN = 5, main = "trans2 support top 5 items",cex.names=0.6)
rules_2 <- apriori(trans_2[,-2],parameter = list(support=0.005,target="frequent itemsets"))

# Cluster 3
order_df_3 <- order_df %>% filter(cluster==3)
tr.filter_3 <- order_df_3 %>% distinct(CUSTOMER_NBR,MERCH_DIV_DESC)
trans_3 <- as(split(tr.filter_3$MERCH_DIV_DESC, tr.filter_3$CUSTOMER_NBR), "transactions") #transactions 메소드 
itemFrequency(trans_3, type="absolute")
itemFrequencyPlot(trans_3, topN = 5, main = "trans3 support top 5 items",cex.names=0.6)
rules_3 <- apriori(trans_3[,-2],parameter = list(support=0.005,target="frequent itemsets"))


####### 아에다른 방향으로 ####
## 각 항목당 횟수를 이용해서 Vertor화 

library(psych)

order_df <- read.csv("order_data.csv",stringsAsFactors = F)


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

write.csv(order_df,"order_data_cluster.csv",row.names = F)
#install.packages("recommenderlab")
library(recommenderlab)


order_df <- read.csv("order_data_cluster.csv", stringsAsFactors = F)
customer <- read.csv("Customer master2.csv",stringsAsFactors = F)
for(i in 1:9){
  tmp_df <- order_df %>% filter(cluster==i)
  assign(paste0("cluster_",i),tmp_df)
  #write.csv(tmp_df,paste0("cluster_",i,".csv"),row.names = F)
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

getRecommand <- function(x,y){
  if(x=="cate"){
    getCategoryRecommand(y)
  }else{
    getProductRecommand(y)
  }
}

library(arules)

# order_df 에서 Cluster별로 쪼갠 후 작업.####
# tr_1 <- order_df_1 %>% group_by(CUSTOMER_NBR,MERCH_DIV_DESC) %>% summarize(cate_cnt = n())
# # if custid = 441
# tmp_list <- tr_1[tr_1$CUSTOMER_NBR==441,]$MERCH_DIV_DESC
# tmp_list <- as.data.frame(tmp_list)
# tmp_tr <- tr_1 %>% filter(CUSTOMER_NBR!=441) %>% group_by(MERCH_DIV_DESC) %>% summarize(cnt = n()) %>% arrange(desc(cnt))
# tmp_tr <- as.data.frame(tmp_tr)
# tmp_tr$percent <- round(prop.table(tmp_tr$cnt),2)
# tmp_tr <- tmp_tr %>% filter(!(MERCH_DIV_DESC %in% tmp_list$tmp_list))


