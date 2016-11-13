library(psych)
library(plyr)
library(dplyr)
library(C50)
library(caret)
library(ROCR)
library(lubridate)
tr <- read.delim("HDept/HDS_Transactions_MG.tab",stringsAsFactors = F)
# tmp <- tr %>% 
#   group_by(custid, corner_nm) %>% 
#   summarize(corner_cnt=n()) %>% 
#   slice(which.max(corner_cnt)) 
# 
# cs <- read.delim("HDept/HDS_Customers.tab",stringsAsFactors = F)
# 
# card <- read.delim("HDept/HDS_Cards.tab", stringsAsFactors = F)

#### Signature만들기 ####

user <- read.csv("2_group.csv", stringsAsFactors = T)
# user <- user[,-c(3,4)]
# user <- user[,-4]
# 
# user_tree <- user[,c(1:8,19,27,34:length(user))]

user_tree <- user[,c(1,2,37:length(user))]

#job <- read.delim("HDept/HDS_Jobs.tab",stringsAsFactors = T)

#user_tree <- read.csv("user_tree.csv")

# 0 : 무효 1 : 남성 2: 여
# user_tree = join(user_tree,job,by="job_stype")
# user_tree <- user_tree[,-(length(user_tree)-1)]
# user_tree <- user_tree[,-20]
user_tree <- user_tree[user_tree$sex!=0,] #무효는 제외 

user_tree$sex <- factor(user_tree$sex)
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
cust_6 <- read.csv("6custsig.csv", stringsAsFactors = F)
tmp_cust <- cust_6[,c("custid","PAPV","P_group","p_trend","instCnt","instMonth","instRatio")]
user_tree <- join(user_tree,tmp_cust,by="custid")
#user_tree <- user_tree[,-c(12,13,22,26,31)] # age, agegrp, fav_goodcd, fav_part, group_member


# cs.ncus <- select(cs,custid,ncus_stype)
# cs.autopat <- select(cs,custid,autopat)
# cs.fml <- select(cs,custid,fml_cnt)
# 
# user_tree <- join(user_tree,cs.ncus,by="custid")
# user_tree <- join(user_tree,cs.autopat,by="custid")
# user_tree <- join(user_tree,cs.fml,by="custid")

set.seed(1)
inTrain <- createDataPartition(y=user_tree$sex,p=0.6,list=F)
user.train <- user_tree[inTrain,]
user.test <- user_tree[-inTrain,]
dim(user.test)
dim(user.train)

# 73.57%
#c5_options_1 <- C5.0Control(winnow = T, noGlobalPruning = T)
#c5_mode_1 <- C5.0(sex ~ mrg_flg+wk_pat+h_type1+h_type2+hobby+cus_stype+fav_time+mail_flg, data=user.train[,-1], control = c5_options_1, rules=F)

# 73.55%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+wk_pat+h_type1+h_type2+hobby+cus_stype+fav_good_index, data=user.train[,-1], control = c5_options, rules=F)

# 74.85%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+cus_stype+group_member, data=user.train[,-1], control = c5_options, rules=F)

# 74.92%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+cus_stype+group_member, data=user.train[,-1], control = c5_options, rules=T)

#75.88% T T
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+cus_stype+group_member+agegrp, data=user.train[,-1], control = c5_options, rules=T)

#76% T F
c5_options <- C5.0Control(winnow = T, noGlobalPruning = F)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+cus_stype+group_member+agegrp, data=user.train[,-1], control = c5_options, rules=T)

#76.15%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = F, CF=0.4)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+cus_stype+group_member+agegrp, data=user.train[,-1], control = c5_options, rules=T)

#76.14%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = F)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+group_member+agegrp+h_type1, data=user.train[,-1], control = c5_options, rules=F)

#76.17%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+group_member+agegrp+h_type1, data=user.train[,-1], control = c5_options, rules=F)

#76.19%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+group_member+agegrp+h_type1+main_store, data=user.train[,-1], control = c5_options, rules=T)

#76.22%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+group_member+agegrp+h_type1+main_store, data=user.train[,-1], control = c5_options, rules=F)

#77.44%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ ., data=user.train[,-1], control = c5_options, rules=F)

#77.53%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ ., data=user.train[,-1], control = c5_options, rules=T)

#77.57%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T)

# 77.61%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T)

# 78.27%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=10)

# 78.8%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=10)

# 78.97%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=20)


#c5_options <- C5.0Control(winnow = T, noGlobalPruning = T, CF=0.4)
#c5_model <- C5.0(sex ~ mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=10)

# 79.07%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ instRatio+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=20)

# 79.18%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ instRatio+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=30)

# 79.22%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=30)

# 79.19%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=40)

#83.02%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ fml_cnt+instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=30)

#83.04%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ fml_cnt+instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=30)

#83.05%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ fml_cnt+instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=F, trials=20)

#82.8%
c5_options <- C5.0Control(winnow = T, noGlobalPruning = T,CF=0.3)
c5_model <- C5.0(sex ~ ncus_stype+fml_cnt+instMonth+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=30)

#83.09%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ fml_cnt+instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=F, trials=40)

#83.1%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ fml_cnt+instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=T, trials=40)

c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ fml_cnt+instMonth+mrg_flg+hobby+h_type2+group_member+agegrp+card_flg1+job_stype+fav_part_mean_amt+NPPV+mail_flg+we_amt+cus_stype+visits, data=user.train[,-1], control = c5_options, rules=F, trials=40)


################## 재 시작 ####

# 72.18
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ instMonth + age + group_member + nop6 + pr_pref +stay_out, data=user.train[,-1], control = c5_options, rules=T)

# 72.63
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ fav_part_index + instMonth + age + group_member + nop6 + pr_pref +stay_out, data=user.train[,-1], control = c5_options, rules=T)

# 72.76
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ fav_part_index + instMonth + age + group_member + nop6 + pr_pref +stay_out, data=user.train[,-1], control = c5_options, rules=T, trials=20)

# 73%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ fav_part_index + instMonth + age + group_member + nop6 + pr_pref +stay_out, data=user.train[,-1], control = c5_options, rules=T, trials=20)

# 73.1%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ fav_part_index + instMonth + age + group_member + nop3 + pr_pref +stay_out, data=user.train[,-1], control = c5_options, rules=T, trials=20)

################## 재 시작2 ####

# 70.31
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.3)
c5_model <- C5.0(sex ~ wk_amt+amt12+fav_part_index+avg_disc+fav_time+sea_pref, data=user.train[,-1], control = c5_options, rules=T, trials=20)

#70.74
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ avg_disc+fav_part_index+fav_time+nop6+fav_good_index+buy_brd+main_store , data=user.train[,-1], control = c5_options, rules=F)

#70.91
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ avg_disc+fav_part_index+fav_time+nop6+fav_good_index+buy_brd+main_store , data=user.train[,-1], control = c5_options, rules=T)

#70.94%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = T)
c5_model <- C5.0(sex ~ avg_disc+fav_part_index+fav_time+nop6+fav_good_index+buy_brd+main_store , data=user.train[,-1], control = c5_options, rules=T)

#70.95%
c5_options <- C5.0Control(winnow = F, noGlobalPruning = T)
c5_model <- C5.0(sex ~ avg_disc+fav_part_index+fav_time+nop6+fav_good_index+buy_brd+main_store , data=user.train[,-1], control = c5_options, rules=T, trials=20)

# tr.v1 <- tr %>% group_by(custid,team_nm) %>% summarize(team_cnt=n())
# library(reshape)
# tr.v1_1 <- melt(tr.v1,id=c("custid","team_nm"))
# tr.v1_2 <- cast(tr.v1_1,custid~team_nm+variable)
# tr.v1 <- as.data.frame(tr.v1_2)
# colnames(tr.v1) <- c("custid","상품개발영업","식료품팀","의류패션팀","인터넷백화점팀","잡화가용팀")
# tr.v1[is.na(tr.v1)] <- 0
# 
# user_tree <- join(user_tree,tr.v1,by="custid")
# 
# tr.v2 <- tr %>% group_by(custid) %>% summarize(super_sum = sum(super_flg))
# user_tree <- join(user_tree,tr.v2,by="custid")
# 
# user_tree <- user_tree %>% mutate(상품개발=round(상품개발영업/visits,2), 식료품=round(식료품팀/visits,2), 의류 = round(의류패션팀/visits,2), 인터넷 = round(인터넷백화점팀/visits,2), 잡화=round(잡화가용팀/visits,2))
# 
# 
# #70.95%
# c5_options <- C5.0Control(winnow = F, noGlobalPruning = T)
# c5_model <- C5.0(sex ~ NPPV+avg_disc+fav_part_index+fav_time+nop6+fav_part_index+buy_brd+main_store , data=user.train[,-1], control = c5_options, rules=T, trials=20)
# 
# user_tree <- user_tree %>% mutate(mean_12=round(amt12/nop12), mean_6 = round(amt6/nop6), mean_3 = round(amt3/nop3))
# 
# tmp <- tr %>% group_by(custid,pc_nm) %>% summarize(pc_cnt = n()) %>% slice(which.max(pc_cnt))
# df3 <- data.frame(pc_index = 1:length(unique(tmp$pc_nm)), pc_nm =unique(tmp$pc_nm))
# 
# user_tree <- join(user_tree,tmp,by="custid")
# user_tree <- user_tree[,-52]
# user_tree <- join(user_tree,df3,by="pc_nm")
# 
# 
# set.seed(1)
# inTrain <- createDataPartition(y=user_tree$sex,p=0.6,list=F)
# user.train <- user_tree[inTrain,]
# user.test <- user_tree[-inTrain,]
# dim(user.test)
# dim(user.train)

c5_options <- C5.0Control(winnow = T, noGlobalPruning = F)
c5_model <- C5.0(sex ~ p_trend+avg_disc+fav_part_index+fav_time+nop6+fav_good_index+buy_brd+main_store , data=user.train[,-1], control = c5_options, rules=T)
summary(c5_model)
user.test$c5_pred <- predict(c5_model,user.test,type="class")
user.test$c5_pred_prob <- round(predict(c5_model,user.test,type="prob"),2)
confusionMatrix(user.test$c5_pred, user.test$sex)


pca = prcomp(user_tree[,c(3:10,14:19,27,28,34:38,40:42)],scale=T)
pca$rotation[,c(1,2)]

