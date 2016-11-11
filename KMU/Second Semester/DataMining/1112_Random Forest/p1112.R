##### 1. Random Forest

install.packages("randomForest")
library(randomForest)
library(caret)
library(ROCR)

cb <- read.delim("Hshopping.txt", stringsAsFactors=FALSE)
cb$반품여부 <- factor(cb$반품여부)

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]

set.seed(123)
rf_model <- randomForest(반품여부 ~ .-ID, data=cb.train, ntree=50, mtry=2)
rf_model

plot(rf_model, main="random Forest model")

importance(rf_model)
varImpPlot(rf_model)

cb.test$rf_pred <- predict(rf_model, cb.test, type="response")
confusionMatrix(cb.test$rf_pred, cb.test$반품여부)

cb.test$rf_pred_prob <- predict(rf_model, cb.test, type="prob")
rf_pred <- prediction(cb.test$rf_pred_prob[,2],cb.test$반품여부)
rf_model.perf1 <- performance(rf_pred, "tpr", "fpr") # ROC-chart
rf_model.perf2 <- performance(rf_pred, "lift", "rpp") 
plot(rf_model.perf1, colorize=TRUE); abline(a=0, b=1, lty=3)
plot(rf_model.perf2, colorize=TRUE); abline(v=0.4, lty=3)
performance(rf_pred, "auc")@y.values[[1]] 


##### 2. Support Vector Machine (SVM)

install.packages("e1071")
library(e1071)

svm_model <- svm(반품여부~성별+나이+구매금액+출연자, data=cb.train, cost=100, gamma=1, probability = TRUE)
summary(svm_model)
plot(svm_model, data=cb.train, 구매금액~나이)

cb.test$svm_pred <- predict(svm_model, cb.test)
confusionMatrix(cb.test$rf_pred, cb.test$반품여부)
postResample(cb.test$svm_pred, cb.test$반품여부)

cb.test$svm_pred_prob <- attr(predict(svm_model, cb.test, probability = TRUE), "probabilities")[,2]
svm_pred <- prediction(cb.test$svm_pred_prob, cb.test$반품여부)
svm_model.perf1 <- performance(svm_pred, "tpr", "fpr") # ROC-chart
svm_model.perf2 <- performance(svm_pred, "lift", "rpp") 
plot(svm_model.perf1, colorize=TRUE); abline(a=0, b=1, lty=3)
plot(svm_model.perf2, colorize=TRUE); abline(v=0.4, lty=3)
performance(svm_pred, "auc")@y.values[[1]]

# the best values to use for the parameters gamma and cost
set.seed(123)
tune.svm(반품여부~성별+나이+구매금액+출연자, data=cb.train, gamma=seq(.5, .9, by=.1), cost=seq(100,1000, by=100))


##### 3. Cross Validation

# Create a 5-fold partition using the caret package
set.seed(1)
flds <- createFolds(cb$반품여부, k=5, list=TRUE, returnTrain=FALSE)
str(flds)

# Perform 5 experiments
experiment <- function(train, test, m) {
  rf <- randomForest(반품여부 ~ .-ID, data=train, ntree=50)
  rf_pred <- predict(rf, test, type="response")
  m$acc = c(m$acc, confusionMatrix(rf_pred, test$반품여부)$overall[1])
  rf_pred_prob <- predict(rf, test, type="prob")
  rf_pred <- prediction(rf_pred_prob[,2], cb.test$반품여부)
  m$auc = c(m$auc, performance(rf_pred, "auc")@y.values[[1]])
  return(m) 
}

measure = list()
for(i in 1:5){
  inTest <- flds[[i]]
  cb.test <- cb[inTest, ]
  cb.train <- cb[-inTest, ]
  measure = experiment(cb.train, cb.test, measure) 
}

measure 
mean(measure$acc); sd(measure$acc)
mean(measure$auc); sd(measure$auc)