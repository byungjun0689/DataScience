data(UScereal, package="MASS")
train_idx <- sample(NROW(UScereal)/2)
m <- lm(calories ~ protein + fat + sugars , data = UScereal[train_idx,-1])
predict(m , newdata = UScereal[-train_idx,-1]) -> pred

pred - UScereal[-train_idx,"calories"] -> error
error
mean(abs(error)) 

data(pima, package="faraway")
pima$test <- factor(pima$test)
train_idx <- sample(NROW(pima)/2)
m <- glm(test ~ pregnant + glucose + bmi, family=binomial, data=pima[train_idx,])
as.integer(predict(m , newdata = pima[-train_idx,] , type = "response") > 0.5) -> pred
actual <- pima[-train_idx,"test"]
xtabs(~ pred + actual) 

library(caret) 
confusionMatrix(pred , actual) 

#ROCíƮ 
library(ROCR) 
pred_prob <- predict(m , newdata = pima[-train_idx,] , type = "response")
labels <- pima[-train_idx,"test"]
pred3 <- prediction(pred_prob , labels)
plot(performance(pred3 , "tpr" , "fpr"))

performance(pred3 , "auc")
 
par(mfrow=c(1,2))
## precision/recall curve (x-axis: recall, y-axis: precision)
perf1 <- performance(pred3, "prec", "rec")
plot(perf1)

## sensitivity/specificity curve (x-axis: specificity, y-axis: sensitivity)
perf2 <- performance(pred3, "sens", "spec")
plot(perf2)

#K-fold Cross Validation
library(cvTools)
data_idx <- cvFolds(NROW(pima) , K=10 , R=3 , type = "random") 
data_idx 

aucs <- c() 
library(foreach) 
foreach(r=1:3) %do% { 
  foreach(k=1:10 , .combine = c) %do% { 
    test_idx <- data_idx$subsets[which(data_idx$which == k) , r] 
    train <- pima[-test_idx , ]
    test <- pima[test_idx , ]
    
    m <- glm(test ~ pregnant + glucose + bmi, family=binomial, data=train) 
    pred_prob <- predict(m , newdata = test , type = "response")
    labels <- pima[test_idx,"test"]
    pred3 <- prediction(pred_prob , labels)
    
    auc <- attributes(performance(pred3 , "auc"))$y.values[[1]]
    aucs <- c(aucs , auc) 
    
    }
  }
aucs
mean(aucs) 

#K-fold validation 1(TRAIN) 
library(caret)
data_idx <- createDataPartition(pima$test , p=0.7 , times = 3)

#K-fold validation 2(TEST)
data_idx <- createFolds(pima$test , k=10)

#K-fold validation 3(TRAIN)
data_idx <- createMultiFolds(pima$test , k=10 , times=3)

#Class Imbalance
table(pima$test)
library(caret) 
data.up <- upSample(pima[-9] , pima$test) 
table(data.up$Class) 

