# raddom forest ####

install.packages("randomForest")
library(randomForest)
library(caret)
library(ROCR)

cb <- read.delim("../1022_Decision Tree_2/Hshopping.txt", stringsAsFactors=FALSE)
cb$반품여부 <- factor(cb$반품여부)

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]
nrow(cb.train)
nrow(cb)

set.seed(123)
rf_model <- randomForest(반품여부 ~. -ID, data=cb.train, ntree = 50, mtry=2)
rf_model

# OOB estimate of  error rate: 9.63% -> 50개 트리 오류의 평균
plot(rf_model) # 초록 :worst , 검정 : overall, 붉은 : best

importance(rf_model) #중요도 퍼센트로 표현.

varImpPlot(rf_model)
# 엔트로피 값은 경우 엔트로피 값이 높으면 불순 낮으면 순수 
# Gini 도 엔트로피가 동일하다.
# Gini값이 높을 수록 영향도가 높다. 

cb.test$rf_pred <- predict(rf_model, cb.test, type="response")
confusionMatrix(cb.test$rf_pred, cb.test$반품여부)


# 그림은 PDF보고 그려보기 11pages ####
