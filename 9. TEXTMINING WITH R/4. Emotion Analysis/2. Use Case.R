library(tm)
library(tm.plugin.sentiment)
library(glmnet)

# 총 정리 및 복습 

# mobile Review Data 로 감정사전 만들기.

mobile <- read.csv("mobile2014.csv", stringsAsFactors = F)
head(mobile)
corpus <- Corpus(VectorSource(mobile$Texts))
dtm <- DocumentTermMatrix(corpus,
                          control = list(tolower = T,
                                         removePunctuation = T,
                                         removeNumbers = T,
                                         stopwords = stopwords("SMART"),
                                         weighting = weightTfIdf))


my.stopwords <- c(stopwords("SMART"), "aaa") # stopwords에 추가.
my.stopwords[(length(my.stopwords)-5):length(my.stopwords)]

X <- as.matrix(dtm)
Y <- mobile$Sentiment

res.lm <- glmnet(X, Y, family = 'binomial', lambda = 0)
coef.lm <- coef(res.lm)[,1]
pos.lm <- coef.lm[coef.lm > 0]
neg.lm <- coef.lm[coef.lm < 0]
pos.lm <- sort(pos.lm, decreasing = T)
neg.lm <- sort(neg.lm, decreasing = F)


# lasso
res.lasso <- glmnet(X, Y, family = 'binomial', alpha = 1)
set.seed(12345)
res.lasso <- cv.glmnet(X, Y, family = 'binomial', alpha = 1,
                       nfolds = 4, type.measure = 'class') # 최적의 람다값을 찾기위해서 cv.glmnet 을 사용.

# nfodls : 훈련할 학습할 데이터와 검증할 데이터를 나누는 방법을 설정 
# 몇대 몇 : nfodls = 3:! 로 나눠서 트레이닝 및 테스트

coef.lasso <- coef(res.lasso, s = 'lambda.min')[,1]
pos.lasso <- coef.lasso[coef.lasso > 0]
neg.lasso <- coef.lasso[coef.lasso < 0]
pos.lasso <- sort(pos.lasso, decreasing = T)
neg.lasso <- sort(neg.lasso, decreasing = F)

# ridge 
set.seed(12345)
res.ridge <- cv.glmnet(X, Y, family = 'binomial', alpha = 0,
                       nfolds = 4, type.measure = 'class')
coef.ridge <- coef(res.ridge, s = 'lambda.min')[,1]
pos.ridge <- coef.ridge[coef.ridge > 0]
neg.ridge <- coef.ridge[coef.ridge < 0]
pos.ridge <- sort(pos.ridge, decreasing = T)
neg.ridge <- sort(neg.ridge, decreasing = F)

# elastic 
set.seed(12345)
res.elastic <- cv.glmnet(X, Y, family = 'binomial', alpha = .5,
                         nfolds = 4, type.measure = 'class')
coef.elastic <- coef(res.elastic, s = 'lambda.min')[,1]
pos.elastic <- coef.elastic[coef.elastic > 0]
neg.elastic <- coef.elastic[coef.elastic < 0]
pos.elastic <- sort(pos.elastic, decreasing = T)
neg.elastic <- sort(neg.elastic, decreasing = F)


# tablet 데이터 분석

data.test <- read.csv('tablet2014_test.csv', stringsAsFactors = F)
head(data.test)

corpus <- Corpus(VectorSource(data.test$Texts))
dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

library(caret)

confusionMatrix(senti.lm.b.test, data.test$Sentiment) # 69%
confusionMatrix(senti.lasso.b.test, data.test$Sentiment) # 87%
confusionMatrix(senti.ridge.b.test, data.test$Sentiment) # 87%
confusionMatrix(senti.elastic.b.test, data.test$Sentiment) # 88%


# Book 
data.test <- read.csv('books_test.csv', stringsAsFactors = F)
corpus <- Corpus(VectorSource(data.test$Texts))
dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

confusionMatrix(senti.lm.b.test, data.test$Sentiment) # 56.5%
confusionMatrix(senti.lasso.b.test, data.test$Sentiment) # 64.4%
confusionMatrix(senti.ridge.b.test, data.test$Sentiment) # 63.6%
confusionMatrix(senti.elastic.b.test, data.test$Sentiment) # 64.3%



# 모바일폰 / 태블릿 / 도서 데이터 감정분석 정확도 비교
data.test <- read.csv('mobile2014_test.csv', stringsAsFactors = F)
corpus <- Corpus(VectorSource(data.test$Texts))
dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

library(tm.plugin.sentiment)
senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

lm.acc <- confusionMatrix(senti.lm.b.test, data.test$Sentiment)$overall[1]
lasso.acc <- confusionMatrix(senti.lasso.b.test, data.test$Sentiment)$overall[1]
ridge.acc <- confusionMatrix(senti.ridge.b.test, data.test$Sentiment)$overall[1]
elastic.acc <- confusionMatrix(senti.elastic.b.test, data.test$Sentiment)$overall[1]
acc <- c(lm.acc, lasso.acc, ridge.acc, elastic.acc)
names(acc) <- c('lm', 'lasso', 'ridge', 'elastic')

mobile.acc <- acc

## 태블릿
data.test <- read.csv('tablet2014_test.csv', stringsAsFactors = F)
corpus <- Corpus(VectorSource(data.test$Texts))
dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

library(tm.plugin.sentiment)
senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

lm.acc <- confusionMatrix(senti.lm.b.test, data.test$Sentiment)$overall[1]
lasso.acc <- confusionMatrix(senti.lasso.b.test, data.test$Sentiment)$overall[1]
ridge.acc <- confusionMatrix(senti.ridge.b.test, data.test$Sentiment)$overall[1]
elastic.acc <- confusionMatrix(senti.elastic.b.test, data.test$Sentiment)$overall[1]
acc <- c(lm.acc, lasso.acc, ridge.acc, elastic.acc)
names(acc) <- c('lm', 'lasso', 'ridge', 'elastic')

tablet.acc <- acc

## 도서

data.test <- read.csv('books_test.csv', stringsAsFactors = F)
corpus <- Corpus(VectorSource(data.test$Texts))
dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

library(tm.plugin.sentiment)
senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

lm.acc <- confusionMatrix(senti.lm.b.test, data.test$Sentiment)$overall[1]
lasso.acc <- confusionMatrix(senti.lasso.b.test, data.test$Sentiment)$overall[1]
ridge.acc <- confusionMatrix(senti.ridge.b.test, data.test$Sentiment)$overall[1]
elastic.acc <- confusionMatrix(senti.elastic.b.test, data.test$Sentiment)$overall[1]
acc <- c(lm.acc, lasso.acc, ridge.acc, elastic.acc)
names(acc) <- c('lm', 'lasso', 'ridge', 'elastic')

book.acc <- acc

## 정확도 비교

mobile.acc
tablet.acc
book.acc
