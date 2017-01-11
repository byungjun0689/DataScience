install.packages("arulesSequences")
library(arulesSequences)
library(reshape2)
library(reshape)
library(dplyr)
library(gtools)
library(stringr)
library(Matrix)
library(arules)



order_df <- read.csv("order_data2.csv",stringsAsFactor = F)
customer <- read.csv("Customer master.csv",stringsAsFactors = F)
ct <- customer %>% select(CUSTOMER_NBR,SHOPPER_SEGMENT_CODE)

tmp_df <- order_df %>% 
  arrange(MERCH_DIV_DESC) %>% unique() %>% 
  group_by(CUSTOMER_NBR,AIR_DATE) %>% 
  summarise(cart=paste(MERCH_DIV_DESC,collapse=";")) %>%  
  ungroup()

head(tmp_df)

tr <- order_df
head(split(tr$MERCH_DIV_DESC, tr$ORDER_NBR),3)
trans <- as(split(tr$MERCH_DIV_DESC, tr$ORDER_NBR), "transactions") #transactions 메소드 
inspect(trans)
trans_df <- as(trans,"data.frame")

names(trans_df)[[2]] <- "sequenceID"
head(trans_df)

tmp_df <- order_df %>% select(CUSTOMER_NBR,ORDER_NBR)

trans_df <- merge(trans_df,tmp_df,by.x="sequenceID", by.y="ORDER_NBR")
trans_df <- trans_df %>% select(items,sequenceID,CUSTOMER_NBR)
names(trans_df)[[3]] <- "eventID"
trans_df$sequenceID <- as.integer(trans_df$sequenceID)
trans_df$eventID <- as.integer(trans_df$eventID)
trans_df$items <- as.character(trans_df$items)

trans_df <- trans_df %>% arrange(sequenceID,eventID)
head(trans_df)


getLength <- function(x){
  len <- length(strsplit(x,",")[[1]])
  return(len)
}

trans_df$size <- sapply(trans_df$items,getLength)

trans_df <- trans_df %>% select(sequenceID)


#### reshape 2 ####
# "sequenceID","eventID","SIZE", "items"
# 1 10 2 C D
# 1 15 3 A B C
# 1 20 3 A B F
# 1 25 4 A C D F
# 2 15 3 A B F
# 2 20 1 E
# 3 10 3 A B F
# 4 10 3 D G H
# 4 20 2 B F
# 4 25 3 A G H

#### 카데고리 #### 

order_df <- read.csv("order_data_with_cluster.csv",stringsAsFactor = F)
customer <- read.csv("customer_with_cluster.csv",stringsAsFactors = F)

for(i in 1:9){
  tmp_df <- order_df %>% filter(cluster==i)
  assign(paste0("cluster_seq_",i),tmp_df)  
}
for(custCluster in 1:9){
  item_df2 <- get(paste0("cluster_seq_",custCluster)) %>% 
    group_by(ORDER_NBR,CUSTOMER_NBR) %>% summarize(size=n())
  item_df2 <- item_df2 %>% arrange(desc(size))
  size <- item_df2[1,]$size
  df.new2 <- data.frame()
  for(i in 1:nrow(item_df2)){
    x <- item_df2[i,]$ORDER_NBR
    tmp_df <- get(paste0("cluster_seq_",custCluster))[get(paste0("cluster_seq_",custCluster))$ORDER_NBR==x,]
    cast_df <- data.frame(t(unlist(tmp_df$MERCH_DIV_DESC)))
    if(length(cast_df)==1){names(cast_df)[1] <- "X1"}
    cast_df$ORDER_NBR=x  
    df.new2 <- smartbind(df.new2,cast_df)
  }
  tmp_new2 <- df.new2[-1,]
  item_df2 <- merge(item_df2,tmp_new2,by="ORDER_NBR")
  item_df2$X1 <- as.character(item_df2$X1)
  item_df2$X2 <- as.character(item_df2$X2)
  item_df2$X3 <- as.character(item_df2$X3)
  item_df2$X4 <- as.character(item_df2$X4)
  item_df2$X5 <- as.character(item_df2$X5)
  item_df2$X6 <- as.character(item_df2$X6)
  item_df2$X7 <- as.character(item_df2$X7)
  item_df2$X8 <- as.character(item_df2$X8)
  item_df2$X9 <- as.character(item_df2$X9)
  item_df2$X1[is.na(item_df2$X1)] <- ""
  item_df2$X2[is.na(item_df2$X2)] <- ""
  item_df2$X3[is.na(item_df2$X3)] <- ""
  item_df2$X4[is.na(item_df2$X4)] <- ""
  item_df2$X5[is.na(item_df2$X5)] <- ""
  item_df2$X6[is.na(item_df2$X6)] <- ""
  item_df2$X7[is.na(item_df2$X7)] <- ""
  item_df2$X8[is.na(item_df2$X8)] <- ""
  item_df2$X9[is.na(item_df2$X9)] <- ""
  if(size > 9 ){
    item_df2$X10 <- as.character(item_df2$X10)
    item_df2$X10[is.na(item_df2$X10)] <-""
    if(size > 10){
      item_df2$X11 <- as.character(item_df2$X11)
      item_df2$X11[is.na(item_df2$X11)] <- ""
      if(size >11){
        item_df2$X12 <- as.character(item_df2$X12)  
        item_df2$X12[is.na(item_df2$X12)] <- ""  
      }
    }
  }
  write.table(item_df2,paste0("item_cate_",custCluster,".txt"),sep="#",row.names = F,col.names = F)
}

getProductRecommand <- function(x){
  custId <- x
  custCluster <- customer[customer$CUSTOMER_NBR==custId,]$cluster
  baskets <-  read_baskets(con  = paste0("item_cate_",custCluster,".txt"),sep = "#", info = c("sequenceID","eventID","SIZE"))
  baskets <- cspade(baskets, parameter = list(support = 0.0001), control = list(verbose = TRUE))
  baskets_df <- as(baskets, "data.frame")
  baskets_df <- baskets_df[order(baskets_df$support,decreasing = T),]
  baskets_df$sequence <- gsub(pattern = "<\\{\"","",baskets_df$sequence)
  baskets_df$sequence <- gsub(pattern = "\"\\}>","",baskets_df$sequence)
  baskets_df$sequence <- gsub(pattern = "\"","",baskets_df$sequence)
  last_df <- order_df[order_df$CUSTOMER_NBR==custId,] %>% arrange(desc(ORDER_DATES)) %>% select(MERCH_DIV_DESC)
  last_cate <- last_df[1,]
  support_df <- baskets_df %>% filter(str_detect(sequence,last_cate))
  return(head(support_df[-1,]))
}

a <- getProductRecommand(355768)
a
tt <- order_df[order_df$CUSTOMER_NBR==355768,] %>% arrange(desc(ORDER_DATES)) %>% select(MERCH_DIV_DESC)
head(tt[1,])



