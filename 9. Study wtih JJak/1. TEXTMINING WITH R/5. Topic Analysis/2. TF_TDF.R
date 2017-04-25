# 가중치 (tf, idf)
# Weighting 가중치 
# - Local : 어떤 문서에는어떤 단어가 몇번나오고 어떤건 몇번나오고, 몇번나오던 상관없이 나오면 1 아니면 0 또는 영향도를 줄이는 경우.
# <ul>
#  <li>TF(Term Frequency): 한문서에 등장한 단어수</li>
#  <li>Log(TF), Log(10)과 Log(100)과 차이와 Log(100)과 Log(1000)의 차이가 같다. 왕창 늘어나도 영향도를 줄인다.</li>
#  <li>Binary : 등장하면 1, 아니면 0 예)의미없는 인용구 </li> 
#   <ol> 단점 : 너무 극단적이다.</ol>
# </ul>
# - Global : 어떤 문서던 많이 쓰여지는 단어를 줄여줘야된다. 예) 누가 ~라고 말했다.
# <ul>
#  <li>Normalization</li>
#  <li>IDF(Inverse document frequency) </li>
#  <li>GFIDF : 단어의 전체 등장 수 * IDF</li>
# </ul>
# - Entropy

library(tm)
library(slam)
library(lsa)

news = read.csv('News-article-wikipedia-DFE.csv', stringsAsFactors = F)
tdm = TermDocumentMatrix(Corpus(VectorSource(news$newdescp)),
                         control = list(removeNumbers = T,
                                        removePunctuation = T,
                                        stopwords = T))

word.count = as.array(rollup(tdm, 2))
word.order = order(word.count, decreasing = T)
freq.word = word.order[1:30]

library(lsa)

tdm.mat = as.matrix(tdm[freq.word,])
# lw_ 를 사용하며 나온다. 
tdm.w <- lw_bintf(tdm.mat) * gw_idf(tdm.mat)

news.lsa = lsa(tdm.w,30) # 메모리 부족으로 에러가 날것이다.

library(GPArotation)
tk = Varimax(news.lsa$tk)$loadings
tk
for(i in 1:30){
  print(i)
  importance = order(abs(tk[,i]), decreasing = T)
  print(tk[importance[1:10], i])
}
