# 회귀계수를 이용한 감정 분석
library(tm)
library(tm.plugin.sentiment)
library(caret)

# 감성사전이 있을때는 긍정단어가 있으면 1 없으면 0 과 같이 처리함.
# 정말 추천한다 vs 쓸만하다 => 둘다 긍정이지만 정도가 다르다. 
# 앞선 분석에 있어서는 무시가 되었다. 

# 감정사전이 만들어져있다고 가정한다. 
# 앞선 2번에서 데이터를 가지고 오거나 1번에서늬 csv파일을 가지고와서 이용하면된다.
# 현재는 데이터를 만들어져있는 상태이다.

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


# 이전내용
res.lm
res.lasso
res.ridge
res.elastic

X.test <- as.matrix(dtm.test)
senti.lm.test.coef <- predict(res.lm, newx=X.test)
senti.lm.test.coef
senti.lasso.test.coef <- predict(res.lasso, newx = X.test, s = "lambda.min") # 최적의 람다값을 사용.
senti.lasso.test.coef
senti.ridge.test.coef <- predict(res.ridge, newx = X.test, s = "lambda.min")
senti.ridge.test.coef
senti.elastic.test.coef <- predict(res.elastic, newx = X.test, s = "lambda.min")
senti.elastic.test.coef

# 감정값을 0 or 1로 변환
senti.lm.b.test.coef <- ifelse(senti.lm.test.coef > 0, 1, 0)
senti.lasso.b.test.coef <- ifelse(senti.lasso.test.coef > 0, 1, 0)
senti.ridge.b.test.coef <- ifelse(senti.ridge.test.coef > 0, 1, 0)
senti.elastic.b.test.coef <- ifelse(senti.elastic.test.coef > 0, 1, 0)

# 정확도확인.
confusionMatrix(senti.lm.b.test.coef, data.test$Sentiment)$overall[1]
confusionMatrix(senti.lasso.b.test.coef, data.test$Sentiment)$overall[1]
confusionMatrix(senti.ridge.b.test.coef, data.test$Sentiment)$overall[1]
confusionMatrix(senti.elastic.b.test.coef, data.test$Sentiment)$overall[1]
