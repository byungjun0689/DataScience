order_df <- read.csv("order_data_cluster.csv", stringsAsFactors = F)
customer <- read.csv("customer_with_cluster.csv",stringsAsFactors = F)

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