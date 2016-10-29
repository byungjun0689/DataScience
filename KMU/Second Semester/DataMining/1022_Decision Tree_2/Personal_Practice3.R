library(psych)
library(plyr)
library(dplyr)
library(C50)
library(caret)
library(ROCR)
library(lubridate)
#tr <- read.delim("HDept/HDS_Transactions_MG.tab",stringsAsFactors = F)

#### Signature만들기 ####

user <- read.csv("2_group.csv", stringsAsFactors = T)
user_tree <- user[,c(1,2,37:length(user))]

# 0 : 무효 1 : 남성 2: 여
# user_tree = join(user_tree,job,by="job_stype")
# user_tree <- user_tree[,-(length(user_tree)-1)]
# user_tree <- user_tree[,-20]
user_tree <- user_tree[user_tree$sex!=0,] #무효는 제외

#cor(user_tree[,c(2:10,12:19,25,27:28,34:35,37:39)])

user_tree$sex <- factor(user_tree$sex)
#user_tree$sex <- as.integer(user_tree$sex)
#user_tree$hobby <- factor(user_tree$hobby)
#user_tree$job_stype <- factor(user_tree$job_stype)
#user_tree$mail_flg <- factor(user_tree$mail_flg)
#user_tree$h_type2 <- factor(user_tree$h_type2)
#user_tree$card_flg1 <- factor(user_tree$card_flg1)
#user_tree$mrg_flg <- factor(user_tree$mrg_flg)
#user_tree$cus_stype <- factor(user_tree$cus_stype)
#user_tree$agegrp <- factor(user_tree$agegrp)
#user_tree$job_stype <- factor(user_tree$job_stype)

user_tree$wk_pat <- as.character(user_tree$wk_pat)
user_tree[user_tree$wk_pat=="주말형",]$wk_pat <- "weekend"
user_tree[user_tree$wk_pat=="주중형",]$wk_pat <- "weekdays"
user_tree[user_tree$wk_pat=="유형없음",]$wk_pat <- "none"
user_tree$wk_pat <- factor(user_tree$wk_pat)

user_tree$main_store <- as.character(user_tree$main_store)
user_tree[user_tree$main_store=="신촌점",]$main_store <- "Sinchon"
user_tree[user_tree$main_store=="천호점",]$main_store <- "Chunho"
user_tree[user_tree$main_store=="무역점",]$main_store <- "Muyuk"
user_tree[user_tree$main_store=="본점",]$main_store <- "Bon"
user_tree$main_store <- factor(user_tree$main_store)

user_tree$group_member <- as.character(user_tree$group_member)
user_tree[user_tree$group_member=="그룹사",]$group_member <- "group"
user_tree[user_tree$group_member=="일반회원",]$group_member <- "normal"
user_tree$group_member <- factor(user_tree$group_member)

user_tree[user_tree$stay_out=="",]$stay_out <- "유지"
user_tree$stay_out <- as.character(user_tree$stay_out)
user_tree[user_tree$stay_out=="이탈/휴면",]$stay_out <- "out"
user_tree[user_tree$stay_out=="유지",]$stay_out <- "stay"
user_tree$stay_out <- factor(user_tree$stay_out)

user_tree$fav_paymthd <- as.character(user_tree$stay_out)
user_tree$fav_paymthd <- gsub(pattern = "개월",replacement = "",user_tree$fav_paymthd)
user_tree$fav_paymthd <- factor(user_tree$fav_paymthd)


# favorite part Korean to index number
df <- data.frame(fav_part_index = 1:length(unique(user_tree$fav_part)), fav_part =unique(user_tree$fav_part))
user_tree <- join(user_tree,df,by="fav_part")
user_tree$fav_part_index <- factor(user_tree$fav_part_index)


df2 <- data.frame(fav_good_index = 1:length(unique(user_tree$fav_goodcd)), fav_goodcd =unique(user_tree$fav_goodcd))
user_tree <- join(user_tree,df2,by="fav_goodcd")
user_tree$fav_good_index <- factor(user_tree$fav_good_index)

#write.csv(user_tree,"user_tree2.csv")
#user_tree$wk_pat <- factor(user_tree$wk_pat)

#user_tree <- user_tree[,-c(29,33,39)]
user_tree <- user_tree[,-c(12,13,22,26,31)]
cust_6 <- read.csv("6custsig.csv", stringsAsFactors = F)
tmp_cust <- cust_6[,c("custid","PAPV","P_group","p_trend","instCnt","instMonth","instRatio")]
user_tree <- join(user_tree,tmp_cust,by="custid")

set.seed(1)
inTrain <- createDataPartition(y=user_tree$sex,p=0.6,list=F)
user.train <- user_tree[inTrain,]
user.test <- user_tree[-inTrain,]
dim(user.test)
dim(user.train)

# T T T
# T T F
# T F T
# T F F
# F T T
# F F F
# F F T
# F T F

install.packages("combinat")
library(combinat)
library(gtools)

make <- function(train_data,test_data,str,detail,cnt,CF=0.25){
  df <- data.frame(Accur = integer(), Param = character(), Sub = character(), Cnt = integer())
  result <- NULL
  permn_str <- permn(str)
  sub_comb <-  permutations(2,3,detail,repeats=TRUE)
  length_permn <- length(permn_str)
  length_sub <- NROW(sub_comb)
  length_count <- length(cnt)
  rows <- 0
  for(i in 1:length_permn){
    param <- paste(permn_str[[i]],collapse = "+")
    for(j in 1:length_sub){
      sub_1 <-  sub_comb[j,1]
      sub_2 <-  sub_comb[j,2]
      sub_3 <- sub_comb[j,3]
      winnow <- 0
      c5_options <- C5.0Control(winnow = sub_1, noGlobalPruning = sub_2, CF = CF)
      for(k in 1:length_count){
        rows <- rows + 1
        params <- as.formula(gsub("\\\"","",paste("sex",param, sep=" ~ ")))
        if(cnt[k]>0){
          c5_model <- C5.0(params, data=train_data, control = c5_options, rules=sub_3, trials=cnt[k])
        }else{
          c5_model <- C5.0(params, data=train_data, control = c5_options, rules=sub_3)
        }
        test_data$c5_pred <- predict(c5_model,test_data,type="class")
        test_data$c5_pred_prob <- round(predict(c5_model,test_data,type="prob"),2)
        Accur <- confusionMatrix(test_data$c5_pred, test_data$sex)
        AccurResult <- Accur$overall[[1]]
        param_in <- deparse(params)
        sub <- toString(sub_comb[j,])
        df2 <- data.frame(Accur = AccurResult, Param = param_in, Sub = sub, Cnt = cnt[k])
        df <- rbind(df,df2)
      }
    } 
    print(rows)
  }
  return(df)
}

make2 <- function(train_data,test_data,str,detail,cnt,CF=0.25){
  df <- data.frame(Accur = integer(), Param = character(), Sub = character(), Cnt = integer())
  result <- NULL
  sub_comb <-  permutations(2,3,detail,repeats=TRUE)
  #length_permn <- length(permn_str)
  length_sub <- NROW(sub_comb)
  length_count <- length(cnt)
  rows <- 0
  param <- paste(str,collapse = "+")
  for(j in 1:length_sub){
    sub_1 <-  sub_comb[j,1]
    sub_2 <-  sub_comb[j,2]
    sub_3 <- sub_comb[j,3]
    winnow <- 0
    c5_options <- C5.0Control(winnow = sub_1, noGlobalPruning = sub_2, CF = CF)
    for(k in 1:length_count){
      rows <- rows + 1
      params <- as.formula(gsub("\\\"","",paste("sex",param, sep=" ~ ")))
      if(cnt[k]>0){
        c5_model <- C5.0(params, data=train_data, control = c5_options, rules=sub_3, trials=cnt[k])
      }else{
        c5_model <- C5.0(params, data=train_data, control = c5_options, rules=sub_3)
      }
      test_data$c5_pred <- predict(c5_model,test_data,type="class")
      test_data$c5_pred_prob <- round(predict(c5_model,test_data,type="prob"),2)
      Accur <- confusionMatrix(test_data$c5_pred, test_data$sex)
      AccurResult <- Accur$overall[[1]]
      param_in <- deparse(params)
      sub <- toString(sub_comb[j,])
      df2 <- data.frame(Accur = AccurResult, Param = param_in, Sub = sub, Cnt = cnt[k])
      df <- rbind(df,df2)
    }
    print(rows)
  }
  return(df)
}


sub <- c(T,F)
detail <- c(T,F)
count <- c(seq(0,40,10))
cnt <- c(seq(0,40,10))
train_data <- user.train[,-1]
test_data <- user.test

str <- c("pr_pref","sea_pref","API","amt12","instMonth","avg_disc","fav_part_index","fav_time","nop6","fav_good_index","buy_brd","main_store","visits")
str <- c("sea_pref","API","amt12","avg_disc","fav_part_index","fav_time")
str <- c("fav_time","buy_brd","avg_disc","amt12")
str <- c("wk_amt","we_amt","visits")


result <- make(user.train[,-1],user.test,str,sub,count)
result2 <- make2(user.train[,-1],user.test,str,sub,count)
result3 <- make2(user.train[,-1],user.test,str,sub,count,0.3)
result4 <- make2(user.train[,-1],user.test,str,sub,count)
result5 <- make2(user.train[,-1],user.test,str,sub,count,0.3)
result6 <- make2(user.train[,-1],user.test,str,sub,count) # 71%로 가장 높다 현재.
result7 <- make2(user.train[,-1],user.test,str,sub,count,0.3)
result8 <- make2(user.train[,-1],user.test,str,sub,count) 
result9 <- make2(user.train[,-1],user.test,str,sub,count,0.3)

result10 <- make(user.train[,-1],user.test,str,sub,count)

write.csv(result6, "result6.csv")

df <- data.frame(Accur = integer(), Param = character(), Sub = character())
df2 <- data.frame(Accur = 0.25, Param = "x ~ a+b", Sub = toString(s[1,]))
df2
df <- rbind(df,df2)
df
