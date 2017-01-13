install.packages("combinat")

library(plyr)  # Join 및 데이터 전처리를 위해 호출
library(dplyr) # 데이터 전처리를 위해 호출
library(C50) # C50, caret, ROCR Decision Tree 생성을 위해 호출
library(caret)
library(ROCR)
library(combinat) # 조합을 사용하기 위해 호출
library(gtools) # 순열을 사용하기 위해 호출
library(Epi) # 시각화 

#### Signature만들기 ####

user <- read.csv("2_group.csv", stringsAsFactors = T)
user_tree <- user[,c(1,2,37:length(user))]
# 0 : 무효 1 : 남성 2: 여
user_tree <- user_tree[user_tree$sex!=0,] #무효는 제외
user_tree$sex <- factor(user_tree$sex)

#명목형 변수 한글사용 시 Model이 생성되지 않는 점과 Factor화 
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

user_tree[user_tree$stay_out=="",]$stay_out <- "유지" # 해당사항이 안될 경우 유지로 판단.
user_tree$stay_out <- as.character(user_tree$stay_out)
user_tree[user_tree$stay_out=="이탈/휴면",]$stay_out <- "out"
user_tree[user_tree$stay_out=="유지",]$stay_out <- "stay"
user_tree$stay_out <- factor(user_tree$stay_out)

#선호 할부 개월에서 한글인 개월 삭제.
user_tree$fav_paymthd <- as.character(user_tree$fav_paymthd)
user_tree$fav_paymthd <- gsub(pattern = "개월",replacement = "",user_tree$fav_paymthd)
user_tree$fav_paymthd <- factor(user_tree$fav_paymthd)


# 한글 벡터를 포함하고 있는 데이터 항목들 전체 인덱스화 (우유 : 1, 치즈 : 2와 같은형태)
df <- data.frame(fav_part_index = 1:length(unique(user_tree$fav_part)), fav_part =unique(user_tree$fav_part))
user_tree <- join(user_tree,df,by="fav_part")
user_tree$fav_part_index <- factor(user_tree$fav_part_index)


df2 <- data.frame(fav_good_index = 1:length(unique(user_tree$fav_goodcd)), fav_goodcd =unique(user_tree$fav_goodcd))
user_tree <- join(user_tree,df2,by="fav_goodcd")
user_tree$fav_good_index <- factor(user_tree$fav_good_index)

#사용하면 안되는 항목 제거 
user_tree <- user_tree[,-c(12,13,22,26,31)]

# 6조 데이터 Join 
cust_6 <- read.csv("6custsig.csv", stringsAsFactors = F)
tmp_cust <- cust_6[,c("custid","PAPV","P_group","p_trend","instCnt","instMonth","instRatio")]
user_tree <- join(user_tree,tmp_cust,by="custid")

# 7:3 으로 Train / Test 데이터 생성.
set.seed(1)
inTrain <- createDataPartition(y=user_tree$sex,p=0.6,list=F)
user.train <- user_tree[inTrain,]
user.test <- user_tree[-inTrain,]
dim(user.test)
dim(user.train)

make <- function(train_data,test_data,str,detail,cnt,CF=0.25){
  df <- data.frame(Accur = integer(), Param = character(), Sub = character(), Cnt = integer())
  # 결과 출력을 위한 빈 DataFrame 데이터형에 맞춰서 생성.
  permn_str <- permn(str) # 입력받은 독립변수들을 순열로 생성
  sub_comb <-  permutations(2,3,detail,repeats=TRUE)  # T,F로 들어온 값을 2개 중 3번 선택, 중복 허용
  # 반복 횟수 가져오기 
  length_permn <- length(permn_str) # 순열의 크기
  length_sub <- NROW(sub_comb) # 생성된 Options의 크기
  length_count <- length(cnt) # trials의 크기.
  rows <- 0
  for(i in 1:length_permn){ 
    # 순열의 크기만큼 반복 (반복시키는 이유 - Winnowing=T에서 입력되는 독립변수 순서에 따라 사용률이 달라지고 모델도 달라짐)
    param <- paste(permn_str[[i]],collapse = "+") # 독립변수들끼리 +로 문자열 합치기 a + b + c
    for(j in 1:length_sub){ # Options만큼 반복.
      sub_1 <-  sub_comb[j,1] # Winnowing
      sub_2 <-  sub_comb[j,2] # noGlobalPruning 
      sub_3 <- sub_comb[j,3] # Trials
      c5_options <- C5.0Control(winnow = sub_1, noGlobalPruning = sub_2, CF = CF) # 옵션 생성 Default CF = 0.25
      for(k in 1:length_count){ # trials 횟수 만큼 반복
        rows <- rows + 1 
        params <- as.formula(gsub("\\\"","",paste("sex",param, sep=" ~ "))) # Formula 생성.
        if(cnt[k]>0){ # trials > 0 이상일때만 
          c5_model <- C5.0(params, data=train_data, control = c5_options, rules=sub_3, trials=cnt[k])
        }else{
          c5_model <- C5.0(params, data=train_data, control = c5_options, rules=sub_3)
        }
        # 정확도 확보를 위한 처리.
        test_data$c5_pred <- predict(c5_model,test_data,type="class")
        test_data$c5_pred_prob <- round(predict(c5_model,test_data,type="prob"),2)
        Accur <- confusionMatrix(test_data$c5_pred, test_data$sex)
        AccurResult <- Accur$overall[[1]] # 해당 모델의 정확도 확인.
        param_in <- deparse(params) # Formula 를 문자열 형태로 변환
        sub <- toString(sub_comb[j,]) # List에 있는 T,F 값들을 문자열 형태로 변환
        df2 <- data.frame(Accur = AccurResult, Param = param_in, Sub = sub, Cnt = cnt[k]) 
        # DataFrame에 동적으로 삽입하기 위해 DF생성
        df <- rbind(df,df2) #df에 합치기.
      }
    } 
    print(rows)
  }
  return(df) #모든 반복이후 결과값 출력 
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

# 자동화 (정확도 산출)
str <- c("pr_pref","sea_pref","API","amt12","instMonth","avg_disc","fav_part_index","fav_time","nop6","fav_good_index","buy_brd","main_store")
# Sex ~ 독립변수 값 들에 할당 결과 : sex ~ fav_time + buy_brd + avg_disc + amt12 의 formula로 변환
sub <- c(T,F) # T,F의 값들 중 3개를 선택하여 표시 TTT,TFT 등등.
count <- c(seq(0,40,10)) # trials = 0 ~ 40 Step 10 형태로 입력.
train_data <- user.train[,-1] # Training Data
test_data <- user.test        # Testing Data
result <- make2(user.train[,-1],user.test,str,sub,count)  # 함수적용. 


# 결과 적용 및 검증을 위한 절차 
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(sex ~ pr_pref + sea_pref + API + amt12 + instMonth + avg_disc + 
                   fav_part_index + fav_time + nop6 + fav_good_index + buy_brd + 
                   main_store, data=train_data, control = c5_options, rules=T, trials=20)
test_data$c5_pred <- predict(c5_model,test_data,type="class")
test_data$c5_pred_prob <- round(predict(c5_model,test_data,type="prob"),2)
confusionMatrix(test_data$c5_pred, test_data$sex)


c5_pred <- prediction(test_data$c5_pred_prob[,2], test_data$sex)
c5_model.perf1 <- performance(c5_pred,"tpr","fpr") # Roc curve
c5_model.perf2 <- performance(c5_pred,"lift","rpp") # Lift chart
par(mfrow=c(1,1))
plot(c5_model.perf1,colorize=T, xlab="ROC Curve")
plot(c5_model.perf2,colorize=T, xlab="Lift Chart")

performance(c5_pred,"auc")@y.values[[1]] 


ROC(form=test_data$sex~c5_pred_prob[,2], data=test_data, plot="ROC")
