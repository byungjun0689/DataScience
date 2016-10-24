install.packages("C50")
install.packages("caret")
install.packages("ROCR")

library(C50)
library(caret)
library(ROCR)

cb <- read.delim("Hshopping.txt",stringsAsFactors = F)
cb$반품여부 <- as.factor(cb$반품여부)


# train / test data split

set.seed(1) # seed를 고정해야 동일한 샘플링을 가질 수 있다. 
inTrain <- createDataPartition(y=cb$반품여부,p=0.6,list=F)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]

# C5.0의 함수 파라미터를 생성하는 함수 C5.0Control
c5_options <- C5.0Control(winnow = F, noGlobalPruning = F)
c5_model <- C5.0(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, control = c5_options, rules=F)
summary(c5_model) 
# size : 트리의 깊이 
# 8.0%가 틀리고 92%를 맞췄다. 
# (a)   (b)    <-classified as
# ----  ----
#   194    13    (a): class 0
# 11    83    (b): class 1  
# 대각선 194, 83이 맞춘 것이다. 


plot(c5_model)

c5_model_2 <- C5.0(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, control = c5_options, rules=T)
summary(c5_model_2)

c5_model_3 <- C5.0(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, control = c5_options, rules=T, trials = 10)


# CF=0.7 가지치기 정도를 낮춘다. Strict 숫자가 높을 수록 정도를 낮춘다. 
# Strict 할수록 해당 데이터에 대해서 잘 fitting되지만 다른 데이터에는 좋지 않을 수도있다. 
c5_options_2 <- C5.0Control(winnow = F, noGlobalPruning = F, CF=0.7)
c5_model_4 <- C5.0(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, control = c5_options_2, rules=F)


# Global Pruning 전역적 가지치기.
# 지역적 가지치기는 부모와 자식간의 가지치기 ( 개별 각각으로)
# 전체 나무 모양을 보고 트리의 깊이가 있어도 해당 부분을 칠수도있다. 


# 예측 및 평가 

cb.test$c5_pred <- predict(c5_model,cb.test,type="class")
cb.test$c5_pred_prob <- round(predict(c5_model,cb.test,type="prob"),2)

# 정확도 확인
confusionMatrix(cb.test$c5_pred, cb.test$반품여부)


# 시각적으로 보기 위해서 
c5_pred <- prediction(cb.test$c5_pred_prob[,2], cb.test$반품여부)
c5_model.perf1 <- performance(c5_pred,"tpr","fpr") # Roc curve
c5_model.perf2 <- performance(c5_pred,"lift","rpp") # Lift chart
par(mfrow=c(1,2))
plot(c5_model.perf1,colorize=T)
plot(c5_model.perf2,colorize=T)

performance(c5_pred,"auc")@y.values[[1]] # 커브 아래의 면적  면적이 높을 수록 좋은 모형이 된다. roccurve에서 
#lift chart는 급격하게 떨어지면 좋은 모형이다. 

# 괜찮은 그래프 그리기 
install.packages("Epi")
library(Epi)
ROC(form=cb.test$반품여부~c5_pred_prob[,2],)


library(psych)
pairs.panels(cb)
