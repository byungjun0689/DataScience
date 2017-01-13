#### SVM(Support Vector Machine) ####
# Using e1071 packages

install.packages("e1071")
library(e1071)

cb <- read.delim("../1022_Decision Tree_2//Hshopping.txt", stringsAsFactors=FALSE)
cb$반품여부 <- factor(cb$반품여부)

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]
nrow(cb.train)
nrow(cb)

svm_model <- svm(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, cost=100, gamma=1, probability = T)
# cost = cost of constraints violation (default: 1)
# it is the ‘C’-constant of the regularization term in the Lagrange formulation.

summary(svm_model)

plot(svm_model, data=cb.train, 구매금액~나이)


# 나머지는 PDF볼것 ####
