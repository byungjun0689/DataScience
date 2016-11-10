##### 1. Neural Network Analysis using nnet package

install.packages("nnet")   # 시각화에 부족 
install.packages("devtools")
install.packages("NeuralNetTools")   
install.packages("neuralnet")
# garson을 사용해야 어떤 변수가 의미 있는지 / 모델에 최적화 되어 있는지 나옴

library(nnet); library(caret); library(ROCR)

cb <- read.delim("../1022_Decision Tree_2//Hshopping.txt", stringsAsFactors=FALSE)
cb$반품여부 <- factor(cb$반품여부)	# 명목형 값 예측일 경우

# C5.0은 명목형만 예측 가능
# Neural Network은 모두 가능하나, 추가 기능을 위해서는 바꿔두자!

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]
nrow(cb.train)
nrow(cb)

set.seed(123)
nn_model <- nnet(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, size=3, maxit=1000)	# size=hidden node수 
nn_model

nn_model2 <- nnet(반품여부 ~ 성별+나이+구매금액+출연자, data=cb.train, size=3, maxit=1000, decay=0.0005)	# size=hidden node수 
nn_model2
# decay 값 : learing rate를 조절할 수 있는 변수. 
# i가 input값이다. 
# b : bias (세타 값 : 시그모이드 함수의 임계)
# rang 옵션 : weight의 값들의 범위를 지정해 줄 수 있다. 

# size: # of hidden nodes
#     늘리면 모델이 복잡해 진다 (학습모델 성능은 올라가나, Overfitting issue 발생)
# maxit: 300명을 1,000번 반복한다 (어느 정도 수렴되면 중간에 멈출 수도 있다)
summary(nn_model)
# 맨 앞줄의 b->h_i들의 값들이 시그모이드 임계 (세타)
# h1의 weight는 26.33
# 2번째 입력층에서 ~까지의 weight는... 
# 선 12개 from 4개 변수 to 3개 노드 + 3개 노드 to 결과치 1개 노드 + bias 4개 = 19 weight

confusionMatrix(predict(nn_model, newdata=cb.test, type="class"), cb.test$반품여부)
confusionMatrix(predict(nn_model2, newdata=cb.test, type="class"), cb.test$반품여부)

library(devtools)
source_url('https://gist.githubusercontent.com/Peque/41a9e20d6687f2f3108d/raw/85e14f3a292e126f1454864427e3a189c2fe33f3/nnet_plot_update.r') 
plot.nnet(nn_model)
plot.nnet(nn_model2)
# 선의 굵기에 따라서 중요도? 해당 output에 영향이 많이 가는 정도를 표현해준다.
# nnet을 돌릴때마다 달라지고 해당 traing data set에 따라서 달라진다. 


library(NeuralNetTools)
garson(nn_model)   # by 변수 중요도 순서
# Nnet은 모델을 다 보더라도, weight를 계산하더라도, 이 변수의 의미를 보기에는 부족하다
# 모델 전체의 의미로만 참고용으로 봐야 한다 
# whitebox model = 의사결정나무
# blackbox model = neural network 


confusionMatrix(predict(nn_model, newdata=cb.test, type="class"), cb.test$반품여부)
# predict만 넣으면, 예측 확율이 나오고 class라고 넣었으니 실제 predict rate이 나온다
# 같은 predict여도, C5.0 or Neural에 따라 결과값이 달라진다

nn_pred <- ROCR::prediction(predict(nn_model, 
                                    newdata=cb.test, type="raw"), cb.test$반품여부)
# 각 패키지 각자에게 prediction이 다 다른 함수로 들어가 있다
# 그래서 ROCR 내에서의 prediction을 돌리라는 의미로 ROCR::prediction
# neural network의 실제값으로 뽑아라: type"raw"
par(mfrow=c(1,2))
nn_model.perf1 <- performance(nn_pred, "tpr", "fpr") # ROC-chart
nn_model.perf2 <- performance(nn_pred, "lift", "rpp") # Lift chart
plot(nn_model.perf1, colorize=TRUE); plot(nn_model.perf2, colorize=TRUE)

# decay: data 최적화를 시키려다 보니, weight가 너무 커지는 노드가 발생할 수 있음
#        다른 data로 적용 시, 정확도 이슈 발생
#        Error 함수 as E(w) : weight가 커지면 Error가 커진다 
#        람다 as decay값 (커질수록 w가 커지는 것을 방지한다)



##### 2. Neural Network Analysis using neuralnet package
library(neuralnet)
cb <- read.delim("Hshopping.txt", stringsAsFactors=FALSE)
# neuralnet 패키지는 목표변수가 numeric이어야 함.
# 시각화가 별로, compute로 예측 (not predict), gwplot as 종속변수의 의미도 추론 가능

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]

set.seed(123)
nn2_model <- neuralnet(반품여부 ~ 성별+나이+구매금액+출연자, 
                           data=cb.train, hidden=3, threshold=0.01)
nn2_model2 <- neuralnet(반품여부 ~ 성별+나이+구매금액+출연자, 
                           data=cb.train, hidden=c(2,3), threshold=0.01)
# error change가 0.01보다 작아지면 stop하라는 의미 (threshold)
# hidden=c(2,2) 첫번째 layer node2  두번째 layer node 2개 
# hidden=c(2,3) 첫번째 layer node2  두번째 layer node 3개 
# nnet 패키지보다 parameter가 많다 (threshold나 stepmax 둘 중 하나를 주로 사용한다,
#                                   굳이 둘다 쓸 필요가 없기 때문)
# linear.output:T = 출력층에는 굳이 log상용화 하지 않고 weight sum한다
#                             (sigmoid 함수 적용X)
plot(nn2_model)
plot(nn2_model2)
# nnet에 비해서의 장점

par(mfrow=c(2,2))
gwplot(nn2_model, selected.covariate = "성별", min=-3, max=6)
gwplot(nn2_model, selected.covariate = "나이", min=-3, max=6)
gwplot(nn2_model, selected.covariate = "구매금액", min=-3, max=6)
gwplot(nn2_model, selected.covariate = "출연자", min=-3, max=6)
# 성별 as 1,0 only / 구매금액은 3단계 / 출연자 as binary / 나이 as 연속형
# 성별에 비해 나이는 어느 나이든 간에 weight가 거의 동일하다 : 큰 의미 없음
# 나이는 output 변수에 영향이 없다 
# 위아래로 많이 퍼져있는 변수의 경우, 의미를 가진다고 보면 된다 

par(mfrow=c(1,1))
cb.test$nn2_pred_prob <- compute(nn2_model, covariate=cb.test[, c(2:5)])$net.result
# pred이 아닌 compute
# 예측확률을 위해서는 $net.result를 추가한다 for result 출력 only
# 이 패키지만 예측할 때 쓰는 변수만 골라다가 지정해야 한다 (알아서 걸러내서 변수 지정 X)
#             covariate=cb.test[,c(2:5)]
# ID / 성별 / 나이 / 구매금액 / 출연자 / 반품여부

cb.test$nn2_pred <- ifelse(cb.test$nn2_pred_prob > 0.5, 1, 0)
# 다른 test에 비해 matrix로 연결해 주어야 한다 
# 예측값이 0.5보다 크면 1이고 작으면 0이다

confusionMatrix(cb.test$nn2_pred, cb.test$반품여부)
nn2_pred <- ROCR::prediction(cb.test$nn2_pred_prob, cb.test$반품여부)
par(mfrow=c(1,2))

nn2_model.perf1 <- performance(nn2_pred, "tpr", "fpr") # ROC-chart
nn2_model.perf2 <- performance(nn2_pred, "lift", "rpp") # Lift chart
plot(nn2_model.perf1, colorize=TRUE); plot(nn2_model.perf2, colorize=TRUE)
par(mfrow=c(1,1))


##### 3. Multinomial Classification using neuralnet
# Neural net은 classification도 가능하다. 

data(iris)
# 예측값이 3개 이상인 경우 (Y에 명목형 변수가 3개 이상인 경우)

formula <- as.formula(paste('Species ~', 
                            paste(names(iris)[-length(iris)], collapse='+')))		
# neuralnet does not support the '.' notation in the formula. (like nnet does)
# formula 생성
m2 <- neuralnet(formula, iris, hidden=3, linear.output=FALSE)
# fails-! error cuz factor type for iris 
# neural은 factor 데이터 equals to error

# 범주별로 출력노드를 하나씩 만들고 (setosa/versicolor/virginica)
# 모델 출력시, 하나하나에 대해서 1 or 0이 뜨도록 모델별로 만든다

trainData <- cbind(iris[, 1:4], class.ind(iris$Species)) # 다중 Class 분
head(trainData) # field 3개 추가됨 / setosa as 1, 나머지 as 0
View(trainData)
unique(trainData$setosa)

m2 <- neuralnet(setosa + versicolor + virginica ~ Sepal.Length 
                + Sepal.Width + Petal.Length + Petal.Width, trainData, hidden=3) # 이또한 이진 분리로 나누어 진다. 
plot(m2)
compute(m2, iris[, 1:4])$net.result # 확률로 표현.


##### 4. Input Normalization in Neural Networks
##### Normalization -> scaling 해준 것.

normalize <- function (x) {
  normalized = (x - min(x)) / (max(x) - min(x))
  return(normalized)
}
# data는 scale이 큰 쪽으로 영향을 받을 수 밖에 없다, normalization 필요!

cb <- read.delim("Hshopping.txt", stringsAsFactors=FALSE)

cb$나이 <- normalize(cb$나이)
cb$구매금액 <- normalize(cb$구매금액)

set.seed(1)
inTrain <- createDataPartition(y=cb$반품여부, p=0.6, list=FALSE)
cb.train <- cb[inTrain,]
cb.test <- cb[-inTrain,]

set.seed(123)
nn3_model <- neuralnet(반품여부 ~ 성별+나이+구매금액+출연자, 
                           data=cb.train, hidden=3, threshold=0.01)

par(mfrow=c(2,2))
gwplot(nn3_model, selected.covariate = "성별", min=-3, max=6)
gwplot(nn3_model, selected.covariate = "나이", min=-3, max=6)
gwplot(nn3_model, selected.covariate = "구매금액", min=-3, max=6)
gwplot(nn3_model, selected.covariate = "출연자", min=-3, max=6)
par(mfrow=c(1,1))

garson(nn3_model)
# 어라 나이 의미가 많아졌네?

cb.test$nn3_pred_prob <- compute(nn3_model, covariate=cb.test[, c(2:5)])$net.result
cb.test$nn3_pred <- ifelse(cb.test$nn3_pred_prob > 0.5, 1, 0)

confusionMatrix(cb.test$nn3_pred, cb.test$반품여부)


##### 5. Model Comparison

nn3_pred <- ROCR::prediction(cb.test$nn3_pred_prob, cb.test$반품여부)
nn3_model.perf1 <- performance(nn3_pred, "tpr", "fpr") # ROC-chart

par(mfrow=c(1,1))
plot(nn_model.perf1, col="red")
plot(nn2_model.perf1, col="green", add=T)
plot(nn3_model.perf1, col="blue", add=T)
legend(0.6,0.7,c("N1","N2","N3"),cex=0.9,col=c("red","green","blue"),lty=1)

performance(nn_pred, "auc")@y.values[[1]] 
performance(nn2_pred, "auc")@y.values[[1]]
performance(nn3_pred, "auc")@y.values[[1]] 
# AUC = ROC curve의 넓