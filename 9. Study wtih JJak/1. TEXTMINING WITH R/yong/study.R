## 병준이가 데이터 하나 잡고 해보랬으니 해보자보자
## 이거슨 범죄 분류/가정상황별 범죄 데이터

crime <- read.csv("crime.csv", stringsAsFactors = F)
View(crime)
str(crime)
rownames(crime) <- crime[,1]
head(crime)
## 내가원하는 경제 생활 계층 컬럼만 가져온다
crimeselect <- subset(crime, select = c(3,4,5))
str(crimeselect)
colnames(crimeselect) <- c("Low", "Middle", "Top")
## 상여리가 별였을만한 범죄만 가져온다
crimeselect <- crimeselect[-c(5,7,12,14,17,18,19,20,21,23,
                              26,27,29,31,32,34,35,38),]
View(crimeselect)
## 범죄 악질에 따라 가중치를 부여하자
a <- c(5,5,3,5,5,3,1,3,3,1,3,1,1,3,3,3,5,5,5,3)
addcrime <- cbind(crimeselect, "가중치" = a)
addcrime <- rbind(addcrime, colSums(addcrime))
rownames(addcrime)[21] <- "total"

View(addcrime)

################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################

## 실패했으니 다른걸로 다른걸 해보자보자
## 이거슨 지역별 17년 4월 10일까지 1년치 대기환경 데이터
envi_set <- read.csv("study_ex.csv", sep="", stringsAsFactors = F)
View(envi_set)
colnames(envi_set) <- c("날짜","위치","이산화질소농도", "오존농도", "일산화탄소농도","아황산가스", "미세먼지", "유히")
sum(is.na(envi_set))
# 결측치 처리
## sum(envi_set$오존농도, na.rm = TRUE) ## - 통계함수 예시
## envi_set <- na.omit(envi_set)
envi_set[is.na(envi_set)] <- 0
## Sys.getlocale()
envi_set$날짜 <- as.Date(as.character(envi_set$날짜), format = '%Y%m%d')

library(zoo)
mov.avr = rollmean(envi_set$미세먼지, 5, na.pad=T)
plot(envi_set$미세먼지,type='l')
lines(envi_set$날짜, mov.avr, col='red', lwd=3) # x 축 : date, y 축 : mov.avr

library("dplyr")
## 16년 05월 데이터로 17년 5월 데이터를 예측하려했따!!
## 방법은 아르마 분석을 통해!! 하지만, 시계열이라고 하기엔 거지같아서.

################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################
################################# 실패 ###################################

## 다시 정신차리고, 선형회귀분석을 실시
## 가설 : 강남대로의 미세먼지가 다른 요소들과 연관성이 있따!
## 16년 05월 전체
envi_1605 <- envi_set %>%
  filter(날짜 >= '2016-05-01' & 날짜<= '2016-05-31', 위치 == '강남대로') %>%
  arrange(날짜) %>%
  group_by(위치)

## 위치와 날짜 데이터 제거하장
envi_1605 <- envi_1605[,-c(1,2)]
View(envi_1605)

## 흠. 대충 정규분포를 따르네?
qqnorm(envi_1605$미세먼지)
qqline(envi_1605$미세먼지)


colnames(envi_1605)
envi_1605 = data.frame(apply(envi_1605,scale,MARGIN = 2))
## 선형회귀 장착
model<-lm(미세먼지~. ,data=envi_1605)
summary(model)
## 피발류가 0.05보다 작아야하는데, 0.01023이다!
## Coefficients..는?...핵존망

## 열받는다 썅 전체해보자
envi_all <- envi_set %>%
  filter(위치 == '강남대로') %>%
  arrange(날짜) %>%
  group_by(위치)

envi_all <- envi_all[,-c(1,2)]

## 오오 개정규분포따름
qqnorm(envi_all$미세먼지)
qqline(envi_all$미세먼지)

## 오오! 피발류가 2.2e-16보다 작단다.
## 2.2e-16은 '0.00000000000000022'란다.by 임강사
## Coefficients도 오존농도&일산화탄소농도&유히에 쓰리스타가 부텄다!
## 개이득
model2 <-lm(미세먼지~. ,data=envi_all)
summary(model2)

###### 오늘 저녁으로 엽기떡볶이를 먹었으니,
###### 조딸 떡볶이와 다른 방법을 해보자 

##install.packages("ROCR")
##install.packages("caret")

library("caret")
library("ROCR")

seyong <- read.delim("Hshopping.txt", stringsAsFactors=FALSE)
str(seyong)
seyong$반품여부 <- factor(seyong$반품여부)

set.seed(1000)
intrain <- createDataPartition(y = seyong$반품여부, p=0.7, list=FALSE) 
train <- seyong[intrain, ]
test <- seyong[-intrain, ]

##########################################################################
##########################################################################
#####Tree 패키지를 사용한 의사결저엉나아무우 혁미니나무 마지막 이프새#####
##########################################################################
##########################################################################
## 이프새가 떨어지면 마음이 아프새

install.packages("tree")
library(tree)
treemodel <- tree(반품여부~ 성별+나이+구매금액+출연자, data=train)
plot(treemodel)
text(treemodel)

## 가지를 쳐서 이프새가 떨어진다. 라미가 떠나간다.
cv.trees <- cv.tree(treemodel, FUN=prune.misclass)
plot(cv.trees)
## 분산이 가장 낮은 가지의 수 선택

prune.trees <- prune.misclass(treemodel, best=10)
plot(prune.trees)
text(prune.trees, pretty=0)

## 분신사바분산사발 오딧세이그랏세이 용도령이 예측한다, 모델평가한다
## 라미미니 올해 결혼확률
library(e1071)
treepred <- predict(prune.trees, test, type='class')
confusionMatrix(treepred, test$반품여부)

##########################################################################
##########################################################################
##### rpart 패키지를 사용한 의사결저엉나아무우 히니 나무 잎이 없프새 #####
##########################################################################
##########################################################################

library(rpart)
rpartmodel <- rpart(반품여부~ 성별+나이+구매금액+출연자, data=train, method = "class")
plot(rpartmodel)
text(rpartmodel)

## rpart패키지도 과적합화 문제가 있기 때문에 가지치기(Pruning)
## rpart패키지에서는 print.cp를 제공
printcp(rpartmodel)
plotcp(rpartmodel)
## 분산이 가장 낮은 것 선택
ptree<-prune(rpartmodel, cp= rpartmodel$cptable[which.min(rpartmodel$cptable[,"xerror"]),"CP"])
plot(ptree)
text(ptree)

## 분신사바분산사발 오딧세이그랏세이 용도령이 예측한다, 모델평가한다
## 히니 남친 10년안에 생길 확률
rpartpred <- predict(ptree, test, type='class')
confusionMatrix(rpartpred, test$반품여부)

##########################################################################
##########################################################################
##party 패키지를 사용한 의사결저엉나아무우 유히가 미국가서 더 살찔 확률###
##########################################################################
##########################################################################

install.packages("party")
library(party)
partymodel <- ctree(반품여부~ 성별+나이+구매금액+출연자, data=train)
plot(partymodel)
## 가지치기를 significance를 사용해서 하기 때문에 별도의 pruning 과정이 필요 없음
## 히니 남친 10년안에 생길 확률
partypred <- predict(partymodel, test)
confusionMatrix(partypred, test$반품여부)
