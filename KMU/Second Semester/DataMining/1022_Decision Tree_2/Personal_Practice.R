library(psych)
library(plyr)
library(C50)
library(caret)
library(ROCR)

user <- read.csv("2_group.csv", stringsAsFactors = T)
user <- user[,-c(3,4)]
user <- user[,-4]

user_tree <- user[,c(1:8,19,27,34:length(user))]

job <- read.delim("HDept/HDS_Jobs.tab",stringsAsFactors = T)

#user_tree <- read.csv("user_tree.csv")

# 0 : 무효 1 : 남성 2: 여
user_tree = join(user_tree,job,by="job_stype")
user_tree <- user_tree[,-(length(user_tree)-1)]
user_tree <- user_tree[,-20]
user_tree <- user_tree[user_tree$sex!=0,] #무효는 제외 

user_tree$sex <- factor(user_tree$sex)
user_tree$hobby <- factor(user_tree$hobby)
user_tree$job_stype <- factor(user_tree$job_stype)
user_tree$mail_flg <- factor(user_tree$mail_flg)
user_tree$h_type2 <- factor(user_tree$h_type2)
user_tree$card_flg1 <- factor(user_tree$card_flg1)
user_tree$mrg_flg <- factor(user_tree$mrg_flg)
user_tree$cus_stype <- factor(user_tree$cus_stype)
user_tree$agegrp <- factor(user_tree$agegrp)
user_tree$job_stype <- factor(user_tree$job_stype)

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

# favorite part Korean to index number
user_tree <- join(user_tree,df,by="fav_part")
user_tree$fav_part_index <- factor(user_tree$fav_part_index)

df <- data.frame(fav_part_index = 1:length(unique(user_tree$fav_part)), fav_part =unique(user_tree$fav_part))
df2 <- data.frame(fav_good_index = 1:length(unique(user_tree$fav_goodcd)), fav_goodcd =unique(user_tree$fav_goodcd))

user_tree <- join(user_tree,df2,by="fav_goodcd")
user_tree$fav_good_index <- factor(user_tree$fav_good_index)

write.csv(user_tree,"user_tree2.csv")

tmp <- user_tree



#user_tree$wk_pat <- factor(user_tree$wk_pat)


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

c5_options <- C5.0Control(winnow = T, noGlobalPruning = T)
c5_model <- C5.0(sex ~ mrg_flg+h_type2+hobby+cus_stype+group_member, data=user.train[,-1], control = c5_options, rules=T, trials = 20)

plot(c5_model)

summary(c5_model)
user.test$c5_pred <- predict(c5_model,user.test,type="class")
confusionMatrix(user.test$c5_pred, user.test$sex)





