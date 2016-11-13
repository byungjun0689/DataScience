##### 1. Neural Network Analysis using nnet package

# nnet, devtools, NeuralNetTools  활용 
# nnet은 시각화 안됨 devtools를 이용해 시각화 한다. 

install.packages("nnet") # 자기가 만든 모델을 시각화 할 수 없다.
library(nnet); library(caret); library(ROCR)

cb <- read.delim("Hshopping.txt", stringsAsFactors=FALSE)
cb$반품여부 <- factor(cb$반품여부)	# 명목형 값 예측일 경우

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]

set.seed(123)
nn_model <- nnet(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, size=3, maxit=1000)	# size: # of hidden nodes

summary(nn_model)

install.packages("devtools")
library(devtools)

source_url('https://gist.githubusercontent.com/Peque/41a9e20d6687f2f3108d/raw/85e14f3a292e126f1454864427e3a189c2fe33f3/nnet_plot_update.r') 
plot.nnet(nn_model)

install.packages("NeuralNetTools")
library(NeuralNetTools)

garson(nn_model)

confusionMatrix(predict(nn_model, newdata=cb.test, type="class"), cb.test$반품여부)
predict(nn_model, newdata=cb.test, type="class")

nn_pred <- ROCR::prediction(predict(nn_model, newdata=cb.test, type="raw"), cb.test$반품여부)
nn_model.perf1 <- performance(nn_pred, "tpr", "fpr") # ROC-chart
nn_model.perf2 <- performance(nn_pred, "lift", "rpp") # Lift chart
plot(nn_model.perf1, colorize=TRUE); plot(nn_model.perf2, colorize=TRUE)


##### 2. Neural Network Analysis using neuralnet package

install.packages("neuralnet")
library(neuralnet)

cb <- read.delim("Hshopping.txt", stringsAsFactors=FALSE)
# neuralnet 패키지는 목표변수가 numeric이어야 함.

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]

set.seed(123)
nn2_model <- neuralnet(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, hidden=3, threshold=0.01)

plot(nn2_model)

par(mfrow=c(2,2))
gwplot(nn2_model, selected.covariate = "성별", min=-3, max=6)
gwplot(nn2_model, selected.covariate = "나이", min=-3, max=6)
gwplot(nn2_model, selected.covariate = "구매금액", min=-3,max=6)
gwplot(nn2_model, selected.covariate = "출연자", min=-3,max=6)
par(mfrow=c(1,1))

cb.test$nn2_pred_prob <- compute(nn2_model, covariate=cb.test[, c(2:5)])$net.result
cb.test$nn2_pred <- ifelse(cb.test$nn2_pred_prob > 0.5, 1, 0)

confusionMatrix(cb.test$nn2_pred, cb.test$반품여부)

nn2_pred <- ROCR::prediction(cb.test$nn2_pred_prob, cb.test$반품여부)

nn2_model.perf1 <- performance(nn2_pred, "tpr", "fpr") # ROC-chart
nn2_model.perf2 <- performance(nn2_pred, "lift", "rpp") # Lift chart
plot(nn2_model.perf1, colorize=TRUE); plot(nn2_model.perf2, colorize=TRUE)


##### 3. Multinomial Classification using neuralnet

data(iris)
formula <- as.formula(paste('Species ~', paste(names(iris)[-length(iris)], collapse='+')))		
# neuralnet does not support the '.' notation in the formula.
m2 <- neuralnet(formula, iris, hidden=3, linear.output=FALSE)
# fails !

trainData <- cbind(iris[, 1:4], class.ind(iris$Species))
m2 <- neuralnet(setosa + versicolor + virginica ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, trainData, hidden=3)
plot(m2)
compute(m2, iris[, 1:4])$net.result

##### 4. Input Normalization in Neural Networks

normalize <- function (x) {
  normalized = (x - min(x)) / (max(x) - min(x))
  return(normalized)
}

cb <- read.delim("Hshopping.txt", stringsAsFactors=FALSE)

cb$나이 <- normalize(cb$나이)
cb$구매금액 <- normalize(cb$구매금액)

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]

set.seed(123)
nn3_model <- neuralnet(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, hidden=3, threshold=0.01)

par(mfrow=c(2,2))
gwplot(nn3_model, selected.covariate = "성별", min=-3, ,max=6)
gwplot(nn3_model, selected.covariate = "나이", min=-3, ,max=6)
gwplot(nn3_model, selected.covariate = "구매금액", min=-3, ,max=6)
gwplot(nn3_model, selected.covariate = "출연자", min=-3, ,max=6)
par(mfrow=c(1,1))

garson(nn3_model)

cb.test$nn3_pred_prob <- compute(nn3_model, covariate=cb.test[, c(2:5)])$net.result
cb.test$nn3_pred <- ifelse(cb.test$nn3_pred_prob > 0.5, 1, 0)

confusionMatrix(cb.test$nn3_pred, cb.test$반품여부)


##### 5. Model Comparison

nn3_pred <- ROCR::prediction(cb.test$nn3_pred_prob, cb.test$반품여부)
nn3_model.perf1 <- performance(nn3_pred, "tpr", "fpr") # ROC-chart

plot(nn_model.perf1, col="red")
plot(nn2_model.perf1, col="green", add=T)
plot(nn3_model.perf1, col="blue", add=T)
legend(0.6,0.7,c("N1","N2","N3"),cex=0.9,col=c("red","green","blue"),lty=1)

performance(nn_pred, "auc")@y.values[[1]]; performance(nn2_pred, "auc")@y.values[[1]]; performance(nn3_pred, "auc")@y.values[[1]] 