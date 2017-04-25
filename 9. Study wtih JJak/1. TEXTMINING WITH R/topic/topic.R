#install.packages(c('tm', 'lsa', 'topicmodels', 'lda', 'h2o'), repos='http://cran.nexr.com')

##########################################


# http://www.crowdflower.com/data-for-everyone 에서 News article / Wikipedia page pairings 데이터를 다운

news <- read.csv('News-article-wikipedia-DFE.csv', stringsAsFactors = F)
news$newdescp[1]


library(tm)
tdm <- TermDocumentMatrix(Corpus(VectorSource(news$newdescp)),
                          control = list(removeNumbers = T,
                                         removePunctuation = T,
                                         stopwords = T))

dim(tdm) #  29837 단어, 3000개 문서.
as.matrix(tdm[1:20, 1:20])


library(slam)  # 특수 메트릭스기 때문에 행의 합계를 구하려면 패키지 사용 
word.count <- as.array(rollup(tdm, 2)) # 행합계 2, 열합계 1
sort(word.count, decreasing = T)[1:30]  # 많이 나온 순서별로 횟수 정렬
word.order <- order(word.count, decreasing = T)
freq.word <- word.order[1:30]  # 많이 나온 단어의 행번호 반환
row.names(tdm[freq.word,])



##### R에서 LSA 실행하는 법 #####
install.packages("lsa")
library(lsa)
# news.lsa <- lsa(tdm, 30) # 데이터가 엄청 커서 메모리 부족으로 에러

# 데이터가 너무 커서 돌아가지 않으므로 잘 안쓰이는 단어를 컷
freq.word <- word.order[1:1000] # 상위 1000개까지만
news.lsa <- lsa(tdm[freq.word,], 30)
news.lsa$tk[,1] # 첫번째 차원, 줄어든 차원에서 실제 단어들과 어떤관계가 있는가

importance <- order(abs(news.lsa$tk[,1]), decreasing = T)
news.lsa$tk[importance[1:10],1]

for(i in 1:30){
  print(i)
  importance = order(abs(news.lsa$tk[,i]), decreasing = T)
  print(news.lsa$tk[importance[1:10],i])
}


### Rotation ###
install.packages("GPArotation")
library(GPArotation)
tk <- Varimax(news.lsa$tk)$loadings

for(i in 1:30){
  print(i)
  importance = order(abs(tk[,i]), decreasing = T)
  print(tk[importance[1:10],i])
}

##### 가중치 (tf, idf)

library(lsa)

tdm.mat <- as.matrix(tdm[freq.word,]) # r에서 쓰는 메트릭스로 변환
# lw_로 시작하는 게 local 가중치, gw_로 시작하는 건 global 가중치
tdm.w <- lw_bintf(tdm.mat) * gw_idf(tdm.mat)

news.lsa <- lsa(tdm.w, 30)

library(GPArotation)
tk <- Varimax(news.lsa$tk)$loadings

for(i in 1:30){
  print(i)
  importance = order(abs(tk[,i]), decreasing = T)
  print(tk[importance[1:10],i])
}

##### R에서 문서 좌표와 유사도 구하기

dim(tdm.mat)

doc.space <- t(tk) %*% tdm.mat
dim(doc.space)
doc.space[,1] # 첫번째 문서 좌표
# 그래도 쓰면 해석이 어려움-  문서의 길이에 따라 길어지고 짧아짐

norm <- sqrt(colSums(doc.space^2)) # 문서의 좌표를 제곱합하여 루트 - 원점에서 부터 거리
norm.space <- sweep(doc.space, 2, norm, '/')  # 문서의 좌표를 열 단위를 norm기준으로 해서 나눠줌
norm.space[,1]
sum(norm.space[,1]^2) # 다 제곱해서 더하면 1이 되도록 좌표를 바꿔줌

cosine(norm.space[,1], norm.space[,2]) # 두 문서가 얼마나 유사한지 알아봄 -  1에 가까울수록 유사함



##### R에서 LDA 실행하는 법#####
install.packages("topicmodels")
install.packages("lda")

dtm <- as.DocumentTermMatrix(tdm[freq.word,])

library(topicmodels)  # lda 해주는 패키지 - 성능이 떨어짐
ldaform <- dtm2ldaformat(dtm, omit_empty = T) # dtm을 lda 돌리는 데 필요한 형태로 바꿔주는 함수

library(lda)
# 오래걸림...
result.lda <- lda.collapsed.gibbs.sampler(documents = ldaform$documents,
                                          K = 30, # 토픽의 개수
                                          vocab = ldaform$vocab, # 어떤 단어들이 있는지
                                          num.iterations = 5000, # 몇번이나 반복을 할것인지(반복할수록 결과 좋아짐) 계속 반복한다고 확 좋아지지 않음
                                          burnin = 1000, # 앞부분 결과는 부정확한게 많기 때문에 앞부분을 버림
                                          alpha = 0.01, # 한 문서 내에서 여러개의 토픽이 얼마나 골고루 들어갈지를 정해주는 것 돌려보고 경험적으로
                                          eta = 0.01) # 한 토픽 내에서 얼마나 단어가 골고루 섞여있는가

attributes(result.lda)
# topics, topic_sums, document_sums
# topics 각 단어가 어떤 토픽에 얼마나 할당되어있는지 보여주는 메트릭스
dim(result.lda$topics)
View(result.lda$topics)

top.topic.words(result.lda$topics) # 각 토픽별로 상위 20개 단어를 보여줌
View(top.topic.words(result.lda$topics))

result.lda$topic_sums # 어떤 토픽이 자주 나오는가 전체 단어중에서 어떤 토픽에 해당되는 단어가 많은가
dim(result.lda$document_sums) # 문서별로 30개의 토픽에서 각 토픽에 해당하는 단어가 몇개씩 나오는지?
result.lda$document_sums[,1]
news$newdescp[1]



##### h2o 사용법

library(lsa)

tdm.mat <- as.matrix(tdm[freq.word,])
tdm.mat <- lw_bintf(tdm.mat)  # 뇌세포는 죽어있거나 살아있거나-인공신경망도
tdm.mat[tdm.mat == 0] <- -1  # h2o 패키지에서 0-1을 지원 안함 - 그래서 0을 -1로 변환해줌
tdm.mat[1:10, 1:10]
dtm.mat <- t(tdm.mat) # 딥러닝에서는 documenttermmatrix사용


library(h2o) # 자바로 만들어져있음, 딥러닝 관련된 기능

localH2O <- h2o.init()  # 어떤 서버를 띄워서 자체적으로 작동, r하고는 통신만, 프로그램 실행

dtm.h2o <- as.h2o(dtm.mat) # h2o에서 쓸수 있게 바꿔줌

########

ae.model <- h2o.deeplearning(x = 1000,  # 데이터 사이즈, 분석할 단어의 수
                             training_frame = dtm.h2o,  # 분석에 쓸 데이터
                             activation = "Tanh", # 범위 -1 ~ 1
                             autoencoder = T,
                             ignore_const_cols = T, # 다 똑같은 값인 경우 무시, 해도되고 안해도 되고
                             hidden = c(500, 30, 500),  # 중간 레이어 갯수
                             epochs = 10)  # 데이터를 몇번을 학습시킬것인가

#결과보기
features <- h2o.deepfeatures(ae.model, dtm.h2o, layer = 2) # 결과 보기 layer=2 두번째 레이어
View(features)

anomaly <- as.data.frame(h2o.anomaly(ae.model, dtm.h2o)) # 패턴에서 벗어난 글을 찾을 수 있다
View(anomaly) # 다시 복구시켰을때 얼마나 원래 데이터랑 다르게 복구되는가
which.max(anomaly$Reconstruction.MSE)
news$newdescp[45]

h2o.shutdown(F) # h2o 닫아줌
