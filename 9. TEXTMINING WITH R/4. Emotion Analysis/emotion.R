
mobile <- read.csv('mobile2014.csv', stringsAsFactors = F)

dim(mobile)

names(mobile)

head(mobile)

mobile[2,]
mobile[1035,]

table(mobile$Sentiment) # 부정적인것 0 긍정적인것 1 

library(tm)

#stopwords() # 제거해야될 단어. 

#stopwords("SMART") # 리스트가 적을 수도 있다. 조금 더 많은 양의 단어. 

mobile$Texts <- iconv(mobile$Texts,"UTF-8","CP949")

corpus <- Corpus(VectorSource(mobile$Texts))

dtm <- DocumentTermMatrix(corpus,
                          control = list(tolower = T, 
                                         removePunctuation = T,
                                         removeNumbers = T,
                                         stopwords=stopwords("SMART"),
                                         weighting=weightTfIdf))

dtm

library(glmnet)

X <- as.matrix(dtm)
Y <- mobile$Sentiment

X[1:5,1:5] # 첫번째 사람이 말했던 5개 단어에서 

dim(X)

Y[1:5] # 부정 

Y[1001:1005] # 긍정 

res.lm <- glmnet(X, Y, family = "binomial", lambda = 0) # family : 두가지 값일때는 binomial, 일반적 회귀분석에선 lambda = 0

res.lm

summary(res.lm)

coef.lm <- coef(res.lm)[,1]
pos.lm <- coef.lm[coef.lm > 0]
neg.lm <- coef.lm[coef.lm < 0]
pos.lm <- sort(pos.lm, decreasing = T) # 정렬
neg.lm <- sort(neg.lm, decreasing = F) # 정렬

coef.lm[1:5] # 8453단어 중에서 5개만.

pos.lm[1:5]

neg.lm[1:5]

length(pos.lm) + length(neg.lm) # 회귀계수가 0인게 없다. 어느 선에서 끊을 것인가를 정해야 된다. Lasso를 이용하면 알아서 0으로 만들어준다.

res.lasso <- glmnet(X,Y,family = "binomial", alpha=1)

res.lasso

plot(res.lasso, xvar="lambda")

set.seed(12345)

res.lasso <- cv.glmnet(X,Y,family = "binomial", alpha=1, nfolds=4,
                       type.measure="class")

res.lasso

plot(res.lasso)

log(0.01054217)

plot(res.lasso$glmnet.fit, xvar = "lambda") # 위와 동일한 모양.

options(scipen = 100)

coef.lasso <- coef(res.lasso, s="lambda.min")[,1]

coef.lasso[1:10]

pos.lasso <- coef.lasso[coef.lasso>0]
neg.lasso <- coef.lasso[coef.lasso<0]

pos.lasso <- sort(pos.lasso, decreasing = T)
neg.lasso <- sort(neg.lasso, decreasing = F)

pos.lasso[1:5]

neg.lasso[1:5]

set.seed(12345)

res.ridge <- cv.glmnet(X,Y,family="binomial",alpha=0, nfolds=4, type.measure = "class")

res.ridge

log( 1.71811) # 최적의 람다. 

plot(res.ridge)

plot(res.ridge$glmnet.fit, xvar = "lambda")

coef.ridge <- coef(res.ridge, s = "lambda.min")[,1]

pos.ridge <- coef.ridge[coef.ridge > 0]
neg.ridge <- coef.ridge[coef.ridge < 0]

pos.ridge <- sort(pos.ridge, decreasing = T)
neg.ridge <- sort(neg.ridge, decreasing = F)

pos.ridge[1:5]

neg.ridge[1:5]

set.seed(12345)

res.elastic <- cv.glmnet(X, Y, family = "binomial", alpha = .5,
                         nfolds = 4, type.measure="class") # 알파 0.5 >> 조절가능.

res.elastic

log(0.02424186)

plot(res.elastic)


plot(res.elastic$glmnet.fit, xvar = "lambda")

coef.elastic <- coef(res.elastic, s = "lambda.min")[,1]

pos.elastic <- coef.elastic[coef.elastic > 0]
neg.elastic <- coef.elastic[coef.elastic < 0]

pos.elastic <- sort(pos.elastic, decreasing = T)
neg.elastic <- sort(neg.elastic, decreasing = F)

length(pos.lm)
length(neg.lm)

length(pos.lasso)
length(neg.lasso)

length(pos.ridge)
length(neg.ridge)

length(pos.elastic)
length(neg.elastic)

write.csv(pos.lm, "pos.lm.csv")
write.csv(neg.lm, "neg.lm.csv")
write.csv(pos.lasso, "pos.lasso.csv")
write.csv(neg.lasso, "neg.lasso.csv")
write.csv(pos.ridge, "pos.ridge.csv")
write.csv(neg.ridge, "neg.ridge.csv")
write.csv(pos.elastic, "pos.elastic.csv")
write.csv(neg.elastic, "neg.elastic.csv")

library(tm.plugin.sentiment)

senti.lm <- polarity(dtm, names(pos.lm), names(neg.lm))

senti.lm[1:10]

senti.lasso <- polarity(dtm, names(pos.lasso), names(neg.lasso))

senti.lasso[1:10]

senti.ridge <- polarity(dtm, names(pos.ridge), names(neg.ridge))

senti.ridge[1:10]

senti.elastic <- polarity(dtm, names(pos.elastic), names(neg.elastic))

senti.elastic[1:10]

#pos.lm.csv <- read.csv('pos.lm.csv')
#neg.lm.csv <- read.csv('neg.lm.csv')
#pos.lasso.csv <- read.csv('pos.lasso.csv')
#neg.lasso.csv <- read.csv('neg.lasso.csv')
#senti.lm <- polarity(dtm, pos.lm.csv[,1], neg.lm.csv[,1])
#senti.lasso <- polarity(dtm, pos.lasso.csv[,1], neg.lasso.csv[,1])

senti.lm.b <- ifelse(senti.lm > 0, 1, 0)
senti.lasso.b <- ifelse(senti.lasso > 0, 1, 0)
senti.ridge.b <- ifelse(senti.ridge > 0, 1, 0)
senti.elastic.b <- ifelse(senti.elastic > 0, 1, 0)

library(caret)

confusionMatrix(senti.lm.b, mobile$Sentiment)

confusionMatrix(senti.lasso.b, mobile$Sentiment)

confusionMatrix(senti.ridge.b, mobile$Sentiment)

confusionMatrix(senti.elastic.b, mobile$Sentiment)

mobile.test <- read.csv("mobile2014_test.csv",stringsAsFactors=F)

dim(mobile.test)

names(mobile.test)

mobile.test$Texts <- iconv(mobile.test$Texts,"UTF-8","CP949")

corpus <- Corpus(VectorSource(mobile.test$Texts))

dtm.test <- DocumentTermMatrix(corpus,
                               control = list(tolower = T,
                                              removePunctuation = T,
                                              removeNumbers = T,
                                              stopwords = stopwords("SMART"),
                                              weighting = weightTfIdf,
                                              dictionary = Terms(dtm)))

dtm.test

senti.lm.test <- polarity(dtm.test, names(pos.lm), names(neg.lm))
senti.lasso.test <- polarity(dtm.test, names(pos.lasso), names(neg.lasso))
senti.ridge.test <- polarity(dtm.test, names(pos.ridge), names(neg.ridge))
senti.elastic.test <- polarity(dtm.test, names(pos.elastic), names(neg.elastic))

senti.lm.b.test <- ifelse(senti.lm.test > 0, 1, 0)
senti.lasso.b.test <- ifelse(senti.lasso.test > 0, 1, 0)
senti.ridge.b.test <- ifelse(senti.ridge.test > 0, 1, 0)
senti.elastic.b.test <- ifelse(senti.elastic.test > 0, 1, 0)

confusionMatrix(senti.lm.b.test, mobile.test$Sentiment)

confusionMatrix(senti.lasso.b.test, mobile.test$Sentiment)

confusionMatrix(senti.ridge.b.test, mobile.test$Sentiment)

confusionMatrix(senti.elastic.b.test, mobile.test$Sentiment)
