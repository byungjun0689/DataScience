# DeepLearning 
# Artificial NeuralNetwork 
# 22.png
# Multi Layer (Deep)
# Auto Encoder -> 하나의 종류의 신호를 다른종류로 변환시키는 것을 Encoder라고 한다.
# 23.PNG
# 얼굴그림을 신경망으로 넣어주면 다시 원래 그그림이 나오도록 짜준다. 
# 가운데는 신경세포가 30개 밖에 없어서 정보가 줄어든다. 다시 30에서 1000 개 2000개로 늘어난다는 것은 어렵다. 최대한 조합을 잘해서 살아날 수 있도록.
# Encoder -> Decorder로 푼다. 
# 2000->30 (LSA)로 차원을 줄인다. 불필요한 데이터만을 줄이고 필요한 데이터를 할 수 있는
# 24.PNG
# LSA vs AutoEncoder (LSA50차원, AutoEncoder 10차원과 비)
# 25.PNG
# 똑같이 2차원으로 분류를 해도 깨끗하게 차원이 축소가 된다. (AutoEncoding)
# DeepLearning 단점
# 1. 해석이 어렵다.
# 2. 데이터가 엄청 많이 필요
# 3. 시간이 오래 걸림

install.packages("h2o")
library(tm)
library(slam)
library(lsa)
library(h2o)


news <- read.csv("News-article-wikipedia-DFE.csv", stringsAsFactors = F)
tdm <- TermDocumentMatrix(Corpus(VectorSource(news$newdescp)), 
                          control=list(
                            removePunctuation=T,
                            removeNumbers=T,
                            stopwords=T
                          ))

# Word Count 세기.
word.count <- as.array(rollup(tdm,2))
word.order <- order(word.count,decreasing = T)
freq.word <- word.order[1:1000]


# Weight를 가중치를 줘서 0아니면 1로 변환되도록 
# lw_bintf = Weighting Schemes (Matrices) binoary weight
# Calculates a weighted document-term matrix according to the chosen local and/or global weighting scheme.
tdm.mat = as.matrix(tdm[freq.word,])

tdm.mat = lw_bintf(tdm.mat) # 신경망이 종류가 여러가지가 있는데 0~1까지 범위를 가지는 신경세포로 표현. 0 아니면 1
tdm.mat[tdm.mat == 0] = -1
tdm.mat[1:10, 1:10] # 나왔으면 1 안나왔으면 -1

dtm.mat = t(tdm.mat) # Deep Learning은 DocumentTermMatrix를 이용한다. 

library(h2o)  # Java로 구성된 패키지로 R도 사용할 수 있고, Python에서도 사용할 수 있다. R에서 DeepLearning에 대해서 기능이 조금 부족하다.

localH2O = h2o.init()
dtm.h2o = as.h2o(dtm.mat)

ae.model = h2o.deeplearning(x = 1000, # 분석할 단어의 수
                            training_frame = dtm.h2o, # 분석에 쓸 데이터.
                            activation = "Tanh", # 활성함수 Tanh(-1~1), c("Tanh", "TanhWithDropout", "Rectifier", "RectifierWithDropout", "Maxout", "MaxoutWithDropout"), 
                            autoencoder = T,
                            ignore_const_cols = T,
                            hidden = c(500, 30, 500), # Layer를 어떻게 할 것인가. 1Layer : 1000 2Layer : 500, 3Layer : 30, 4Layer : 500, Last Layer :1000
                            epochs = 100) # 몇번 학습할 것 인가?

features = h2o.deepfeatures(ae.model, dtm.h2o, layer=2) # 분석결과, 데이터, Layer 2를 보려고하는것. 30개 짜리 Layer의 내용.
View(features) # Row : 3000개의 문서.
anomaly = as.data.frame(h2o.anomaly(ae.model, dtm.h2o)) # Detect anomalies in an H2O dataset using an H2O deep learning model with auto-encoding.
# 원래의 데이터를 가장 손실없이 줄인다. 어떤 데이터는 줄여도 정보손실이 적은게 있고 어떤건 많은 경우가 있다. 
# 텍스트들이 일정한 패턴이 있는데 크게 벗어나지 않으면 정보 손실이 적은데, 크게 벗어나면 손실이 크다. 
# 이것을 활용해서 이상한 글을 찾을 수 있다. 

View(anomaly)
# Reconstruction.MSE 차원복원했을때 얼마나 차이가 나는 것인가?
which.max(anomaly$Reconstruction.MSE) # 제일 큰 값.
anomaly[45,]
news$newdescp[45]

h2o.shutdown(localH2O, F)


