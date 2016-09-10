# Data Preparation

setwd("d:/DataScience/KMU/Second Semester/DataMining/0910/")

train <- read.csv("pepTrainSet.csv", stringsAsFactors=F)
train <- subset(train, select=-c(id))
test <- read.csv("pepTestSet.csv", stringsAsFactors=F)
newd <- read.csv("pepNewCustomers.csv", stringsAsFactors=F)
str(train)

train$pep <- factor(train$pep)
test$pep <- factor(test$pep)


# Modeling

#install.packages("caret",repos = "http://cran.us.r-project.org") #데이너 전처리 / 모델
#install.packages("ROCR",repos = "http://cran.us.r-project.org") # 모형의 그래프 생성과 평가
#install.packages("C50",repos = "http://cran.us.r-project.org") # 분류 분석, 의사결정나무 (Decision Tree)

library(caret)
library(ROCR)
library(C50)

?C5.0Control

# Various parameters that control aspects of the C5.0 fit.
c5_options <- C5.0Control(winnow = FALSE, noGlobalPruning = FALSE)
c5_model <- C5.0(pep ~ ., data=train, control=c5_options, rules=FALSE)
summary(c5_model)
plot(c5_model)

lm_model <- glm(pep ~ ., data=train, family = binomial)
summary(lm_model)


# Evaluation
install.packages("e1071")
library(e1071)
test$c5_pred <- predict(c5_model, test, type="class")
test$c5_pred_prob <- predict(c5_model, test, type="prob")
confusionMatrix(test$c5_pred, test$pep) # .No, .Yes생성하는

head(test)
#pred.prob.No -> NO 의 확률 
#pred.prob.Yes -> Yes의 확률 

test$lm_pred <- ifelse(predict(lm_model, test, type="response") > 0.5, "YES", "NO")
test$lm_pred_prob <- predict(lm_model, test, type="response")
confusionMatrix(test$lm_pred, test$pep)

c5_pred <- prediction(test$c5_pred_prob[, "YES"], test$pep)
c5_model.perf <- performance(c5_pred, "tpr", "fpr")

lm_pred <- prediction(test$lm_pred_prob, test$pep)
lm_model.perf <- performance(lm_pred, "tpr", "fpr")

plot(c5_model.perf, col="red")
plot(lm_model.perf, col="blue", add=T)
legend(0.7, 0.7, c("C5","LM"), cex=0.9, col=c("red", "blue"), lty=1)


# Deployment

newd$c5_pred <- predict(c5_model, newd, type="class")
newd$c5_pred_prob <- predict(c5_model, newd, type="prob")
target <- subset(newd, c5_pred=="YES" & c5_pred_prob[ ,"YES"] > 0.8)
write.csv(target[order(target$c5_pred_prob[,"YES"], decreasing=T), ], "dm_target.csv", row.names=FALSE)
