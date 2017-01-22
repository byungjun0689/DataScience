install.packages("caret")
library(caret) # sklearn과 비슷하나 sklearn이 더 좋다. 
library(tidyverse)
# 제일 큰 차이 : 홈페이지가 너무 구리다.... ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ

#데이터 준비 
df <- read_csv("automobile.csv")
df

#선형 회귀분석
# http://archive.ics.uci.edu/ml/   # 여기서 데이터를 가지고 올 수 있다. 

model <- lm(symboling ~ width, data=df)
summary(model)

ggplot(df, aes(width, symboling)) + geom_point() + geom_smooth(method='lm')


symboling.p <- predict(model,df)

# 선형회귀 생략 


# 통계 vs ML  
# 차이 : 통계는 해석이 필요하고 한데, ML은 맞추기만 하면된다.
# 통계는 해석 ML는 예측 해석은 다양하게 가능하지만 예측은 설명이 불가능하다. 왜 이렇게 된다정도만 되지 정확히 표혀닝 불가  
# 조절(Moderation) :
# - overfitting, Underfitting 
# - 전체 데이터 중 일부를 짤라낸다. Split (Training : 70%, Test : 30%) -> Trianing 후 Test overfitting을 막을 수 있다.
# - 시기에 따라 데이터가 나타나 있다면 1~12월 : 1~10월까지만 Train하고 11~12 : Test 데이터로 활용. 
#   어떠한 특성을 가지는가. 시즈널리티 일경우 전체에서 나누는게 나음.

# Data partitioning 
index <- createDataPartition(y = df$symboling, p=0.6, times = 1, list = F)
index

train <- df[index,]
test <- df[-index,]

dim(train)
dim(test)

model <- lm(symboling~width+length+engine_size, train)
mean((train$symboling-predict(model,train))^2)
mean((test$symboling-predict(model,test))^2)

# 변수선택
# 머신러닝 할 수 없는 변수 : Example(너무 적은 카테고리 수동으로 제거 )
colnames(df)
features = c("symboling", "fuel", "aspiration", "doors", "body", "wheels", "wheel_base",
             "length", "width", "height", "curb_weight", "engine_size",
             "bore", "stroke", "compression_ratio", "horsepower", "peak_rpm",
             "city_mpg", "highway_mpg", "price")

train = df[index, features]
test = df[-index, features]


# Hyper Parameter : 데이터를 조정하는 값이 아니라, 먼저 지정해야되는 Parameters  기준이 없다. CrossValidation
# Training Data 를 또 70 : 30 으로 Train / Test로 나눠서 반복해본다. Tuning Parameter를 이런식으로 잡는다. 
# Test와 하는 일은 비슷하나 목적이 다르다. 
# k-fold Cross Vaildation 
# 3-fold : 데이터를 3개로 나눈다 1,2 번으로 Training 3번으로 Vaildation, 1,3으로 Training 2번으로 vaildation 
# repeation을 할 수 있다. 또 랜덤하게 반복할 수 있엉. 
# Python에서는 GridSearchcv 가 동일한 역할.
# http://scikit-learn.org/stable/modules/grid_search.html#grid-search
# http://scikit-learn.org/stable/modules/generated/sklearn.model_selection.GridSearchCV.html#sklearn.model_selection.GridSearchCV

# Training Control
controlObject <- trainControl(
  method = 'repeatedcv',
  repeats = 1, #나누는 걸 몇번
  number = 5) # 5등분

# 11월 12일 파이썬 수업 
# LM의 정규화
# 미친듯이 널뛰는 선보다는 선형 모델 (직선) 이 좋다.
# 회귀 선도 평평하게 줄인다.
# |W| 의 최소화 : Lasso(L1)  |W|^2의 최소화 : Ridge(L2)
# Lasso : 회귀계수를 0으로 만드는 성향이 있다.
# 영화평에 대한 감정 분석 
# 어제 / 잼있다 / 귀신   => 어제 0.00001 계수가 있다 Lasso를 사용하게 되면 0으로 변한다. 
# 변수 선택의 기능이 있다.
# Ridge : 예측력이 조금 더 좋다. (항상 그런 것은 아니다.)

# 1. Elastic Net
# L1 + L2도 하자. 
# 튜닝파라미터 : 람다 - 정규화를 얼마나 강하게 할 것이냐? 높으면 정규화가 높다.  (모델이 단순하게) 적게 하면 예측률이 높아질듯.
#                알파 - L1,L2를 몇대 몇으로 할것이냐. 0~1, 알파 : 0 릿지만, 알파 : 1 라쏘만.
elst.Grid <- expand.grid(
  .alpha = seq(0, 1, 0.2),
  .lambda = c(0.001, 0.01, 0.1))

# 모든 벡터의 경우의 수를 만든다.
elst.Grid

# train : Carat 의 function 
install.packages("glmnet")
library(glmnet)
elst.Model <- train(
  symboling ~ ., 
  data = train, 
  method = 'glmnet',
  tuneGrid = elst.Grid, # 만든 파라미터.
  preProc = c('center', 'scale'), # 무조건 넣는다고 생각하면된다. 
  metric = 'RMSE', #예측문제라 RMSE를 최적화
  trControl = controlObject) #CrossValidation을 어떻게 할 것인가. 

#RMSE가 작은걸 고르면 된다. 

best = as.numeric(rownames(elst.Model$bestTune))
best

elst.Model$finalModel$beta[,best] # 베스트의 회귀계
y = predict(elst.Model, test, na.action = na.pass)

mean((test$symboling - y)^2, na.rm = T)

# K-Nearset Neightbors 
# KNN -> 친구를 보면 그사람을 안다 라는 발상
# 새로운 데이터의 가장 가까운 데이터를 보고 판단한다. k < 갯수. 즉, 친구를 여러명 본다. k=3 이면 3개의 친구를 본다
# 데이터 적을 때 k를 키우면 도우미 안된다. 하지만 데이터가 많아도 재앙이다. 비용이 많이든다. 100만건에서 10개를 검색하는데 시간이 많이 걸린다. 
# 예측하는데 시간이 많이 걸린다. 트레이닝 할때는 시간이 얼마 안걸리는데, 테스트할때 많이 걸린다. 
# 추천시스템에서 KNN 많이 쓴다. 

# 가정 : 비슷한 애들끼리 모여있다. 하지만 모형확인부터 해야된다. 
# 막 섞여있다. 하면 KNN을 하기 어렵다. But 다른 모델도 마찬가지다. 
# 주변의 값의 평균으로 한다. k=3 이면 3개의 평균. 
# 비슷하다는 것은 어떻게 할 것이냐? 예) 변수가 3개다. 가격(0~10,000,000) / 크기 (0~10) 어느것이 가까우냐 판단하기 어렵다.
## 변수가 달라지면 판단이 어렵다. center와 scale  연속변수면 이렇게 하면 되는데.
## 이산변수면 더 골아프다. => 유사성을 본인이 정의. 예를들어 svm 커널처럼 비슷한거 갯수를 Count 
## 또는 재정의 : 현대차 / 토요타 / 마세라티 연속적인 수치로 변환.  다른지표로 변환 평균 가격 과같은 숫자로 
# 회사의 데이터는 대부분이 이산변수이다.... 

knn.Model <- train(
  symboling ~ ., 
  data = train,
  method = 'knn',
  preProc = c('center', 'scale'),
  metric = 'RMSE',
  tuneGrid = data.frame(.k = 2:5), # 2~5개 k 개 
  trControl = controlObject)

knn.Model
test.c = test[complete.cases(test),]
y = predict(knn.Model, test.c)
mean((test.c$symboling - y)^2, na.rm = T)

# SVM
# LM은 오차를 줄이는데 목적이 있다
# SVM은 좋은 형태를 찾는데 목적이 있다. 
# Classification : 무수히 많은 경계선을 그을 수가 있다. Large Margin Classifier 의 일종이다.(SVM)
# Regression : 가장 평평한 선을 찾는다 (일정범위내에서)
# 예외케이스에서는 Penalty를 먹인다. 
# Kernal Trick (SVM 수업참고.)
# example : 이산변수 -> 유사성으로 변경 


install.packages("kernlab") #  rbf 를 사용할때 Sigma를 추천해주는것.
library(kernlab)

sigmaRange <- sigest(as.matrix(train[8:20])) # sigma range를 추천해준다. 연속인 값에 넣어준다. 
svm.Grid <- expand.grid(
  .sigma = sigmaRange[1],
  .C = 2^(seq(-5,5,2)))

svm.Model <- train(
  symboling ~ .,
  data = train,
  method = 'svmRadial', # svm with rbf
  tuneGrid = svm.Grid,
  preProc = c('center', 'scale'),
  metric = 'RMSE',    
  trControl = controlObject)

y = predict(svm.Model, test)
mean((test.c$symboling - y)^2)

# Nueral Net
# 별로 좋지가 않아 사용하지 않기를 권한다. 
# DeepLearning과 동일하다 생각하면된다. 
# Perceptron = Logistic Regression


nnet.Grid <- expand.grid(
  .decay = c(0.001, 0.01, 0.1), # LM의 ridge와 동일하다. 람다를 키우를거랑 비슷하다. 정규화를 얼마나 할 것이냐.
  .size = seq(3,11, by = 2), # hidden Layer 크기 노드의 수 
  .bag = FALSE) # bagging 모델을 여러개 만들어서 각각 다른 데이터를 줘서 평균 내는 방식. 

nnet.Model <- train(
  symboling ~ .,
  data = train,
  method = 'avNNet',
  tuneGrid = nnet.Grid,
  preProc = c('center', 'scale'),
  maxit = 200, # 밑바닥에 들어가서 error가 주는것인지 아닌지 알수가 없다. 한참걸린다. local minimun 최대 200 Step을 내려가고 Stop
  trControl = controlObject
  ,trace = F)

y = predict(nnet.Model, test)
mean((test.c$symboling - y)^2)

# Decision Tree

rpart.Model <- train(
  symboling ~ ., 
  data = train,
  method = 'rpart',
  tuneLength = 10,
  trControl = controlObject)

rpart.Model
y = predict(rpart.Model, test)
mean((test.c$symboling - y)^2)


# RandomForest 
# bagging을 적용  python 수업시간 내용을 본다. 
# feature importance 를 사용해서 설명이 가능하다. 

rf.Grid <- expand.grid(.mtry = c(4,6,8,10)) # 컬럼수를 결정 총 length 만큼 반복하는데 각 순서대로 컬럼수를 가지고 한다. 
rf.Model <- train(
  symboling  ~.,
  data = train,
  method = 'rf',
  tuneGrid = rf.Grid,
  ntrees = 10, # 트리 수 
  importance = T,
  trControl = controlObject)

y = predict(rf.Model, test)
mean((test.c$symboling - y)^2)

# Gradient Boosting Tree
# Y = Y^hat + E 실제 = 예측 + 오차 
# 실제 = 예측1 + 오차1 
# 오차1 = 예측2 + 오차2 
# 실제 = 예측1 + 예측2 + 오차2 
# 실제 = 예측1 + 예측2 + 예측3 + 오차3 으로 점점 늘어난다. 
# 첫번째 모형이 예측하는데 그게 못하는 것을 두번째 모형이 한다. 


# Evaluation between model
allResamples <- resamples(
  list('Elastic Net' = elst.Model,
       'K-NN' = knn.Model,
       'svm' = svm.Model,
       'Neural network' = nnet.Model,
       'tree' = rpart.Model,
       'Random Forest' = rf.Model))
summary(allResamples)

# save & load
save(rf.Model, file="rfModel.RData")
load('rfModel.RData')

# Linear Discriminant Analysis
df$doors <- factor(df$doors)
levels(df$doors)

install.packages("e1071")
library(e1071)

lda.Model <- train(
  doors ~ ., 
  data = train,
  method = 'lda2',
  metric = 'Kappa',
  tuneLength = 2,
  trControl = controlObject)

lda.Model
y = predict(lda.Model, test.c)
confusionMatrix(y, test.c$doors)
